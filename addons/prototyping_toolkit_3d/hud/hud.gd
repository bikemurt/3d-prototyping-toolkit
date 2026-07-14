@tool
class_name ProtoHUD
extends CanvasLayer

@export_tool_button("Generate Nodes") var initialize_nodes := func() -> void:
	for c in get_children(): c.free()
	
	if crosshair:
		var crosshair_node := ProtoCrosshair.new()
		Proto.add_node(self, crosshair_node, "ProtoCrosshair")
	
	if use_interact_label:
		interact_label = Label.new()
		interact_label.text = "[E] Interact"
		interact_label.position = get_viewport().get_visible_rect().size / 2.0
		interact_label.add_theme_color_override(&"font_outline_color", Color.BLACK)
		interact_label.add_theme_constant_override(&"outline_size", 4)
		Proto.add_node(self, interact_label)
	
	layer = 10

@export var load_on_ready := true
@export var crosshair := true
@export var use_interact_label := true

@export var interact_label: Label

func _ready() -> void:
	if Engine.is_editor_hint():
		if load_on_ready:
			if get_child_count() == 0: initialize_nodes.call()
		return
	
	if interact_label: interact_label.hide()
	if Proto.signal_hub:
		Proto.signal_hub.interact_hover_on.connect(on_interact_hover_on)
		Proto.signal_hub.interact_hover_off.connect(on_interact_hover_off)

func on_interact_hover_on(_node: Node) -> void:
	if interact_label: interact_label.show()

func on_interact_hover_off() -> void:
	if interact_label: interact_label.hide()
