extends Area2D

@export var points = 10
@export var color = Color.RED

func _ready():
	add_to_group("brick")
	$ColorRect.color = color
