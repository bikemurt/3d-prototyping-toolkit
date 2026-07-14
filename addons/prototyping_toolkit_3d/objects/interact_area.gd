@tool
class_name ProtoInteractArea
extends Node3D

@export_tool_button("Generate Nodes") var initialize_nodes := func() -> void:
	for c in get_children(): c.free()
	
	if mesh:
		var mesh_instance := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = Vector3.ONE
		mesh_instance.mesh = box_mesh
		Proto.add_node(self, mesh_instance)
	
	var area_3d := Area3D.new()
	var col := CollisionShape3D.new()
	
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3.ONE
	col.shape = box_shape
	
	Proto.add_node(self, area_3d)
	Proto.add_node(area_3d, col)
	
	interact_label = Label3D.new()
	interact_label.text = "Interact"
	interact_label.position.y = 1.0
	interact_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	Proto.add_node(self, interact_label)
	
	position.y = 0.5
	
	Proto.proto_print("Interactable nodes configured")

@export var load_on_ready := true
@export var mesh := true
@export var interact_label: Label3D

var interact_tween: Tween

func _ready() -> void:
	if Engine.is_editor_hint():
		if load_on_ready:
			if get_child_count() == 0: initialize_nodes.call()
	else:
		if Proto.signal_hub:
			Proto.signal_hub.interact.connect(on_interact)
		if interact_label:
			interact_label.hide()

func on_interact(node: Node) -> void:
	interact_label.text = "Interact (%s)" % node.name
	interact_label.show()
	await get_tree().create_timer(1.0).timeout
	interact_label.hide()
