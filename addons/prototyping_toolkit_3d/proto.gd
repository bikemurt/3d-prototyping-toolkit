@tool
class_name Proto
extends Node

static var signal_hub: ProtoSignalHub

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
