extends Area2D

var speed = 200
var type = 0



func _ready():
	add_to_group("powerup")
	type = randi() % 3
	if type == 0:
		$ColorRect.color = Color.BLUE
	elif type == 1:
		$ColorRect.color = Color.GREEN
	else:
		$ColorRect.color = Color.YELLOW



func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 10:
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("paddle"):
		get_parent().call_deferred("gain_powerup",type)
		queue_free()
