extends Area2D

# 1. Note: We use 'area', not 'body', because it's an Area2D collision
func _on_area_entered(area):
	# 2. 'area' is the "hitbox" node. We get its PARENT to find the "player" node.
	var parent_node = area.get_parent()
	
	# 3. Now checking the parent (which is the Node2D named 'player')
	if parent_node.name == "player":
		GameManager.add_score(1)
		queue_free()
