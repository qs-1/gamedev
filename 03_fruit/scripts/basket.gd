extends Area2D

var speed_multiplier = 0.6
	
func _process(delta):
	var screen_w = get_viewport_rect().size.x
	var curr_speed = screen_w * speed_multiplier 
	var half_w = ($Sprite2D.texture.get_width() * $Sprite2D.scale.x) / 2
	
	if Input.is_action_pressed("ui_left"):
		position.x -= curr_speed * delta
	if Input.is_action_pressed("ui_right"):
		position.x += curr_speed * delta
		
	position.x = clamp(position.x, half_w + 5, screen_w - half_w - 5)


func _on_area_entered(area):
	if area is FallingObject:
		if area.is_in_group("powerups"):
			grow_basket()
		else:
			get_parent().add_score(area.score)
			if area.score < 0:
				get_parent().take_damage()
		area.queue_free()


func grow_basket():
	var tween = create_tween().set_parallel(true)
	tween.tween_property($CollisionShape2D.shape, "radius", $CollisionShape2D.shape.radius * 1.5, 0.3)
	tween.tween_property($Sprite2D, "scale", $Sprite2D.scale * 1.5, 0.3)
	
	await get_tree().create_timer(5.0).timeout
	
	if is_instance_valid(self): #if game starts again
		tween.tween_property($CollisionShape2D.shape, "radius", $CollisionShape2D.shape.radius / 1.5, 0.3)
		tween.tween_property($Sprite2D, "scale", $Sprite2D.scale / 1.5, 0.3)
	
