extends Area2D

func _on_area_entered(area):
	if area.get_parent().name == "player":
		GameManager.add_score(1)
		queue_free()
