extends Area3D

@export var points: int
signal scored(points)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "ball" or body.is_in_group("ball"):
		$CollisionShape3D.set_deferred("disabled", true)
		GameManager.score += points
		$pickup.play()
		
		var mat = $MeshInstance3D.get_active_material(0).duplicate()
		$MeshInstance3D.set_surface_override_material(0, mat)
		
		var tween = create_tween()
		tween.tween_method(func(a): mat.set_shader_parameter("alpha", a), 1.0, 0.0, 1)
		await tween.finished
		
		# In case the sound is longer than the visual fade, wait for it too
		if $pickup.playing:
			await $pickup.finished
			
		queue_free()
