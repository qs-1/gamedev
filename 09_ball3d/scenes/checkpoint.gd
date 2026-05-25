extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.name == "ball" and get_parent().spawn_pos != position:
		$check.play()
		var mat = $MeshInstance3D.get_active_material(0)
		mat.set_shader_parameter("bubble_color", Color(0.0, 0.769, 0.043, 1.0))
		get_parent().spawn_pos = position
