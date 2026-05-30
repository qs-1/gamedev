extends CharacterBody3D

var sens = 0.004
const DEFAULT_SPEED := 8.0
const SPRINT_SPEED := 14.0
var CURR_SPEED := DEFAULT_SPEED
const JUMP_VELOCITY = 10
@onready var cam = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var gridmap = get_parent().get_node("GridMap")
@onready var break_timer: Timer = $BreakTimer
var collider
var curr_gridmap_target
var index: int = 0
const blocks := ["Planks", "Wood", "Stone", "Dirt", "Bricks", "Grass", "Leaves"]
var amount: Array[int] = [64, 64, 64, 64, 64, 64, 64]
var health = 100.0
var hunger = 100.0
var sprint = 10.0
var is_exhausted: bool = false
var spawn_position: Vector3







var noise: FastNoiseLite
func setup_terrain() -> void:
	noise = FastNoiseLite.new()
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.02
	
	for x in range(-64, 64):
		for z in range(-64, 64):
			var noise_val = noise.get_noise_2d(x, z)
			var target_y = int((noise_val + 1.0) * 4.0)
			
			for y in range(0, target_y):
				var block_id = 2
				if y == target_y - 1:
					block_id = 5
				elif y > target_y - 4:
					block_id = 3
					
				gridmap.set_cell_item(Vector3i(x, y, z), block_id)










func _ready() -> void:
	spawn_position = global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_labels()
	setup_terrain()

func respawn() -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	health = 100.0
	hunger = 100.0
	sprint = 10.0
	update_labels()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if not is_on_floor():
		velocity += get_gravity() * 2 * delta

	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("w", "e", "n", "s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if sprint <= 0.0:
		is_exhausted = true
	elif sprint >= 3.0:
		is_exhausted = false

	if Input.is_action_pressed("sprint") and not is_exhausted and direction != Vector3.ZERO:
		sprint -= delta * 1.0
		CURR_SPEED = SPRINT_SPEED
	else:
		sprint += delta * 3
		CURR_SPEED = DEFAULT_SPEED
	
	sprint = clamp(sprint, 0.0, 10.0)

	if direction:
		velocity.x = direction.x * CURR_SPEED
		velocity.z = direction.z * CURR_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, CURR_SPEED)
		velocity.z = move_toward(velocity.z, 0, CURR_SPEED)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if raycast.is_colliding():
			var curr_col = raycast.get_collider()
			if curr_col is GridMap:
				var curr_pos = raycast.get_collision_point() - raycast.get_collision_normal() * 0.1
				var curr_grid_target = curr_col.local_to_map(curr_pos)
				if curr_grid_target != curr_gridmap_target or break_timer.is_stopped():
					collider = curr_col
					curr_gridmap_target = curr_grid_target
					break_timer.start()
			else:
				break_timer.stop()
		else:
			break_timer.stop()
	else:
		if not break_timer.is_stopped():
			break_timer.stop()

	hunger -= 0.2 * delta
	if hunger <= 0:
		hunger = 0
		health -= 0.5 * delta
		if health <= 0:
			respawn()

	if global_position.y < -50.0:
		respawn()

	update_labels()
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sens)
		cam.rotate_x(-event.relative.y * sens)
		cam.rotation.x = clamp(cam.rotation.x, -PI/2, PI/2)
		
	if event is InputEventKey and event.pressed:
		for i in range(7):
			if event.keycode == KEY_1 + i:
				index = i
				update_labels()
				break_timer.stop()

	if event is InputEventKey and event.keycode == KEY_E and event.pressed:
		if index == 6 and amount[index] > 0:
			amount[index] -= 1
			hunger = min(hunger + 20.0, 100.0)
			update_labels()

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			index = wrapi(index - 1, 0, blocks.size())
			update_labels()
			break_timer.stop()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			index = wrapi(index + 1, 0, blocks.size())
			update_labels()
			break_timer.stop()

func update_labels():
	var text_ui = "[color=lightcoral]HEALTH:[/color] " + str(int(health)) + "  |  [color=khaki]HUNGER:[/color] " + str(int(hunger)) + "  |  [color=lightskyblue]STAMINA:[/color] " + str(int(sprint * 10)) + "\n\n"
	for i in range(blocks.size()):
		if i == index:
			text_ui += "[b][color=white]> " + blocks[i] + " : " + str(amount[i]) + " <[/color][/b]   "
		else:
			text_ui += "[color=lightgray]" + blocks[i] + " : " + str(amount[i]) + "[/color]   "
	$UI/blocks.text = text_ui

func pos_to_grid(p):
	return gridmap.local_to_map(p)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if raycast.is_colliding():
			var hit_point = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()
			if event.button_index == MOUSE_BUTTON_RIGHT:
				var place_pos = hit_point + (normal * 0.1)
				if amount[index] > 0:
					gridmap.set_cell_item(pos_to_grid(place_pos), index)
					amount[index] -= 1
					update_labels()

func _on_break_timer_timeout() -> void:
	if collider and collider is GridMap:
		var block_id = collider.get_cell_item(curr_gridmap_target)
		if block_id != -1:
			amount[block_id] += 1
			collider.set_cell_item(curr_gridmap_target, -1)
			update_labels()
