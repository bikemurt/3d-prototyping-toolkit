@tool
class_name ProtoInputSetup
extends Node

## Reload the project to see the changes to the input bindings
@export var reload_required := false

@export_category("Config")
@export var load_on_ready := true

@export_category("Add All Inputs")
@export_tool_button("Add All Inputs") var add_all_inputs := func() -> void:
	add_wasd.call()
	add_joystick_look.call()
	add_jump.call()
	add_pause.call()
	add_interact.call()

@export_category("Add Inputs")
@export_tool_button("Add WASD Inputs") var add_wasd := func() -> void:
	add_button_binding("forward", "ui_up", KEY_W)
	add_button_binding("back", "ui_down", KEY_S)
	add_button_binding("left", "ui_left", KEY_A)
	add_button_binding("right", "ui_right", KEY_D)
	wasd_added = true
	Proto.proto_print("WASD inputs configured")

@export_tool_button("Add Joystick Look Binding") var add_joystick_look := func() -> void:
	add_axis_binding("look_left", "ui_right", JoyAxis.JOY_AXIS_RIGHT_X, -1.0)
	add_axis_binding("look_right", "ui_right", JoyAxis.JOY_AXIS_RIGHT_X, +1.0)
	add_axis_binding("look_down", "ui_right", JoyAxis.JOY_AXIS_RIGHT_Y, -1.0)
	add_axis_binding("look_up", "ui_right", JoyAxis.JOY_AXIS_RIGHT_Y, +1.0)
	joystick_look_added = true
	Proto.proto_print("Joystick look (right joystick) configured")

@export_tool_button("Add Jump Binding") var add_jump := func() -> void:
	add_button_binding("jump", "ui_select", KEY_SPACE, true, JOY_BUTTON_A)
	jump_added = true
	Proto.proto_print("Jump input configured")

@export_tool_button("Add Pause Binding") var add_pause := func() -> void:
	add_button_binding("pause", "ui_select", KEY_ESCAPE, true, JOY_BUTTON_START)
	pause_added = true
	Proto.proto_print("Pause input configured")

@export_tool_button("Add Interact Binding") var add_interact := func() -> void:
	add_button_binding("interact", "ui_select", KEY_E, true, JOY_BUTTON_X)
	pause_added = true
	Proto.proto_print("Interact input configured")

@export_category("Input Status")
@export var wasd_added := false
@export var joystick_look_added := false
@export var jump_added := false
@export var pause_added := false

func _ready() -> void:
	if Engine.is_editor_hint():
		reload_required = false
		
		wasd_added = has_bindings(["left", "right", "forward", "back"])
		pause_added = has_bindings(["pause"])
		joystick_look_added = has_bindings(["look_left", "look_right", "look_up", "look_down"])
		
		if load_on_ready and not wasd_added:
			add_all_inputs.call()


func has_bindings(bindings: Array[String]) -> bool:
	for binding in bindings:
		if not ProjectSettings.has_setting("input/" + str(binding)): return false
	
	return true

func add_button_binding(new_action: String, copy_from: String, keycode: Key, use_custom_joy_binding := false, joy_binding := JOY_BUTTON_A) -> void:
	var dict: Dictionary = ProjectSettings.get_setting("input/" + copy_from).duplicate_deep()
	for key in dict:
		if key == "events":
			for event in dict.events:
				if event is InputEventKey:
					event.keycode = keycode
				if use_custom_joy_binding and event is InputEventJoypadButton:
					event.button_index = joy_binding

	dict.deadzone = 0.1
	ProjectSettings.set_setting("input/" + new_action, dict)
	ProjectSettings.save()
	
	reload_required = true

func add_axis_binding(new_action: String, copy_from: String, joy_axis := JoyAxis.JOY_AXIS_LEFT_X, joy_axis_value := -1.0) -> void:
	var dict: Dictionary = ProjectSettings.get_setting("input/" + copy_from).duplicate_deep()
	for key in dict:
		if key == "events":
			var delete := []
			for event in dict.events:
				if event is InputEventKey or event is InputEventJoypadButton:
					delete.push_back(event)
				if event is InputEventJoypadMotion:
					event.axis = joy_axis
					event.axis_value = joy_axis_value
			
			for event in delete:
				dict.events.erase(event)
	
	dict.deadzone = 0.1
	ProjectSettings.set_setting("input/" + new_action, dict)
	ProjectSettings.save()
	
	reload_required = true
