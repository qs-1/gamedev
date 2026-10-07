extends CPUParticles2D

func _ready():
	emitting = true
	await get_tree().create_timer(lifetime + 1.0).timeout
	queue_free()
