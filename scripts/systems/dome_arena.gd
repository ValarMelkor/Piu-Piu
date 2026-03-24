extends Node3D
class_name DomeArena

@export var world_config: WorldConfig

@onready var floor_mesh: MeshInstance3D = $Floor
@onready var dome_mesh: MeshInstance3D = $Dome
@onready var markers_root: Node3D = $ScaleMarkers

func _ready() -> void:
	_build_arena()

func _build_arena() -> void:
	var radius := world_config.dome_diameter_m * 0.5
	var floor := CylinderMesh.new()
	floor.top_radius = radius
	floor.bottom_radius = radius
	floor.height = 1.0
	floor.radial_segments = 64
	floor_mesh.mesh = floor
	floor_mesh.position = Vector3(0.0, world_config.floor_y - 0.5, 0.0)

	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 64
	sphere.rings = 24
	dome_mesh.mesh = sphere
	dome_mesh.position.y = world_config.floor_y
	dome_mesh.scale = Vector3(1.0, 0.5, 1.0)

	for child in markers_root.get_children():
		child.queue_free()
	for i in world_config.scale_mark_count:
		var dist := float(i + 1) * world_config.scale_mark_spacing_m
		var ring := MeshInstance3D.new()
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = dist - 0.4
		ring_mesh.outer_radius = dist + 0.4
		ring_mesh.ring_sides = 8
		ring_mesh.sides = 48
		ring.mesh = ring_mesh
		ring.rotation_degrees.x = 90.0
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.25, 0.8, 0.9, 0.5)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring.material_override = mat
		markers_root.add_child(ring)
