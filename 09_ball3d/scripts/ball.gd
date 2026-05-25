extends RigidBody3D

@export var rolling_force: float = 20.0
@export var jump_impulse: float = 25.0
@export var camera_smoothing: float = 0.1
@export var mouse_sensitivity: float = 0.002

@onready var camera_rig: Node3D = $camrig
@onready var camera: Node3D = $camrig/Camera3D
@onready var floor_check: RayCast3D = $RayCast3D

var mouse_cap = false
var win = false

func _ready() -> void:
	camera_rig.set_as_top_level(true)
	floor_check.set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_cap = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not win:
		camera_rig.rotate_y(-event.relative.x * mouse_sensitivity)
	if event.is_action_pressed("ui_cancel"):
		if mouse_cap:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_cap = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_cap = true

func _physics_process(delta: float) -> void:
	if win:
		camera_rig.rotate_y(0.01)
		camera.position = camera.position.lerp(Vector3(0, 6, 8), 1 * delta)
		return
	
	# Step 1: Ask the camera rig "where is forward / right?"
	var cam_forward: Vector3 = -camera_rig.global_basis.z
	cam_forward.y = 0.0
	cam_forward = cam_forward.normalized()

	var cam_right: Vector3 = camera_rig.global_basis.x
	cam_right.y = 0.0
	cam_right = cam_right.normalized()

	# Step 2: Build a movement direction from WASD
	var move_dir := Vector3.ZERO
	if Input.is_action_pressed("forward"):
		move_dir += cam_forward
	if Input.is_action_pressed("back"):
		move_dir -= cam_forward
	if Input.is_action_pressed("left"):
		move_dir -= cam_right
	if Input.is_action_pressed("right"):
		move_dir += cam_right

	# Step 3: Convert that direction into a spin axis
	if move_dir.length() > 0.0:
		move_dir = move_dir.normalized()
		var spin_axis: Vector3 = Vector3.UP.cross(move_dir)
		angular_velocity += spin_axis * rolling_force * delta

	floor_check.global_position = global_position
	camera_rig.global_position = camera_rig.global_position.lerp(global_position, camera_smoothing)

	if Input.is_action_just_pressed("jump") and floor_check.is_colliding():
		apply_impulse(Vector3.UP * jump_impulse)
		$jump.play()
