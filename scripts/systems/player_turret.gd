extends Node3D
class_name PlayerTurret

signal shot_fired(origin: Vector3, direction: Vector3)
signal turret_angles_changed(yaw_deg: float, pitch_deg: float)

@export var turret_config: TurretConfig

var current_yaw_deg: float = 0.0
var current_pitch_deg: float = 20.0
var target_yaw_deg: float = 0.0
var target_pitch_deg: float = 20.0
var can_fire_at_sec: float = 0.0

@onready var yaw_base: Node3D = $YawBase
@onready var pitch_pivot: Node3D = $YawBase/PitchPivot
@onready var muzzle: Marker3D = $YawBase/PitchPivot/Muzzle

func _ready() -> void:
	apply_angles_immediate()

func process_mouse_motion(relative: Vector2) -> void:
	if turret_config == null:
		return
	target_yaw_deg -= relative.x * turret_config.mouse_sensitivity_deg
	target_pitch_deg -= relative.y * turret_config.mouse_sensitivity_deg
	var yaw_half := turret_config.yaw_total_deg * 0.5
	target_yaw_deg = clampf(target_yaw_deg, -yaw_half, yaw_half)
	target_pitch_deg = clampf(target_pitch_deg, turret_config.pitch_min_deg, turret_config.pitch_max_deg)

func update_turret(delta: float) -> void:
	if turret_config == null:
		return
	var yaw_step := turret_config.yaw_speed_deg_per_sec * delta
	var pitch_step := turret_config.pitch_speed_deg_per_sec * delta
	current_yaw_deg = move_toward(current_yaw_deg, target_yaw_deg, yaw_step)
	current_pitch_deg = move_toward(current_pitch_deg, target_pitch_deg, pitch_step)
	if turret_config.use_smoothing:
		var t := clampf(delta * turret_config.smoothing_speed, 0.0, 1.0)
		yaw_base.rotation.y = lerp_angle(yaw_base.rotation.y, deg_to_rad(current_yaw_deg), t)
		pitch_pivot.rotation.x = lerp_angle(pitch_pivot.rotation.x, deg_to_rad(-current_pitch_deg), t)
	else:
		apply_angles_immediate()
	emit_signal("turret_angles_changed", current_yaw_deg, current_pitch_deg)

func try_fire() -> bool:
	if turret_config == null:
		return false
	var now_sec := float(Time.get_ticks_msec()) * 0.001
	if now_sec < can_fire_at_sec:
		return false
	can_fire_at_sec = now_sec + turret_config.fire_interval_sec
	var direction := -muzzle.global_transform.basis.z.normalized()
	emit_signal("shot_fired", muzzle.global_position, direction)
	return true

func apply_angles_immediate() -> void:
	yaw_base.rotation.y = deg_to_rad(current_yaw_deg)
	pitch_pivot.rotation.x = deg_to_rad(-current_pitch_deg)

func get_limits_text() -> String:
	return "Yaw ±%.1f | Pitch [%.1f, %.1f]" % [turret_config.yaw_total_deg * 0.5, turret_config.pitch_min_deg, turret_config.pitch_max_deg]
