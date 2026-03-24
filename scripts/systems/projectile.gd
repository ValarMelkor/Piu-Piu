extends Node3D
class_name Projectile

signal hit_target(target: Node3D, hit_position: Vector3)
signal expired(reason: String)

var config: ProjectileConfig
var velocity: Vector3 = Vector3.ZERO
var start_position: Vector3 = Vector3.ZERO
var life_time: float = 0.0

@onready var body_mesh: MeshInstance3D = $BodyMesh

func setup(projectile_config: ProjectileConfig, origin: Vector3, direction: Vector3) -> void:
	config = projectile_config
	start_position = origin
	global_position = origin
	velocity = direction.normalized() * config.speed_mps
	if body_mesh.material_override is StandardMaterial3D:
		(body_mesh.material_override as StandardMaterial3D).albedo_color = config.color

func _physics_process(delta: float) -> void:
	if config == null:
		return
	life_time += delta
	velocity += config.gravity * delta
	var old_pos := global_position
	var new_pos := old_pos + velocity * delta
	var result := _raycast(old_pos, new_pos)
	if result.has("collider"):
		var collider := result.collider
		if collider and collider.is_in_group("targets"):
			emit_signal("hit_target", collider as Node3D, result.position)
			queue_free()
			return
	global_position = new_pos
	if life_time >= config.max_lifetime_sec:
		emit_signal("expired", "lifetime")
		queue_free()
		return
	if global_position.distance_to(start_position) >= config.max_range_m:
		emit_signal("expired", "range")
		queue_free()

func _raycast(from: Vector3, to: Vector3) -> Dictionary:
	var state := get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.create(from, to)
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.hit_from_inside = true
	return state.intersect_ray(params)
