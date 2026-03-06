extends Area2D
var speed = 400

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		position.x = position.x - speed * delta
	if Input.is_action_pressed("ui_right"):
		position.x = position.x + speed * delta
	position.x = clamp(position.x, 50, 750)
