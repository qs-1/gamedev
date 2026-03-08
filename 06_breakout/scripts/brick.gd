extends Area2D

@export var hits_required = 1



func _ready() -> void:
	add_to_group("brick")
	$GPUParticles2D.emitting = true
	await get_tree().create_timer(0.2).timeout
	$GPUParticles2D.hide()



func got_hit():
	hits_required -= 1
	if hits_required <= 0:
		return true
	else:
		# darker on hit
		$ColorRect.color = $ColorRect.color.darkened(0.3)
		return false
