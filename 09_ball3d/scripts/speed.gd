extends Area3D

var active = true

func _on_body_entered(body):
	if body.name == "ball":
		active = false
		body.apply_central_impulse(body.linear_velocity.normalized() * 25.0)
		await get_tree().create_timer(1.5).timeout
		active = true
