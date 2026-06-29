@tool
class_name ProtoSimplePause
extends CanvasLayer

@export var load_on_ready := true

@export var hidden_mouse_mode := Input.MOUSE_MODE_CAPTURED
@export var visible_mouse_mode := Input.MOUSE_MODE_VISIBLE

@export var resume_button: Button
@export var quit_button: Button

@export_tool_button("Initialize Nodes") var initialize_nodes := func() -> void:
	var panel := Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(400,400)
	panel.position = Vector2(50, 50)
	add_child(panel)
	panel.owner = get_tree().edited_scene_root
	
	var vbox := VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.size = Vector2(400,400)
	panel.add_child(vbox)
	vbox.owner = get_tree().edited_scene_root
	
	var label := Label.new()
	label.name = "Label"
	label.text = "Pause Menu"
	vbox.add_child(label)
	label.owner = get_tree().edited_scene_root
	
	resume_button = Button.new()
	resume_button.name = "ResumeButton"
	resume_button.text = "Resume"
	
	vbox.add_child(resume_button)
	resume_button.owner = get_tree().edited_scene_root
	
	quit_button = Button.new()
	quit_button.name = "QuitButton"
	quit_button.text = "Quit"
	vbox.add_child(quit_button)
	quit_button.owner = get_tree().edited_scene_root
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	Proto.proto_print("Simple pause nodes configured")

@export_tool_button("Clear Child Nodes") var clear_child_nodes := func() -> void:
	for c in get_children(): c.free()

func _ready() -> void:
	if Engine.is_editor_hint():
		if load_on_ready:
			if get_child_count() == 0: initialize_nodes.call()
	else:
		hide()
		visibility_changed.connect(on_visibility_changed)
		resume_button.pressed.connect(func() -> void:
			visible = false
			Input.mouse_mode = hidden_mouse_mode
			)
		quit_button.pressed.connect(get_tree().quit)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if InputMap.has_action(&"pause"):
		if Input.is_action_just_pressed(&"pause"):
			visible = not visible
	
func on_visibility_changed() -> void:
	if visible:
		get_tree().paused = true
		Input.mouse_mode = visible_mouse_mode
	else:
		get_tree().paused = false
		Input.mouse_mode = hidden_mouse_mode
