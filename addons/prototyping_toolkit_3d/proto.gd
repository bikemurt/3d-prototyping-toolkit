@tool
class_name Proto
extends Node

static func proto_print(msg: String) -> void:
	var print_enabled := true
	if print_enabled:
		print("[PROTO] " + msg)

static func add_node(target: Node, node: Node, name_override := "") -> void:
	if name_override == "":
		node.name = node.get_class()
	else:
		node.name = name_override
	target.add_child(node)
	node.owner = target.get_tree().edited_scene_root

static func process_interact_raycast(source: Node3D, proto_signal_hub: ProtoSignalHub, raycast: RayCast3D) -> void:
	if proto_signal_hub and raycast:
		var is_colliding := raycast.is_colliding()
		var collider := raycast.get_collider()
		if is_colliding != proto_signal_hub.last_is_colliding:
			if is_colliding:
				proto_signal_hub.interact_hover_on.emit(collider)
			else:
				proto_signal_hub.interact_hover_off.emit()
			
			proto_signal_hub.last_is_colliding = is_colliding
		
		if is_colliding and Input.is_action_just_pressed(&"interact"):
			proto_signal_hub.interact.emit(source, collider)

static func get_autoload(node: Node, autoload_name: String) -> Node:
	if node.get_tree().root.has_node(autoload_name):
		return node.get_tree().root.get_node(autoload_name)
	return null
