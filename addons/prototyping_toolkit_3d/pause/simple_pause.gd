@tool
class_name ProtoSimplePause
extends CanvasLayer

@export_tool_button("Generate Nodes") var initialize_nodes := func() -> void:
	for c in get_children(): c.free()
	
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(400,400)
	panel.position = Vector2(50, 50)
	Proto.add_node(self, panel)
	
	var vbox := VBoxContainer.new()
	vbox.size = Vector2(400,400)
	Proto.add_node(panel, vbox)
	
	var label := Label.new()
	label.text = "Pause Menu"
	Proto.add_node(vbox, label)
	
	resume_button = Button.new()
	resume_button.text = "Resume"
	Proto.add_node(vbox, resume_button)
	
	quit_button = Button.new()
	quit_button.text = "Quit"
	Proto.add_node(vbox, quit_button)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	Proto.proto_print("Simple pause nodes configured")

@export var load_on_ready := true

@export var hidden_mouse_mode := Input.MOUSE_MODE_CAPTURED
@export var visible_mouse_mode := Input.MOUSE_MODE_VISIBLE

@export var resume_button: Button
@export var quit_button: Button

func _ready() -> void:
	if Engine.is_editor_hint():
		if load_on_ready:
			if get_child_count() == 0: initialize_nodes.call()
		
		set_process(false)
	else:
		hide()
		visibility_changed.connect(on_visibility_changed)
		resume_button.pressed.connect(func() -> void:
			visible = false
			Input.mouse_mode = hidden_mouse_mode
			)
		quit_button.pressed.connect(get_tree().quit)

func _process(_delta: float) -> void:
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
