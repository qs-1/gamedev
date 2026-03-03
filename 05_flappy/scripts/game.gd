extends Node2D

var pipe_scene = preload("res://scenes/pipe.tscn")

const PIPE_MARGIN = 20
const MAX_PIPE_SHIFT = 60
const PIPE_GAP = 80
const GROUND_HEIGHT = 8

var last_pipe_y = 0
var score = 0

func _ready() -> void:
	$PipeSpawnTimer.start()
	$bird.area_entered.connect(_on_bird_area_entered)

func _on_bird_area_entered(area):
	if area.is_in_group("pipe"):
		game_over()
	elif area.is_in_group("mid_pipe"):
		score += 1
		print(score)
		area.queue_free()

func game_over():
	print("dead  ")
	$bird.die()
	$PipeSpawnTimer.stop()
	$bg.set_process(false)
	get_tree().call_group("pipes", "set_process", false)

func _on_pipe_spawn_timer_timeout() -> void:
	var screen = get_viewport_rect().size
	var half_height = screen.y/2
	var ground = screen.y - GROUND_HEIGHT 
	
	var pipe = pipe_scene.instantiate()
	pipe.GAP = PIPE_GAP
	pipe.position.x = screen.x + 50
	
	var min_y = -(half_height) + PIPE_MARGIN + (PIPE_GAP/2.0)
	var max_y = ground - PIPE_MARGIN - (PIPE_GAP/2.0)
	
	var rand_min_y = max(min_y, last_pipe_y - MAX_PIPE_SHIFT)
	var rand_max_y = min(max_y, last_pipe_y + MAX_PIPE_SHIFT)
	
	pipe.position.y = randf_range(rand_min_y, rand_max_y)
	last_pipe_y = pipe.position.y
	
	pipe.add_to_group("pipes")
	add_child(pipe)
	
	
