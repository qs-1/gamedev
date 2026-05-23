extends Node2D

var blue_balloon_scene: PackedScene
var red_balloon_scene: PackedScene
var gold_balloon_scene: PackedScene
var particle_scene: PackedScene
var bomb_scene: PackedScene
var balloons: Array = []
var spawn_timer: Timer
var balloon_height: int = 32

var score: int = 0
var highscore: int = 0
const default_lives: int = 3
var lives: int = default_lives
var timeleft: float = 30.0
var speed_boost: float = 1.0

var state = false

var powerup_timer = 0

var combo_count: int = 0
var combo_timer: float = 0.0
const COMBO_WINDOW: float = 1.0

func save_to_file(content):
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_string(content)

func load_from_file():
	if FileAccess.file_exists("user://save_game.dat"):
		var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
		var content = file.get_as_text()
		return int(content)
	return 0
	
func play_pop_particles(pos: Vector2) -> void:
	var fx = particle_scene.instantiate()
	fx.global_position = pos
	add_child(fx)

	fx.restart()
	fx.emitting = true

	await get_tree().create_timer(0.8).timeout
	if is_instance_valid(fx):
		fx.queue_free()

func _ready():
	red_balloon_scene = load("res://scenes/RedBalloon.tscn")
	blue_balloon_scene = load("res://scenes/BlueBalloon.tscn")
	gold_balloon_scene = load("res://scenes/GoldBalloon.tscn")
	particle_scene = load("res://scenes/particles.tscn")
	bomb_scene = load("res://scenes/bomb.tscn")
	spawn_timer = $SpawnTimer
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)
	
	highscore = load_from_file()

	$HUD.visible = false
	$Player.visible = false
	show_menu(true)
	play_pop_particles(Vector2(-9999, -9999))

func show_menu(state):
	highscore = load_from_file()
	$menu/high.text = "highscore:" + " " + str(highscore)
	$menu.visible = state

func _on_play_pressed() -> void:
	state = true
	start_game(state)

func start_game(state):
	get_tree().paused = false
	$HUD/pause.visible = false
	var flip = not state
	show_menu(flip)
	
	for balloon in balloons:
		if is_instance_valid(balloon):
			balloon.queue_free()
	balloons.clear()
	
	score = 0
	highscore = load_from_file()
	lives = default_lives
	timeleft = 30.0
	speed_boost = 1.0

	powerup_timer = 0

	combo_count = 0
	combo_timer = 0.0

	$HUD.visible = state
	$Player.visible = state
	$Player.set_process(state)
	$Player.scale = Vector2(1,1)
	
	if state:
		spawn_timer.wait_time = 1.0 - (Autoloads.difficulty * 0.25)
		spawn_timer.start()
	else:
		spawn_timer.stop()

func _process(delta):
	if not state: return
	if lives > 0 and timeleft > 0:
		timeleft -= delta
		speed_boost += delta * 0.05 
		
		if combo_timer > 0:
			combo_timer -= delta
			if combo_timer <= 0:
				combo_count = 0

		if powerup_timer > 0:
			powerup_timer -= delta
			if powerup_timer <= 0:
				$Player.scale = Vector2(1,1)

	for balloon in balloons:
		if balloon.position.y + balloon_height / 2 < 0:
			balloon.remove = true

	for i in range(balloons.size() - 1, -1, -1):
		if balloons[i].remove:
			balloons[i].queue_free()
			balloons.remove_at(i)

	if lives > -1:
		_update_labels()

	if lives <= 0 or timeleft <= 0:
		$Player.set_process(false)
		spawn_timer.stop()
		$HUD.get_node("TimeLbl").text = "GAME OVER"
		for balloon in balloons:
			balloon.speed = 0
		if score > highscore:
			save_to_file(str(score))
		await get_tree().create_timer(3).timeout
		start_game(false)
		return

func _on_spawn_timer_timeout():
	var balloon_scenes = [blue_balloon_scene,red_balloon_scene]
	var scene_to_use
	var rand = randf()
	if rand < 0.8:
		scene_to_use = balloon_scenes[randi() % balloon_scenes.size()]
	elif rand < 0.9:
		scene_to_use = bomb_scene
	else:
		scene_to_use = gold_balloon_scene
	
	var balloon = scene_to_use.instantiate()
	balloon.position = Vector2(randf_range(0, get_viewport_rect().size.x), get_viewport_rect().size.y + balloon_height * 2)
	
	var diff_multiplier = 1.0 + (Autoloads.difficulty * 0.5)
	balloon.speed *= (speed_boost * diff_multiplier)
	
	add_child(balloon)
	balloons.append(balloon)

func add_score(points_to_add: int):
	combo_timer = COMBO_WINDOW
	combo_count += 1
	
	var multiplier = 1
	if combo_count >= 3:
		multiplier = 2
		
	score += (points_to_add * multiplier)

func apply_powerup():
	powerup_timer = 3
	$Player.scale = Vector2(2,2)

func _update_labels():
	var canvas = $HUD
	canvas.get_node("ScoreLbl").text = "Score: " + str(score)
	canvas.get_node("LivesLbl").text = "Lives: " + str(lives)
	canvas.get_node("TimeLbl").text = "Time: " + str(int(timeleft))

func pop_sound():
	$pop.play()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and state:
		pause_game()
		
func pause_game():
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	$HUD/pause.visible = is_paused
		
func _on_button_pressed() -> void:
	pause_game()
