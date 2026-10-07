extends CharacterBody3D

var sens = 0.004
const DEFAULT_SPEED := 8.0
const SPRINT_SPEED := 14.0
var CURR_SPEED := DEFAULT_SPEED
const JUMP_VELOCITY = 10
var fall_velocity = 0
@onready var cam = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var gridmap = get_parent().get_node("GridMap")
@onready var break_timer: Timer = $BreakTimer
@onready var light = $OmniLight3D
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

func save_game():
	var save_data = {
		"player" : {
			"px": global_position.x,
			"py": global_position.y,
			"pz": global_position.z,
			"hp": health, "hunger": hunger, "stamina": sprint,
			"index": index, "amount": amount
		},
		"world":[]
	}

	for cell in gridmap.get_used_cells():
		save_data["world"].append({"x": cell.x, "y": cell.y, "z": cell.z, "id": gridmap.get_cell_item(cell)})

	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("saved.")

func load_game():
	if not FileAccess.file_exists("user://savegame.json"):
		print("No save found!")
		return
		
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	var p = save_data["player"]
	global_position = Vector3(p["px"], p["py"], p["pz"])
	health = p["hp"]
	hunger = p["hunger"]
	sprint = p["stamina"]
	
	index = int(p["index"])
	amount.clear()
	for count in p["amount"]:
		amount.append(int(count))
	update_labels()
	
	gridmap.clear()
	for cell in save_data["world"]:
		gridmap.set_cell_item(Vector3i(int(cell["x"]), int(cell["y"]), int(cell["z"])), int(cell["id"]))
	print("game loaded.")

func _on_btn_save_pressed() -> void:
	save_game()

func _on_btn_load_pressed() -> void:
	load_game()
	$UI/PauseMenu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

func _on_btn_quit_pressed() -> void:
	get_tree().quit()

func setup_terrain() -> void:
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.015
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.fractal_lacunarity = 1.5
	noise.fractal_gain = 0.4
	
	for x in range(-128, 128):
		for z in range(-128, 128):
			var noise_val = noise.get_noise_2d(x, z)
			var target_y = int((noise_val + 1.0) * 3.0)
			
			for y in range(0, target_y):
				var block_id = 2
				if y == target_y - 1:
					block_id = 5
				elif y > target_y - 4:
					block_id = 3
					
				gridmap.set_cell_item(Vector3i(x, y, z), block_id)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	spawn_position = global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
	style.content_margin_left = 20
	style.content_margin_top = 10
	style.content_margin_right = 10
	style.content_margin_bottom = 10
	$UI/blocks.add_theme_stylebox_override("normal", style)
	
	update_labels()
	setup_terrain()
	
	$UI/tip.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property($UI/tip, "modulate:a", 1.0, 0.25)
	tween.tween_interval(5.0)
	tween.tween_property($UI/tip, "modulate:a", 0.0, 0.25)


func respawn() -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	health = 100.0
	hunger = 100.0
	sprint = 10.0
	update_labels()

func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
		fall_velocity = min(fall_velocity, velocity.y)

	if is_on_floor():
		if -fall_velocity>20: health-=10
		
		fall_velocity = 0
		
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("w", "e", "n", "s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if sprint <= 0.0:
		is_exhausted = true
	elif sprint >= 3.0:
		is_exhausted = false

	if Input.is_action_pressed("sprint") and not is_exhausted and direction != Vector3.ZERO:
		sprint -= delta * 0.5
		CURR_SPEED = SPRINT_SPEED
	else:
		sprint += delta * 3.0
		CURR_SPEED = DEFAULT_SPEED
	
	sprint = clamp(sprint, 0.0, 10.0)

	if direction:
		velocity.x = direction.x * CURR_SPEED
		velocity.z = direction.z * CURR_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, CURR_SPEED)
		velocity.z = move_toward(velocity.z, 0, CURR_SPEED)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
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

	if global_position.y < -50.0 or health < 1:
		respawn()

	update_labels()
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var menu = $UI/PauseMenu
		menu.visible = !menu.visible
		if menu.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
			
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * sens)
			cam.rotate_x(-event.relative.y * sens)
			cam.rotation.x = clamp(cam.rotation.x, -PI/2, PI/2)
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_C:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				
		if event.keycode == KEY_L:
			light.visible = !light.visible

		for i in range(7):
			if event.keycode == KEY_1 + i:
				index = i
				update_labels()
				break_timer.stop()

		if event.keycode == KEY_E:
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
	var text_ui = "[color=lightcoral]HEALTH:[/color] " + str(int(health)) + "  |  [color=khaki]HUNGER:[/color] " + str(int(hunger)) + "  |  [color=lightskyblue]STAMINA:[/color] " + str(int(sprint * 10)) + "\n"
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
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return
		
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
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
