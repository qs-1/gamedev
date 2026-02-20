extends Area2D

var speed = 200

func _ready():
	add_to_group("fruits")
	
	$Sprite2D.modulate = Color(randf(), randf(), randf())
	speed = randf_range(200, 400)

func _process(delta):
	position.y += speed * delta
	
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()
