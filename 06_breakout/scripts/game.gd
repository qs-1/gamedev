extends Node2D

var screen_size = Vector2.ZERO

var brick_scene = preload("res://scenes/brick.tscn")
var powerup_scene = preload("res://scenes/powerup.tscn")
var ball_scene = preload("res://scenes/ball.tscn")

var score = 0
var lives = 3
var current_level = 1

enum GameState {START, PLAYING, GAMEOVER}
var current_state = GameState.START



func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	$score.text = "Score: 0"
	$lives.text = "Lives: 3"
	
	$start.position.x = (screen_size.x / 2) - ($start.size.x / 2)
	$start.position.y = (screen_size.y / 2) - ($start.size.y / 2)
	$start.visible = true
	
	spawn_bricks()



func spawn_ball():
	var new_ball = ball_scene.instantiate()
	new_ball.hit_brick.connect(add_score)
	new_ball.lost_life.connect(lost_life)
	add_child(new_ball)
	return new_ball



func spawn_bricks():
	var temp_brick = brick_scene.instantiate()
	var brick_w = temp_brick.get_node("ColorRect").size.x
	var brick_h = temp_brick.get_node("ColorRect").size.y
	temp_brick.queue_free()

	var margin_x = 50 
	var start_y = 80 
	var space_x = 20 
	var space_y = 20 
	var brick_and_space_x = brick_w + space_x
	var brick_and_space_y = brick_h + space_y
	var rows = min(current_level, 5) 
	
	var max_usable_width = screen_size.x - (margin_x * 2)
	var cols = int(max_usable_width / brick_and_space_x)
	
	var total_grid_width = (cols * brick_w) + ((cols - 1) * space_x)
	var start_x = (screen_size.x - total_grid_width) / 2
	
	for row in range(rows):
		for col in range(cols):
			var brick = brick_scene.instantiate()
			brick.position.x = (col * brick_and_space_x) + start_x
			brick.position.y = (row * brick_and_space_y) + start_y
			
			if current_level >= 2 and row == 0:
				brick.hits_required = 2 
				brick.get_node("ColorRect").color = Color.DARK_RED
			else:
				brick.get_node("ColorRect").color = Color(randf(), randf(), randf())
			add_child(brick)



func add_score(brick):
	if brick.got_hit() == true: # destroyed brick
		score += 20
		brick.queue_free()
		$score.text = "Score: " + str(score)

		if randf()<0.1:
			var powerup = powerup_scene.instantiate()
			powerup.position = brick.position
			call_deferred("add_child",powerup)

		if get_tree().get_nodes_in_group("brick").size() <= 1:
			current_level += 1

			for p in get_tree().get_nodes_in_group("powerup"):
				p.queue_free()
			for b in get_tree().get_nodes_in_group("ball"):
				b.queue_free()

			await get_tree().create_timer(1).timeout
			spawn_bricks()
			spawn_ball()



func gain_powerup(type):
	if type == 0: # paddle wide
		var rect = $paddle.get_node("ColorRect")
		var shape = $paddle.get_node("CollisionShape2D")
		rect.size.x = 120
		shape.shape.size.x = 120
		shape.position.x = 60
		$PaddleTimer.start(5)

	elif type == 1: # +1 life
		lives += 1
		$lives.text = "Lives: " + str(lives)
		
	elif type == 2: # extra ball
		var new_ball = spawn_ball()
		new_ball.position = $paddle.position - Vector2(0, 30)


func lost_life(ball_node):
	ball_node.queue_free()
	# 1 since del after this frmae ends
	if get_tree().get_nodes_in_group("ball").size() <= 1:
		lives -= 1
		$lives.text = "Lives: " + str(lives)
		
		if lives < 1:
			game_over()
		else:
			spawn_ball()



func game_over():
	$gameover.text = "Game over!\n Score: " + str(score)
	$gameover.position.x = (screen_size.x / 2) - ($gameover.size.x / 2)
	$gameover.position.y = (screen_size.y / 2) - ($gameover.size.y / 2)
	$gameover.visible = true
	set_process(false)
	
	for b in get_tree().get_nodes_in_group("ball"):
		b.queue_free()
	for p in get_tree().get_nodes_in_group("powerups"):
		p.queue_free()

	current_state = GameState.GAMEOVER


func _input(event):
	if current_state == GameState.START:
		if Input.is_action_just_pressed("ui_accept"):
			start_game()
	
	elif current_state == GameState.GAMEOVER:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()

func start_game():
	current_state = GameState.PLAYING
	$start.visible = false
	$gameover.visible = false
	spawn_ball()



func _on_paddle_timer_timeout() -> void:
	var rect = $paddle.get_node("ColorRect")
	var shape = $paddle.get_node("CollisionShape2D")
	rect.size.x = 60
	shape.shape.size.x = 60
	shape.position.x = 30
