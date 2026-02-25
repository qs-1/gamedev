extends Area2D

var speed = 200
var score = 1

func _ready():
	add_to_group("fruits")
	
func fruit_type(type):
	if type == 0:
		$Sprite2D.modulate = Color(1, 0, 0)
		score = 1
		speed = randf_range(200, 300)
	elif type == 1:
		$Sprite2D.modulate = Color(1, 0.8, 0)
		score = 3
		speed = randf_range(350, 500)
	elif type == 2:
		$Sprite2D.modulate = Color(0, 1, 1)
		score = 5
		speed = randf_range(400, 600)

func _process(delta):
	position.y += speed * delta
	
	if position.y > get_viewport_rect().size.y + 100:
		get_parent().take_damage()
		queue_free()
