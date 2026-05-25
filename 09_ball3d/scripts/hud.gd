extends CanvasLayer

const Confetti = preload("res://scenes/confetti_particles.tscn")

func _ready():
	GameManager.score_change.connect(_update_score)

func _update_score(new_score: int):
	$Score.text = "Score: " + str(new_score)

func play_confetti(pos: Vector2, count: int = 40, val: float = 1.0):
	var c = Confetti.instantiate()
	c.global_position = pos
	c.amount = count
	c.scale = Vector2(val, val)
	add_child(c)

func play_shower():
	var sz = get_viewport().get_visible_rect().size
	for i in 5:
		var x = (sz.x / 6.0) * (i + 1) + randf_range(-40.0, 40.0)
		play_confetti(Vector2(x, -20), 80, 1.2)
		await get_tree().create_timer(0.18).timeout

func _process(delta):
	$Time.text = hr_min_time(GameManager.elapsed_time)

func hr_min_time(time):
	return "%02d:%02d" % [int(time/60), int(time)%60]
