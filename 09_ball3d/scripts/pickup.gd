extends Area3D

@export var points:int
signal scored(points)

func _process(delta: float) -> void:
	self.rotate_y(0.1)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "ball" or body.is_in_group("ball"):
		GameManager.score += points
		queue_free()
