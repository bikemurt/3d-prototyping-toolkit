@tool
class_name Proto
extends Node

static func proto_print(msg: String) -> void:
	var print_enabled := true
	if print_enabled:
		print("[PROTO] " + msg)
