extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball") or body.name == "ball":
		GameManager.timer_reset()
		body.get_node("ded").play()
		
		if get_parent().has_method("reset_ball_pos"):
			get_parent().reset_ball_pos()
		else:
			await body.get_node("ded").finished
			get_tree().call_deferred("reload_current_scene")
