@tool
class_name ProtoSimpleFloor
extends StaticBody3D

@export var size := 1000.0
@export var load_on_ready := true

@export_tool_button("Initialize Nodes") var initialize_nodes := func() -> void:
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(size, 1, size)
	mesh_instance.mesh = box_mesh
	mesh_instance.name = "MeshInstance3D"
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(Color.BLACK)
	
	mesh_instance.set_surface_override_material(0, mat)
	
	add_child(mesh_instance)
	mesh_instance.owner = get_tree().edited_scene_root
	
	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(size, 1, size)
	collision.shape = box_shape
	collision.name = "CollisionShape3D"
	
	add_child(collision)
	collision.owner = get_tree().edited_scene_root
	
	position.y = -0.5
	
	Proto.proto_print("Simple floor nodes configured")

@export_tool_button("Clear Child Nodes") var clear_child_nodes := func() -> void:
	for c in get_children(): c.free()

func _ready() -> void:
	if Engine.is_editor_hint():
		if load_on_ready:
			if get_child_count() == 0: initialize_nodes.call()
