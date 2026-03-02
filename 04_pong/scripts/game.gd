extends Node2D

var paddle_scene = preload("res://scenes/paddle.tscn")
var ball_scene = preload("res://scenes/ball.tscn")

var score_left = 0
var score_right = 0

@onready var screen = get_viewport_rect().size

func _ready() -> void:
	var fourth = screen.x / 4
	$UI/label_left.position.x = fourth 
	$UI/label_left.position.y = 10
	
	$UI/label_right.position.x = fourth * 3 
	$UI/label_right.position.y = 10 
	
	$UI/label_win.position.y = (screen.y / 2) - ($UI/label_win.size.y / 2)
	$UI/label_win.position.x = (screen.x / 2) - ($UI/label_win.size.x / 2)
	
	spawn_paddles()
	spawn_ball()

func spawn_paddles():
	var left_paddle = paddle_scene.instantiate()
	var right_paddle = paddle_scene.instantiate()
	var paddle_size = left_paddle.get_node("Sprite2D").texture.get_size()
	
	var paddle_w = paddle_size.x * left_paddle.get_node("Sprite2D").scale.x
	#var paddle_h = paddle_size.y * left_paddle.get_node("Sprite2D").scale.y
	
	left_paddle.position = Vector2(paddle_w * 2, screen.y / 2.0)
	left_paddle.UP = "self_up"
	left_paddle.DOWN = "self_down"
	
	right_paddle.position = Vector2(screen.x - (paddle_w * 2), screen.y / 2.0)
	right_paddle.UP = "enemy_up"
	right_paddle.DOWN = "enemy_down"
	right_paddle.is_ai = 1
	
	add_child(left_paddle)
	add_child(right_paddle)
	


func spawn_ball():
	var ball = ball_scene.instantiate() 

	# custom score signal
	ball.point_scored.connect(_on_score)
	
	ball.position = Vector2(screen.x / 2, screen.y / 2)
	add_child(ball)
	
func _on_score(side):
	$score.play()
	
	if side == "right":
		score_left += 1
	else:
		score_right += 1
	
	$UI/label_left.text = str(score_left)
	$UI/label_right.text = str(score_right)
		
	if score_left>=5 or score_right>=5:
		game_won()
	else:
		await get_tree().create_timer(1.0).timeout
		spawn_ball()

func game_won():
	if score_left > score_right:
		$UI/label_win.text = "Left Player Wins!\nPress Space to Restart"
	else:
		$UI/label_win.text = "Right Player Wins!\nPress Space to Restart"
	$UI/label_win.visible = true
	
func _input(event):
	if event.is_action_pressed("ui_accept") and $UI/label_win.visible:
		get_tree().reload_current_scene()


func _on_balls_timeout() -> void:
	spawn_ball()
