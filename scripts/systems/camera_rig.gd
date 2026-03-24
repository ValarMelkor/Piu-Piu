extends Node3D
class_name CameraRig

enum CameraMode { COMBAT, TACTICAL }

signal camera_mode_changed(mode_name: String)

@export var camera_config: CameraConfig

var mode: CameraMode = CameraMode.COMBAT
var tactical_distance_current: float
var precision_active: bool = false

@onready var camera_3d: Camera3D = $Camera3D
@onready var combat_anchor: Marker3D = $CombatAnchor
@onready var tactical_anchor: Marker3D = $TacticalAnchor

func _ready() -> void:
	tactical_distance_current = camera_config.tactical_distance
	_apply_mode(true)

func toggle_mode() -> void:
	mode = CameraMode.TACTICAL if mode == CameraMode.COMBAT else CameraMode.COMBAT
	_apply_mode(false)

func set_precision_zoom(active: bool) -> void:
	precision_active = active

func process_zoom(zoom_in: bool) -> void:
	if mode != CameraMode.TACTICAL:
		return
	var dir := -1.0 if zoom_in else 1.0
	tactical_distance_current = clampf(
		tactical_distance_current + dir * camera_config.tactical_zoom_step,
		camera_config.tactical_min_distance,
		camera_config.tactical_max_distance
	)

func update_camera(delta: float, turret_position: Vector3) -> void:
	if mode == CameraMode.COMBAT:
		global_position = turret_position
		rotation = Vector3.ZERO
		var target_fov := camera_config.combat_precision_fov_deg if precision_active else camera_config.combat_fov_deg
		camera_3d.fov = lerpf(camera_3d.fov, target_fov, clampf(delta * camera_config.combat_lerp_speed, 0.0, 1.0))
		camera_3d.global_position = camera_3d.global_position.lerp(combat_anchor.global_position, clampf(delta * camera_config.combat_lerp_speed, 0.0, 1.0))
		camera_3d.global_basis = camera_3d.global_basis.slerp(combat_anchor.global_basis, clampf(delta * camera_config.combat_lerp_speed, 0.0, 1.0))
	else:
		var tactical_target := turret_position + Vector3(0.0, camera_config.tactical_height, tactical_distance_current)
		camera_3d.global_position = camera_3d.global_position.lerp(tactical_target, clampf(delta * camera_config.tactical_lerp_speed, 0.0, 1.0))
		camera_3d.look_at(turret_position + Vector3(0.0, 20.0, 0.0), Vector3.UP)
		camera_3d.fov = lerpf(camera_3d.fov, camera_config.combat_fov_deg, clampf(delta * camera_config.tactical_lerp_speed, 0.0, 1.0))

func get_mode_name() -> String:
	return "CombatView" if mode == CameraMode.COMBAT else "TacticalView"

func get_current_fov() -> float:
	return camera_3d.fov

func _apply_mode(immediate: bool) -> void:
	emit_signal("camera_mode_changed", get_mode_name())
	if immediate:
		if mode == CameraMode.COMBAT:
			camera_3d.global_position = combat_anchor.global_position
			camera_3d.global_basis = combat_anchor.global_basis
		else:
			camera_3d.global_position = tactical_anchor.global_position
			camera_3d.global_basis = tactical_anchor.global_basis
