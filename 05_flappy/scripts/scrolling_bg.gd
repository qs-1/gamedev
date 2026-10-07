extends Node2D

var SCROLL_SPEED = 60

func _process(delta: float) -> void:
	for child in get_children():
		if child is Sprite2D:
			var bg_w = child.texture.get_width()
			child.position.x -= SCROLL_SPEED * delta
			if child.position.x <= -bg_w:
				child.position.x += 2 * bg_w
