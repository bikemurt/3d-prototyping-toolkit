@tool
class_name ProtoSetup
extends Node

func _ready() -> void:
	if Engine.is_editor_hint():
		ProjectSettings.set_setting("autoload/ProtoGame", "*res://addons/prototyping_toolkit_3d/proto_game.gd")
		var error := ProjectSettings.save()
		if error == OK:
			Proto.proto_print("ProtoSetup autoload registered")
		else:
			printerr("[PROTO] Failed to register ProtoSetup autoload. Error code: ", error)
