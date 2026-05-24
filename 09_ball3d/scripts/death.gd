extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball") or body.name == "ball":
		GameManager.timer_reset()
		get_tree().call_deferred("reload_current_scene")
