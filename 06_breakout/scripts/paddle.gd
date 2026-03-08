extends Area2D

var speed = 300
var screen = null



func _ready() -> void:
	screen = get_viewport_rect().size
	add_to_group("paddle")
	var paddle_w = $ColorRect.size.x
	position.x = (screen.x / 2) - (paddle_w / 2)
	position.y = screen.y - 50



func _process(delta: float) -> void:
	var direction = 0
	if Input.is_action_pressed("ui_left"):
		direction = -1
	elif Input.is_action_pressed("ui_right"):
		direction = 1
	position.x += direction * speed * delta
	position.x = clamp(position.x, 0, screen.x - $ColorRect.size.x)
