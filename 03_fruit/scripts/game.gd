extends Node2D

var fruit_scene = preload("res://scenes/fruit.tscn")
var score = 0

func _ready():
	$Timer.wait_time = 1.0
	$Timer.timeout.connect(_on_spawn_timer_timeout)
	$Timer.start()

func _on_spawn_timer_timeout():
	var fruit = fruit_scene.instantiate()
	
	var screen_w = get_viewport_rect().size.x
	var random_x = randf_range(90, screen_w - 90)
	
	fruit.position = Vector2(random_x, -90)
	
	add_child(fruit)

func add_score():
	score += 1
	$ScoreLabel.text = "Score: " + str(score)
