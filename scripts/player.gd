extends Node2D


var speed = 300.0
var timer = 0
@onready var sprite_w_half = $Sprite2D.texture.get_width() / 2
@onready var sprite_h_half = $Sprite2D.texture.get_height() / 2


func _process(delta: float) -> void:
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1 
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1 
		
	if direction.length() > 0:
		direction = direction.normalized()
	
	var temp_speed = speed
	if Input.is_action_pressed("sprint"):
		temp_speed *= 2
		
	position += direction * temp_speed * delta


	# # wrapping
	var screen = get_viewport_rect().size
	
	if position.x > screen.x + (sprite_w_half):
		position.x = -(sprite_w_half)
	elif position.x < -(sprite_w_half):
		position.x = screen.x + (sprite_w_half)
	if position.y > screen.y + (sprite_h_half):
		position.y = -(sprite_h_half)
	elif position.y < -(sprite_h_half):
		position.y = screen.y + (sprite_h_half)


	# # clamping
	#var screen_size = get_viewport_rect().size
	#position.x = clamp(position.x, sprite_w_half, screen_size.x - sprite_w_half)
	#position.y = clamp(position.y, sprite_h_half, screen_size.y - sprite_h_half)
