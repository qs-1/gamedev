extends Area2D
class_name FallingObject

var speed = 0
var score = 0

func _ready():
	add_to_group("falling_objects")

func _process(delta):
	position.y += speed * delta

	if position.y > get_viewport_rect().size.y + 100:
		if score > 0: 
			get_parent().add_miss() # missed fruit
		queue_free()
