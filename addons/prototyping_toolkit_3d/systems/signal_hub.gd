@tool
class_name ProtoSignalHub
extends Node

signal interact_hover_on(node: Node)
signal interact_hover_off
signal interact(node: Node)

@export_multiline("Note") var note := "READ:\nThis node must exist at the top of the scene tree."

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		get_parent().move_child.call_deferred(self, 0)
		Proto.proto_print("Signal hub configured")

func _ready() -> void:
	if not Engine.is_editor_hint():
		Proto.signal_hub = self
