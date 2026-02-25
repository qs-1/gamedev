extends FallingObject

func _ready():
	super._ready()
	add_to_group("fruits")
	randomize_fruit()

func randomize_fruit():
	var type = randi()  % 3
	
	if type == 0:
		$Sprite2D.modulate = Color(1, 0, 0)
		score = 1
		speed = randf_range(200, 300)
	
	elif type == 1:
		$Sprite2D.modulate = Color(1, 0.8, 0)
		score = 3
		speed = randf_range(350, 500)
	
	else:
		$Sprite2D.modulate = Color(0, 1, 1)
		score = 5
		speed = randf_range(400, 600)
