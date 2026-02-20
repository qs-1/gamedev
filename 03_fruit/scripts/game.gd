extends Node2D

var fruit_scene = preload("res://scenes/fruit.tscn")
var score = 0
var lives = 3
var is_game_over = false

func _ready():
	$Timer.wait_time = 1.0
	$Timer.timeout.connect(_on_spawn_timer_timeout)
	$Timer.start()
	
	$DifficultyTimer.wait_time = 10.0
	$DifficultyTimer.timeout.connect(_on_difficulty_timer_timeout)
	$DifficultyTimer.start()

func _process(delta):
	if is_game_over:
		if Input.is_key_pressed(KEY_R):
			get_tree().reload_current_scene()

func _on_spawn_timer_timeout():
	if is_game_over:
		return

	var fruit = fruit_scene.instantiate()
	
	var screen_w = get_viewport_rect().size.x
	var random_x = randf_range(90, screen_w - 90)
	
	fruit.position = Vector2(random_x, -90)
	
	add_child(fruit)

func _on_difficulty_timer_timeout():
	if $Timer.wait_time > 0.3:
		$Timer.wait_time -= 0.1

func add_score():
	score += 1
	$ScoreLabel.text = "Score: " + str(score)

func game_over():
	is_game_over = true
	$Timer.stop()
	$GameOverLabel.visible = true

func take_damage():
	if is_game_over:
		return
	lives -= 1
	$MissLabel.text = "Lives: " + str(lives)
	if lives <= 0:
		game_over()
