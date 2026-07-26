@tool
class_name ProtoInteractForcePush
extends RigidBody3D

@export_tool_button("Generate Nodes") var initialize_nodes := func() -> void:
	for c in get_children(): c.free()

	if mesh:
		var mesh_instance := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = Vector3.ONE
		mesh_instance.mesh = box_mesh
		Proto.add_node(self, mesh_instance)
	
	var col := CollisionShape3D.new()
	
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3.ONE
	col.shape = box_shape
	
	area_3d = Area3D.new()
	var col_2 := col.duplicate()
	Proto.add_node(self, area_3d)
	Proto.add_node(area_3d, col_2)
	
	Proto.add_node(self, col)
	
	position.y = 0.5
	
	Proto.proto_print("Interactable force push generated")

@export var load_on_ready := true
@export var mesh := true
@export var force_strength := 5.0
@export var area_3d: Area3D

var proto_game: Node

func _ready() -> void:
	if Engine.is_editor_hint():
		if load_on_ready:
			if get_child_count() == 0: initialize_nodes.call()
		return
	
	proto_game = Proto.get_autoload(self, "ProtoGame")
	if proto_game:
		proto_game.signal_hub.interact.connect(on_interact)

func on_interact(source: Node3D, target: Node3D) -> void:
	if target != area_3d: return
	
	var direction := source.global_position.direction_to(target.global_position)
	apply_central_impulse(force_strength * direction)
