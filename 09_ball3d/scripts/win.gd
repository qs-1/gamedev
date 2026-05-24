extends Area3D

@export_file("*.tscn") var next_level: String

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball") or body.name == "ball":
		print("win")
		if next_level != "":
			get_tree().call_deferred("change_scene_to_file", next_level)
