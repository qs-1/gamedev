extends Node2D

var fruit_scene = preload("res://scenes/fruit.tscn")
var bomb_scene = preload("res://scenes/bomb.tscn")
var powerup_scene = preload("res://scenes/powerup.tscn")

var is_game_over = false

var score = 0
var misses = 0
var lives = 3

func _ready():
	var screen = get_viewport_rect().size
	
	$basket.position = Vector2(screen.x / 2, screen.y - 70)
	
	$GameOverLabel.visible = false
	$GameOverLabel.position = screen / 2
	$GameOverLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$GameOverLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	$ScoreLabel.text = "Score: 0"
	$MissLabel.text = "Misses: 0"
	$LivesLabel.text = "Lives: 3"
	
	$SpawnTimer.wait_time = 1.0
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
	$SpawnTimer.start()
	
	$DifficultyTimer.wait_time = 10.0
	$DifficultyTimer.timeout.connect(_on_difficulty_timer_timeout)
	$DifficultyTimer.start()
	
	$PowerupTimer.wait_time = 15.0
	$PowerupTimer.timeout.connect(_on_powerup_timer_timeout)
	$PowerupTimer.start()

func _process(_delta):
	if is_game_over:
		if Input.is_key_pressed(KEY_R):
			get_tree().reload_current_scene()

func get_random_spawn_x():
	var screen_w = get_viewport_rect().size.x
	var padding = screen_w * 0.1
	return randf_range(padding, screen_w - padding)

func _on_powerup_timer_timeout():
	if is_game_over:
		return
	
	var powerup = powerup_scene.instantiate()
	powerup.position = Vector2(get_random_spawn_x(), -90)
	add_child(powerup)

func _on_spawn_timer_timeout():
	if is_game_over:
		return
		
	var spawn_falling_obj
	var dice = randf() * 100
	if dice < 25:
		spawn_falling_obj = bomb_scene.instantiate()
	else:
		spawn_falling_obj = fruit_scene.instantiate()
		
	spawn_falling_obj.position = Vector2(get_random_spawn_x(), -90)
	add_child(spawn_falling_obj)

func _on_difficulty_timer_timeout():
	if $SpawnTimer.wait_time > 0.3:
		$SpawnTimer.wait_time -= 0.1

func add_score(amount):
	score += amount
	score = max(score, 0)
	$ScoreLabel.text = "Score: " + str(score)

func add_miss():
	misses += 1
	$MissLabel.text = "Misses: " + str(misses)

func game_over():
	is_game_over = true
	get_tree().call_group("falling_objects", "queue_free")
	$SpawnTimer.stop()
	$DifficultyTimer.stop()
	$PowerupTimer.stop()
	$GameOverLabel.visible = true

func take_damage():
	if is_game_over:
		return
	lives -= 1
	$LivesLabel.text = "Lives: " + str(lives)
	if lives <= 0:
		game_over()
