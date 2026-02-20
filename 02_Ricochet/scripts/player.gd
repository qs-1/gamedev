extends Node2D
var SPEED = 200
var timer = 0
var direction = Vector2.ZERO

func _ready() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _process(delta: float) -> void:
	var screen = get_viewport_rect().size
	var sprite_w = $Sprite2D.get_rect().size.x * $Sprite2D.scale.x
	var sprite_h = $Sprite2D.get_rect().size.y * $Sprite2D.scale.y
	#direction.y += 0.8 * delta
	position += direction * SPEED * delta
	
	var wrapped = false
	var half_w = sprite_w/2
	var half_h = sprite_h/2
	if position.x > screen.x + half_w:
		position.x = -half_w
		wrapped = true
	elif position.x < -half_w:
		position.x = screen.x + half_w
		wrapped = true
		
	if position.y > screen.y + half_h:
		position.y = -half_h
		wrapped = true
	elif position.y < -half_h:
		position.y = screen.y + half_h
		wrapped = true

	if wrapped:
		$Sprite2D.modulate = Color(randf(), randf(), randf())
	
	
	#var reflect = false
	
	#if position.x > screen.x - sprite_w/2:
		#direction.x *= -1
		#position.x = screen.x - sprite_w/2
		#reflect = true
	#if position.x < sprite_w/2:
		#direction.x *= -1
		#position.x = sprite_w/2
		#reflect = true
#
	#if position.y > screen.y - sprite_h/2:
		#direction.y *= -1
		#position.y = screen.y - sprite_h/2
		#reflect = true
	#if position.y < sprite_h/2:
		#direction.y *= -1
		#position.y = sprite_h/2
		#reflect = true
		#
	#if reflect:
		#$Sprite2D.modulate = Color(randf(),randf(),randf())
		#SPEED += 50
		#SPEED = min(SPEED,500)
		
		
	timer += delta
	if timer >= 0.1:
		make_trail()
		timer = 0
	

func make_trail():
	var trail = Sprite2D.new()
	trail.position = global_position
	trail.texture = $Sprite2D.texture
	trail.scale = $Sprite2D.scale
	
	trail.modulate = $Sprite2D.modulate
	trail.modulate.a = 0.5
	
	get_parent().add_child(trail)
	#get_parent().move_child(trail, 0)
	
	var tween = create_tween()
	tween.tween_property(trail, "modulate:a", 0 , 0.5)
	
	tween.tween_callback(trail.queue_free)
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	var other = area.get_parent() 
	var reflect_vector = (position - other.position).normalized() 
	direction = direction.bounce(reflect_vector)
