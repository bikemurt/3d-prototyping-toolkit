@tool
class_name ProtoFirstPersonCharacter
extends CharacterBody3D

@export_tool_button("Generate Nodes") var initialize_nodes := func() -> void:
	if not Engine.is_editor_hint(): return
	for c in get_children(): c.free()
	
	camera_3d = Camera3D.new()
	camera_3d.position = Vector3(0,0.726,-0.12)
	Proto.add_node(self, camera_3d)
	
	if interactable_raycast:
		raycast = RayCast3D.new()
		raycast.target_position = Vector3(0,0,-raycast_length)
		raycast.collide_with_areas = true
		raycast.collide_with_bodies = false
		Proto.add_node(camera_3d, raycast)
	
	var collision_shape_3d := CollisionShape3D.new()
	
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	
	collision_shape_3d.shape = shape
	Proto.add_node(self, collision_shape_3d)
	
	position.y = 0.9
	
	Proto.proto_print("First person character controller nodes configured")
	
	if interactable_raycast:
		var signal_hub_exists := false
		for c in get_parent().get_children():
			if c.name == "ProtoSignalHub":
				signal_hub_exists = true
				break
		
		if not signal_hub_exists:
			var signal_hub := ProtoSignalHub.new()
			Proto.add_node(get_parent(), signal_hub, "ProtoSignalHub")

@export_category("Config")
@export var load_on_ready := true

## Interactable Raycasts requiire the ProtoSignalHub component
@export var interactable_raycast := true:
	set(value):
		interactable_raycast = value
		initialize_nodes.call()
	get:
		return interactable_raycast

@export var raycast_length := 2.0:
	set(value):
		raycast_length = value
		initialize_nodes.call()
	get:
		return raycast_length

@export_category("Character Settings")
@export var speed := 5.0
@export var jump_velocity := 4.5
@export var sens_x := -0.07
@export var sens_y := -0.07
@export var joypad_sens_x := -0.07
@export var joypad_sens_y := -0.07

@export_category("Mouse Behaviour")
@export var capture_mouse := true

@export_category("Node References")
@export var camera_3d: Camera3D
@export var raycast: RayCast3D

var wasd_controls := false
var joystick_look_controls := false
var jump_controls := false
var last_is_colliding := false
var interact_controls := false

func _ready() -> void:
	if Engine.is_editor_hint():
		if load_on_ready:
			if get_child_count() == 0: initialize_nodes.call()
		
		set_process(false)
		set_process_input(false)
		set_physics_process(false)
	else:
		wasd_controls = InputMap.has_action(&"left") and InputMap.has_action(&"right") and InputMap.has_action(&"forward") and InputMap.has_action(&"back")
		joystick_look_controls = InputMap.has_action(&"look_left") and InputMap.has_action(&"look_right") \
			and InputMap.has_action(&"look_up") and InputMap.has_action(&"look_down")
		
		jump_controls = InputMap.has_action(&"jump")
		interact_controls = InputMap.has_action(&"interact")
		
		if capture_mouse: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pivot_camera(event.relative.x, event.relative.y, sens_x, sens_y)

func _process(_delta: float) -> void:
	if interactable_raycast and raycast:
		var is_colliding := raycast.is_colliding()
		var collider := raycast.get_collider()
		if is_colliding != last_is_colliding:
			if Proto.signal_hub:
				if is_colliding:
					Proto.signal_hub.interact_hover_on.emit(collider)
				else:
					Proto.signal_hub.interact_hover_off.emit()
			
			last_is_colliding = is_colliding
		
		if is_colliding and interact_controls and \
			interactable_raycast and \
			Input.is_action_just_pressed(&"interact"):
			Proto.signal_hub.interact.emit(collider)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var jump_action := Input.is_action_just_pressed(&"ui_accept") or (jump_controls and Input.is_action_just_pressed(&"jump"))
	if jump_action and is_on_floor():
		velocity.y = jump_velocity
	
	var input_dir := Vector2.ZERO
	if wasd_controls:
		input_dir = Input.get_vector(&"left", &"right", &"forward", &"back")
	else:
		input_dir = Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	
	if joystick_look_controls:
		var look_right := Input.get_axis(&"look_left", &"look_right")
		var look_up := Input.get_axis(&"look_down", &"look_up")
		# fyi the last factor is a fudge factor to make the joypad feel similar to mouse at the same sens
		pivot_camera(look_right, look_up, joypad_sens_x, joypad_sens_y, 2.0)
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()

func pivot_camera(relative_x: float, relative_y: float, _sens_x: float, _sens_y: float, factor := 100.0) -> void:
	rotation.y += _sens_x * relative_x / factor
	camera_3d.rotation.x += _sens_y * relative_y / factor
