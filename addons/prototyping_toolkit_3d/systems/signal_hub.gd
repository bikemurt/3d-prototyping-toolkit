@tool
class_name ProtoSignalHub
extends Node

signal interact_hover_on(node: Node)
signal interact_hover_off
signal interact(node: Node)

var last_is_colliding := false

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		get_parent().move_child.call_deferred(self, 0)
		Proto.proto_print("Signal hub configured")
