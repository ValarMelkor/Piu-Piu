extends Area3D
class_name Target

signal destroyed(target: Target)

var target_config: TargetConfig
var world_config: WorldConfig
var velocity: Vector3 = Vector3.ZERO
var next_change_time: float = 0.0

@onready var mesh_instance: MeshInstance3D = $Visual

func setup(config: TargetConfig, wconfig: WorldConfig) -> void:
	target_config = config
	world_config = wconfig
	add_to_group("targets")
	_pick_new_direction()
	_schedule_next_direction_change()

func _physics_process(delta: float) -> void:
	if target_config == null or world_config == null:
		return
	next_change_time -= delta
	if next_change_time <= 0.0:
		_pick_new_direction()
		_schedule_next_direction_change()
	var wobble := Vector3(
		sin(Time.get_ticks_msec() * 0.002 + global_position.x * 0.01),
		sin(Time.get_ticks_msec() * 0.0017 + global_position.z * 0.013),
		cos(Time.get_ticks_msec() * 0.0014 + global_position.y * 0.009)
	) * target_config.wobble_strength
	global_position += (velocity + wobble) * delta
	_constrain_inside_dome()

func destroy() -> void:
	emit_signal("destroyed", self)
	queue_free()

func _pick_new_direction() -> void:
	var dir := Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-0.25, 0.9),
		randf_range(-1.0, 1.0)
	).normalized()
	velocity = dir * target_config.speed_mps

func _schedule_next_direction_change() -> void:
	next_change_time = randf_range(target_config.direction_change_interval_min, target_config.direction_change_interval_max)

func _constrain_inside_dome() -> void:
	var max_radius := world_config.dome_diameter_m * 0.5 - target_config.target_radius_m * 2.0
	var pos := global_position
	if pos.y < world_config.floor_y + target_config.target_radius_m:
		pos.y = world_config.floor_y + target_config.target_radius_m
		velocity.y = absf(velocity.y)
	if pos.length() > max_radius:
		var normal := pos.normalized()
		pos = normal * max_radius
		velocity = velocity.bounce(normal)
	global_position = pos
