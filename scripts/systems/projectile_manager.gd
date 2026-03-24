extends Node3D
class_name ProjectileManager

signal projectile_count_changed(count: int)

@export var projectile_scene: PackedScene

var active_projectiles: Array[Projectile] = []

func spawn_projectile(projectile_config: ProjectileConfig, origin: Vector3, direction: Vector3) -> Projectile:
	if projectile_scene == null:
		return null
	var projectile := projectile_scene.instantiate() as Projectile
	add_child(projectile)
	projectile.setup(projectile_config, origin, direction)
	projectile.tree_exited.connect(_on_projectile_exited.bind(projectile))
	active_projectiles.append(projectile)
	emit_signal("projectile_count_changed", active_projectiles.size())
	return projectile

func count() -> int:
	return active_projectiles.size()

func _on_projectile_exited(projectile: Projectile) -> void:
	active_projectiles.erase(projectile)
	emit_signal("projectile_count_changed", active_projectiles.size())
