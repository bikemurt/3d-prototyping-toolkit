@tool
class_name ProtoCrosshair
extends Control

enum CrossHairMode { NONE, INTERACTABLE }

@export var crosshair_mode := CrossHairMode.INTERACTABLE
@export var on_color := Color(0,1,0,0.5)
@export var off_color := Color(1,0,0,0.5)
@export var radius := 3.0

var interact_hover := false

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(false)
		return
	
	queue_redraw()
	if Proto.signal_hub:
		Proto.signal_hub.interact_hover_on.connect(on_interact_hover_on)
		Proto.signal_hub.interact_hover_off.connect(on_interact_hover_off)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var _color := on_color
	
	if crosshair_mode == CrossHairMode.INTERACTABLE:
		if interact_hover: _color = on_color
		else: _color = off_color
	
	draw_circle(get_viewport_rect().size / 2.0, radius, _color)

func on_interact_hover_on(_node: Node) -> void:
	interact_hover = true
	queue_redraw()

func on_interact_hover_off() -> void:
	interact_hover = false
	queue_redraw()
