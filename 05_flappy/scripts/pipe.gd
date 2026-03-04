extends Node2D

var SPEED = 60
var GAP = 80

func _ready() -> void:
	$top_pipe.add_to_group("pipe")
	$bottom_pipe.add_to_group("pipe")
	$mid_pipe.add_to_group("mid_pipe")
	
	var pipe_height = $bottom_pipe/Sprite2D.texture.get_height()

	$top_pipe.position.y = -(GAP / 2.0) - (pipe_height / 2.0)
	$top_pipe.rotation = PI
	$top_pipe/CollisionShape2D.shape.size = $top_pipe/Sprite2D.texture.get_size()

	$bottom_pipe.position.y = (GAP / 2.0) + (pipe_height / 2.0)
	$bottom_pipe/CollisionShape2D.shape.size = $bottom_pipe/Sprite2D.texture.get_size()

	$mid_pipe.position.y = 0 # default
	$mid_pipe/CollisionShape2D.shape.size.x = 30
	$mid_pipe/CollisionShape2D.shape.size.y = GAP
	
func _process(delta: float) -> void:
	position.x -= SPEED * delta
	if position.x <= -100:
		queue_free()
