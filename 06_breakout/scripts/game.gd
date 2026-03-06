extends Node2D

var score = 0
var lives = 3
var brick_container: Node
var screen = null

func _ready():
	screen = get_viewport_rect().size
	brick_container = Node.new()
	brick_container.name = "BrickContainer"
	add_child(brick_container)
	
	$ball.scored.connect(_on_ball_scored)
	$ball.life_lost.connect(_on_ball_life_lost)
	
	$GameOverLabel.position.x = (screen.x / 2) - ($GameOverLabel.size.x / 2)
	$GameOverLabel.position.y = (screen.y / 2) - ($GameOverLabel.size.y / 2)
	
	spawn_bricks()
	
func spawn_bricks():
	var brick_scene = preload("res://scenes/brick.tscn")
	var rows = 5
	var cols = 8
	var start_x = 100
	var start_y = 50
	var spacing_x = 80
	var spacing_y = 30
	var colors = [
		Color.RED,
		Color.ORANGE,
		Color.YELLOW,
		Color.GREEN,
		Color.BLUE
	]
	
	for row in range(rows):
		for col in range(cols):
			var brick = brick_scene.instantiate()
			brick.position = Vector2(
				start_x + col * spacing_x,
				start_y + row * spacing_y
			)
			brick.color = colors[row]
			brick_container.add_child(brick) 

func _on_ball_scored(points):
	score = score + points
	$ScoreLabel.text = "Score: " + str(score)
	
	if brick_container.get_child_count() == 0:
		win_game()
		
func win_game():
	$ball.set_process(false)
	$ball.visible = false
	$GameOverLabel.text = "YOU WIN!\nScore: " + str(score)
	$GameOverLabel.visible = true

func _on_ball_life_lost():
	lives = lives - 1
	$LivesLabel.text = "Lives: " + str(lives)
	if lives <= 0:
		game_over()
		
func game_over():
	$ball.set_process(false)
	$ball.visible = false
	$GameOverLabel.text = "GAME OVER\nScore: " + str(score)
	$GameOverLabel.visible = true
