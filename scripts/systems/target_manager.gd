extends Node3D
class_name TargetManager

signal target_count_changed(count: int)
signal target_destroyed(target_name: String, distance_m: float)

@export var target_scene: PackedScene

var targets: Array[Target] = []
var world_config: WorldConfig
var target_config: TargetConfig
var spawn_config: SpawnConfig

func configure(wconfig: WorldConfig, tconfig: TargetConfig, sconfig: SpawnConfig) -> void:
	world_config = wconfig
	target_config = tconfig
	spawn_config = sconfig

func spawn_initial() -> void:
	for i in spawn_config.initial_target_count:
		spawn_one()

func spawn_one() -> Target:
	if target_scene == null:
		return null
	var target := target_scene.instantiate() as Target
	target.name = "Target_%d" % Time.get_ticks_usec()
	add_child(target)
	target.global_position = _random_spawn_position()
	target.setup(target_config, world_config)
	target.destroyed.connect(_on_target_destroyed)
	targets.append(target)
	emit_signal("target_count_changed", targets.size())
	return target

func get_target_count() -> int:
	return targets.size()

func closest_target_distance(from_position: Vector3) -> float:
	if targets.is_empty():
		return -1.0
	var closest := INF
	for target in targets:
		if is_instance_valid(target):
			closest = min(closest, from_position.distance_to(target.global_position))
	return closest

func average_speed() -> float:
	if targets.is_empty():
		return 0.0
	var total := 0.0
	var valid := 0
	for target in targets:
		if is_instance_valid(target):
			total += target.velocity.length()
			valid += 1
	if valid <= 0:
		return 0.0
	return total / float(valid)

func _on_target_destroyed(target: Target) -> void:
	if not is_instance_valid(target):
		return
	var distance := target.global_position.length()
	targets.erase(target)
	emit_signal("target_destroyed", target.name, distance)
	emit_signal("target_count_changed", targets.size())
	if target_config.can_respawn:
		await get_tree().create_timer(target_config.respawn_delay_sec).timeout
		if is_inside_tree():
			spawn_one()

func _random_spawn_position() -> Vector3:
	var theta := randf_range(0.0, TAU)
	var radius := randf_range(spawn_config.min_spawn_radius_m, spawn_config.max_spawn_radius_m)
	var height := randf_range(spawn_config.min_spawn_height_m, spawn_config.max_spawn_height_m)
	return Vector3(cos(theta) * radius, height, sin(theta) * radius)
