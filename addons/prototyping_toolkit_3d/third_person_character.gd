@tool
class_name ProtoThirdPersonCharacter
extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 4.5
@export var sens_x := -0.07
@export var sens_y := -0.07
@export var joypad_sens_x := -0.07
@export var joypad_sens_y := -0.07

@export var capture_mouse := true

@export var load_on_ready := true

@export var camera_3d: Camera3D
@export var spring_arm: SpringArm3D
@export var mesh_instance: MeshInstance3D

@export_tool_button("Initialize Nodes") var initialize_nodes := func() -> void:
	spring_arm = SpringArm3D.new()
	spring_arm.name = "SpringArm3D"
	spring_arm.position.y = 1.0
	spring_arm.spring_length = 3.0
	spring_arm.rotation_degrees.x = -20.0
	add_child(spring_arm)
	spring_arm.owner = get_tree().edited_scene_root
	
	camera_3d = Camera3D.new()
	camera_3d.name = "Camera3D"
	spring_arm.add_child(camera_3d)
	
	camera_3d.owner = get_tree().edited_scene_root
	
	var collision_shape_3d := CollisionShape3D.new()
	collision_shape_3d.name = "CollisionShape3D"
	
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	
	collision_shape_3d.shape = shape
	add_child(collision_shape_3d)
	collision_shape_3d.owner = get_tree().edited_scene_root
	
	mesh_instance = MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = capsule
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.BLUE_VIOLET
	mesh_instance.set_surface_override_material(0, mat)
	add_child(mesh_instance)
	mesh_instance.owner = get_tree().edited_scene_root
	
	var mesh_instance_2 := mesh_instance.duplicate()
	mesh_instance_2.name = "MeshInstance3D"
	mesh_instance_2.scale = Vector3.ONE * 0.3
	mesh_instance_2.rotation_degrees.z = 90.0
	mesh_instance_2.position = Vector3(0,0.4,-0.4)
	var mat_2 := StandardMaterial3D.new()
	mat_2.albedo_color = Color.GREEN
	mesh_instance_2.set_surface_override_material(0, mat_2)
	mesh_instance.add_child(mesh_instance_2)
	mesh_instance_2.owner = get_tree().edited_scene_root
	
	position.y = 0.9
	
	Proto.proto_print("Third person character controller nodes configured")
	
@export_tool_button("Clear Child Nodes") var clear_child_nodes := func() -> void:
	for c in get_children(): c.free()
	camera_3d = null

var wasd_controls := false
var joystick_look_controls := false
var jump_controls := false

func _ready() -> void:
	if Engine.is_editor_hint():
		if load_on_ready:
			if get_child_count() == 0: initialize_nodes.call()
	else:
		wasd_controls = InputMap.has_action(&"left") and InputMap.has_action(&"right") and InputMap.has_action(&"forward") and InputMap.has_action(&"back")
		joystick_look_controls = InputMap.has_action(&"look_left") and InputMap.has_action(&"look_right") \
			and InputMap.has_action(&"look_up") and InputMap.has_action(&"look_down")
		
		jump_controls = InputMap.has_action(&"jump")
		
		if capture_mouse: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event is InputEventMouseMotion:
		pivot_camera(event.relative.x, event.relative.y, sens_x, sens_y)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
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
	
	var b := Basis(Vector3.UP, camera_3d.global_rotation.y)
	var direction := (b * Vector3(input_dir.x, 0, input_dir.y))
	if direction:
		mesh_instance.global_rotation.y = lerp_angle(mesh_instance.global_rotation.y, atan2(direction.x, direction.z) + PI, 0.15)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()

func pivot_camera(relative_x: float, relative_y: float, _sens_x: float, _sens_y: float, factor := 100.0) -> void:
	spring_arm.rotation.x += _sens_y * relative_y / factor
	spring_arm.rotation.y += _sens_x * relative_x / factor
