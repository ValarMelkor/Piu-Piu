extends Node3D

@export var world_config: WorldConfig
@export var turret_config: TurretConfig
@export var camera_config: CameraConfig
@export var projectile_config: ProjectileConfig
@export var target_config: TargetConfig
@export var spawn_config: SpawnConfig

var debug_enabled: bool = true
var last_yaw: float = 0.0
var last_pitch: float = 20.0

@onready var dome_arena: DomeArena = $WorldRoot/DomeArena
@onready var player_turret: PlayerTurret = $WorldRoot/TurretRoot/PlayerTurret
@onready var camera_rig: CameraRig = $WorldRoot/CameraRig
@onready var projectile_manager: ProjectileManager = $WorldRoot/ProjectileManager
@onready var target_manager: TargetManager = $WorldRoot/TargetManager
@onready var hud: HUD = $UI/HUD
@onready var debug_overlay: DebugOverlay = $UI/DebugOverlay
@onready var metrics: MetricsRecorder = $MetricsRecorder
@onready var debug_draw: Node3D = $WorldRoot/DebugDraw

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	dome_arena.world_config = world_config
	player_turret.turret_config = turret_config
	camera_rig.camera_config = camera_config
	target_manager.configure(world_config, target_config, spawn_config)
	target_manager.spawn_initial()

	player_turret.shot_fired.connect(_on_shot_fired)
	player_turret.turret_angles_changed.connect(_on_turret_angles_changed)
	target_manager.target_destroyed.connect(_on_target_destroyed)
	debug_overlay.set_visible_debug(debug_enabled)
	metrics.record_event("Simulation started")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		player_turret.process_mouse_motion(event.relative)
	if event.is_action_pressed("camera_toggle"):
		camera_rig.toggle_mode()
	if event.is_action_pressed("restart_scene"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("toggle_debug"):
		debug_enabled = not debug_enabled
		debug_overlay.set_visible_debug(debug_enabled)
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
	if event.is_action_pressed("tactical_zoom_in"):
		camera_rig.process_zoom(true)
	if event.is_action_pressed("tactical_zoom_out"):
		camera_rig.process_zoom(false)

func _physics_process(delta: float) -> void:
	player_turret.update_turret(delta)
	camera_rig.set_precision_zoom(Input.is_action_pressed("precision_zoom"))
	camera_rig.update_camera(delta, player_turret.global_position)
	if Input.is_action_pressed("fire") and player_turret.try_fire():
		metrics.record_shot()
	_update_ui()
	_update_debug_draw()

func _on_turret_angles_changed(yaw_deg: float, pitch_deg: float) -> void:
	last_yaw = yaw_deg
	last_pitch = pitch_deg

func _on_shot_fired(origin: Vector3, direction: Vector3) -> void:
	var projectile := projectile_manager.spawn_projectile(projectile_config, origin, direction)
	if projectile == null:
		return
	projectile.hit_target.connect(_on_projectile_hit_target)
	projectile.expired.connect(_on_projectile_expired)
	if debug_enabled:
		_draw_shot_ray(origin, direction * 100.0)

func _on_projectile_hit_target(target: Node3D, hit_position: Vector3) -> void:
	if target is Target:
		metrics.record_hit(target.name, hit_position.length())
		(target as Target).destroy()

func _on_projectile_expired(reason: String) -> void:
	metrics.record_miss(reason)

func _on_target_destroyed(target_name: String, distance_m: float) -> void:
	metrics.record_event("Target down: %s (%.1fm)" % [target_name, distance_m])

func _update_ui() -> void:
	hud.update_hud({
		"targets": target_manager.get_target_count(),
		"hits": metrics.hits,
		"misses": metrics.misses,
		"accuracy": metrics.accuracy(),
		"closest_target": target_manager.closest_target_distance(player_turret.global_position),
		"fps": Engine.get_frames_per_second(),
		"camera": camera_rig.get_mode_name(),
		"yaw": last_yaw,
		"pitch": last_pitch
	})
	debug_overlay.update_debug({
		"fov": camera_rig.get_current_fov(),
		"sensor_range": world_config.detection_range_m,
		"projectiles": projectile_manager.count(),
		"avg_target_speed": target_manager.average_speed(),
		"logs": metrics.event_logs,
		"turret_limits": player_turret.get_limits_text(),
		"draw_debug": debug_enabled
	})

func _update_debug_draw() -> void:
	debug_draw.visible = debug_enabled

func _draw_shot_ray(origin: Vector3, vec: Vector3) -> void:
	var mi := MeshInstance3D.new()
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_add_vertex(origin)
	im.surface_add_vertex(origin + vec)
	im.surface_end()
	mi.mesh = im
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.15, 0.15)
	mi.material_override = mat
	debug_draw.add_child(mi)
	await get_tree().create_timer(0.4).timeout
	if is_instance_valid(mi):
		mi.queue_free()
