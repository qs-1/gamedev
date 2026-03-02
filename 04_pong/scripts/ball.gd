extends Area2D

signal point_scored(side)

var SPEED = 350
var direction = Vector2.ZERO

func _ready() -> void:
	add_to_group("ball")
	
	var directions = [Vector2(1,1),
					Vector2(-1,-1),
					Vector2(-1,1),
					Vector2(1,-1)]
		
	direction = directions.pick_random().normalized()


func _process(delta: float) -> void:
	var screen = get_viewport_rect().size
	var half_ball = ($Sprite2D.texture.get_size().x * $Sprite2D.scale.x) / 2
	
	# ball speed
	position += SPEED * delta * direction
	
	# bounce off walls
	if position.y >= screen.y - half_ball:
		direction = direction.bounce(Vector2.UP)
	elif position.y <= half_ball:
		direction = direction.bounce(Vector2.DOWN)

	# point scored
	if position.x >= screen.x:
		point_scored.emit("right")
		queue_free()
	elif position.x <= 0:
		point_scored.emit("left")
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("paddle"): 
		# increase ball speed on hit
		SPEED = min(SPEED * 1.05, 800)
		
		direction.x *= -1 # reflecc
		
		position.x += sign(direction.x) * 10 # nudge
		
		# vary bounce angle based on distance from center of paddle
		var paddle_half_height = area.get_node('Sprite2D').texture.get_size().y / 2
		var offset = (position.y - area.position.y)/ paddle_half_height # is now -1 to 1
		direction.y = offset
		direction.y *= 0.9 # make y smaller so it moves mostly in x
		direction = direction.normalized()
		get_parent().get_node("hit").play()
	
		#screen shake
		var cam = get_parent().get_node("cam")
		var xshake = randf_range(3.0, 6.0) * [-1,1].pick_random()
		var yshake = randf_range(3.0, 6.0) * [-1,1].pick_random()
		
		cam.offset = Vector2(xshake, yshake)

		var tween = get_tree().create_tween()
		tween.tween_property(cam, "offset", Vector2.ZERO, 0.1)
