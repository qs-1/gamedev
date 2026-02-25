extends FallingObject

func _ready():
	super._ready()
	add_to_group("powerups")
	speed = 400
