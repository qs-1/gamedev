extends Node2D
class_name Player

@export var rotation_speed: float = 7.0

func _ready():
	pass

func _process(delta):
	rotation += rotation_speed * delta
	position = get_global_mouse_position()
