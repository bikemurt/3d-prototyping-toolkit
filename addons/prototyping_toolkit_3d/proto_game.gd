extends Node

var signal_hub: ProtoSignalHub

func _ready() -> void:
	signal_hub = ProtoSignalHub.new() 
	add_child(signal_hub)
