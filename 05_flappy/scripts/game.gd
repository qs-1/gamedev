extends Node2D

var pipe_scene = preload("res://scenes/pipe.tscn")

var screen = null

const PIPE_MARGIN = 20
const MAX_PIPE_SHIFT = 150
const PIPE_GAP = 90
const PIPE_SPEED = 140
var last_pipe_y = 0

var curr_pipe_speed = PIPE_SPEED

var score = 0
var high_score = 0

enum state {MENU, COUNTDOWN, PLAYING, DYING, SCORE, PAUSED}
var current_state = state.MENU 



func _ready() -> void:
	screen = get_viewport_rect().size
	
	$sounds/music.play()
	
	$bird.area_entered.connect(_on_bird_area_entered)
	$bird.flapped.connect(_on_bird_flapped)
	
	await get_tree().process_frame # ensure labels exist
	
	$UI/ScoreLabel.position.x = (screen.x / 2.0) - ($UI/ScoreLabel.size.x/2.0)

	$UI/ReadyLabel.position.x = (screen.x / 2.0) - ($UI/ReadyLabel.size.x/2.0)
	$UI/ReadyLabel.position.y = (screen.y / 2.0) - ($UI/ReadyLabel.size.y / 2.0) - 50
	
	$UI/GameOverLabel.position.x = screen.x / 2.0 - ($UI/GameOverLabel.size.x / 2.0)
	$UI/GameOverLabel.position.y = (screen.y / 2.0) - ($UI/GameOverLabel.size.y / 2.0)
	
	#$ground.position.y = screen.y - ($ground/Sprite2D.texture.get_height()) / 2.0
	$ground.add_to_group('pipe')
	
	show_menu()



func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if current_state == state.PLAYING:
			pause_game()
		elif current_state == state.PAUSED:
			unpause_game()

	if current_state == state.MENU:
		if Input.is_action_just_pressed("ui_accept"):
			start_countdown()

	elif current_state == state.COUNTDOWN:
		pass # countdown handles itself

	elif current_state == state.PLAYING:
		pass # bird script handles flapping

	elif current_state == state.DYING:
		pass # frozen

	elif current_state == state.SCORE:
		if Input.is_action_just_pressed("ui_accept"):
			restart()



func pause_game():
	current_state = state.PAUSED
	$bird.alive = false
	$PipeSpawnTimer.paused = true
	$ground.set_process(false) 
	$bg.set_process(false)	
	get_tree().call_group("pipes", "set_process", false)
	$UI/ReadyLabel.text = "PAUSED"
	$UI/ReadyLabel.visible = true

func unpause_game():
	current_state = state.PLAYING
	$bird.alive = true
	$PipeSpawnTimer.paused = false
	$ground.set_process(true)
	$bg.set_process(true)
	get_tree().call_group("pipes", "set_process", true)
	$UI/ReadyLabel.visible = false

func _on_pause_button_pressed() -> void:
	if current_state == state.PLAYING:
		pause_game()
	elif current_state == state.PAUSED:
		unpause_game()



func _on_bird_flapped():
	$sounds/flap.play()



func show_menu():
	current_state = state.MENU
	$bird.alive = false
	$bird.visible = false
	$UI/PauseButton.visible = false
	$UI/ReadyLabel.text = "Flappy Bird"
	$UI/ReadyLabel.visible = true
	
	$UI/GameOverLabel.text = "Press Space"
	$UI/GameOverLabel.visible = true
	
	score = 0
	$UI/ScoreLabel.text = ""
	


func start_countdown():
	current_state = state.COUNTDOWN
	$UI/GameOverLabel.visible = false # hide 'press space'
	$UI/ReadyLabel.text = "3"
	$sounds/score.play()
	await get_tree().create_timer(0.5).timeout
	$UI/ReadyLabel.text = "2"
	$sounds/score.play()
	await get_tree().create_timer(0.5).timeout
	$UI/ReadyLabel.text = "1"
	$sounds/score.play()
	await get_tree().create_timer(0.5).timeout
	$UI/ReadyLabel.visible = false
	start_game()
	
	
	
func start_game():
	current_state = state.PLAYING
	score = 0
	curr_pipe_speed = PIPE_SPEED
	$ground.SCROLL_SPEED = curr_pipe_speed
	
	$bird.alive = true
	$bird.visible = true
	$UI/PauseButton.visible = true
	$UI/ScoreLabel.text = "0"
	
	_on_pipe_spawn_timer_timeout() # skip initial 2s wait
	
	$PipeSpawnTimer.start()



func restart():
	$UI/GameOverLabel.visible = false
	get_tree().call_group("pipes", "queue_free")
	$bird.reset()
	last_pipe_y = 0.0
	$bg.set_process(true)
	$ground.set_process(true)
	show_menu()



func game_over():
	$sounds/hit.play()
	$bird.die()
	$PipeSpawnTimer.stop()
	
	high_score = max(high_score, score)
	
	$bg.set_process(false)
	$ground.set_process(false)
	get_tree().call_group("pipes", "set_process", false)
	
	await get_tree().create_timer(0.7).timeout
	show_score_screen()



func show_score_screen():
	current_state = state.SCORE
	$UI/PauseButton.visible = false
	$UI/ReadyLabel.text = "You Lost!"
	$UI/ReadyLabel.visible = true
	$UI/GameOverLabel.text = "Score: " + str(score) + "\nBest: " + str(high_score) + "\nPress Space to play again!"
	$UI/GameOverLabel.visible = true



func _on_bird_area_entered(area):
	if area.is_in_group("pipe"):
		game_over()
	elif area.is_in_group("mid_pipe"):
		score += 1
		$UI/ScoreLabel.text = str(score)
		$sounds/score.play()
		area.queue_free()
		
		# increase difficulty
		if score % 5 == 0:
			curr_pipe_speed += 10
			$ground.SCROLL_SPEED = curr_pipe_speed
			$PipeSpawnTimer.wait_time = max(0.8, $PipeSpawnTimer.wait_time - 0.1)


func _on_pipe_spawn_timer_timeout() -> void:
	var ground = screen.y - $ground/g1.texture.get_height()
	
	var pipe = pipe_scene.instantiate()
	pipe.GAP = PIPE_GAP
	pipe.SPEED = curr_pipe_speed
	pipe.position.x = screen.x + 50
	
	var min_y = PIPE_MARGIN + (PIPE_GAP / 2.0)
	var max_y = ground - PIPE_MARGIN - (PIPE_GAP / 2.0)
	
	var rand_min_y
	var rand_max_y
	
	# If first pipe, place anywhere on screen
	if last_pipe_y == 0: 
		rand_min_y = min_y
		rand_max_y = max_y
	else: 
		rand_min_y = max(min_y, last_pipe_y - MAX_PIPE_SHIFT)
		rand_max_y = min(max_y, last_pipe_y + MAX_PIPE_SHIFT)
		
	pipe.position.y = randf_range(rand_min_y, rand_max_y)
	last_pipe_y = pipe.position.y
	
	pipe.add_to_group("pipes")
	add_child(pipe)
	
