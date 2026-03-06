extends Area2D

signal scored(points)
signal life_lost()

var velocity = Vector2.ZERO
var speed = 400
var start_speed = 400

func _ready():
	area_entered.connect(_on_area_entered)
	reset()

func reset():
	position = Vector2(400, 500)
	var direction = Vector2(randf_range(-0.5, 0.5), -1)
	velocity = direction.normalized() * speed
	speed = start_speed

func _process(delta):
	position = position + velocity * delta

	if position.y < 10:
		velocity.y = -velocity.y
		position.y = 11

	if position.x < 10 or position.x > 790:
		velocity.x = -velocity.x

	if position.y > 600:
		life_lost.emit()
		reset()

func _on_area_entered(area):
	if area.is_in_group("brick"):
		area.queue_free()
		velocity.y = -velocity.y
		scored.emit(area.points)
	
	else:
		#paddle bounce angle
		
		var paddle = area
		var paddle_width = paddle.get_node("ColorRect").size.x
		var offset = (position.x - paddle.position.x) / (paddle_width / 2.0)
		
		velocity.y = -abs(velocity.y)
		velocity.x = offset * speed * 0.5
		velocity = velocity.normalized() * speed
