extends Area2D

@export var SPEED = 300
@export var DOWN = "" 
@export var UP = "" 
@export var is_ai = 0

var ball = 0

func _ready() -> void:
	add_to_group("paddle")

func _process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	# make ai go for the nearest ball if there are multiple
	var balls = get_tree().get_nodes_in_group("ball")
	
	var closest_ball = null
	var closest_dist = INF

	for b in balls:
		var curr_dist = abs(position.x - b.position.x)
		if curr_dist < closest_dist:
			closest_dist = curr_dist
			closest_ball = b

	if is_ai and closest_ball:
		var step = SPEED * delta
		var distance = closest_ball.position.y - position.y
		
		# if overshooting with speed, jus teleport to closest_balls y pos
		if abs(distance) <= step: 
			position.y = closest_ball.position.y
		else:
			position.y += step * sign(distance)
			
		#or jus do
		#position.y = move_toward(position.y, closest_ball.position.y, SPEED * delta)
	
	else:
		if Input.is_action_pressed(UP):
			direction.y -= 1
		if Input.is_action_pressed(DOWN):
			direction.y += 1
		position.y += delta * SPEED * direction.y
	
	var screen = get_viewport_rect()
	var half_paddle_h = $Sprite2D.texture.get_size().y / 2.0
	position.y = clamp(position.y, half_paddle_h, screen.size.y - half_paddle_h)
	
