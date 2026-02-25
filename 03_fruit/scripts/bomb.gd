extends FallingObject

func _ready():
	super._ready()
	add_to_group("bombs")
	score = -3
	speed = 500
