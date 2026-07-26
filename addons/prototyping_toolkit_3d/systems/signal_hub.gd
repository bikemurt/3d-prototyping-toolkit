@tool
class_name ProtoSignalHub
extends Node

signal interact_hover_on(node: Node3D)
signal interact_hover_off
signal interact(source: Node3D, target: Node3D)

var last_is_colliding := false
