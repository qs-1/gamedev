extends Area2D

var direction = Vector2.ZERO
var default_speed = 200
var speed = default_speed
var paddle_w = null

signal hit_brick
signal lost_life(ball)

var screen = null



func _ready() -> void:
	add_to_group("ball")
	screen = get_viewport_rect().size
	reset()



func reset():
	direction = [Vector2(-0.5, -0.5), Vector2(0.5, -0.5)].pick_random()
	position = Vector2(400,400)
	speed = default_speed
	if has_node("trail"):
		$trail.global_position = global_position



func _process(delta: float) -> void:
	position += direction * speed * delta

	if position.x < 0 or position.x > screen.x - $ColorRect.size.x:
		direction.x *= -1
		position.x = clamp(position.x, 0, screen.x - $ColorRect.size.x)
	
	if position.y < 0:
		direction.y *= -1
		position.y = 0
	
	if position.y > get_viewport_rect().size.y + 50:
		lost_life.emit(self)
		
	var tween = create_tween()
	tween.tween_property($trail, "global_position", global_position, 0.1)



func _on_area_entered(area: Area2D) -> void:
	get_parent().get_node("hit").play()
	
	if area.is_in_group("paddle"):
		direction.y = -abs(direction.y)
		
		var paddle = area
		paddle_w = paddle.get_node("ColorRect").size.x
		var angle = (position.x - paddle.position.x) / (paddle_w / 2) 
		direction.x = angle * 0.8
		direction = direction.normalized()
	
		speed = min(speed*1.1, 500)
	
	elif area.is_in_group("brick"):
		hit_brick.emit(area) 
		direction.y = -direction.y
