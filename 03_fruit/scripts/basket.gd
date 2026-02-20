extends Area2D

var speed = 400

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		position.x -= speed * delta
	if Input.is_action_pressed("ui_right"):
		position.x += speed * delta
		
	var screen_w = get_viewport_rect().size.x
	var half_w = ($Sprite2D.texture.get_width() * $Sprite2D.scale.x) / 2
	
	position.x = clamp(position.x, half_w, screen_w - half_w)

func _on_area_entered(area):
	if area.is_in_group("fruits"):
		area.queue_free()
		get_parent().add_score()
