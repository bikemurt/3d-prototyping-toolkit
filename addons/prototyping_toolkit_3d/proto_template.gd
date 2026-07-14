@tool
#class_name ProtoTemplate
extends Node

# this script is meant to be copied not inherited from
# inheritance doesn't really work, because every proto class inherits from different nodes
# e.g. CharacterBody3D (character controllers) vs CanvasLayer (simple pause), breaks inheritance

@export var load_on_ready := true

@export_tool_button("Generate Nodes") var initialize_nodes := func() -> void:
	for c in get_children(): c.free()

func _ready() -> void:
	if Engine.is_editor_hint():
		if load_on_ready:
			if get_child_count() == 0: initialize_nodes.call()
