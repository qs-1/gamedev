extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.score_change.connect(_update_score)

func _update_score(new_score: int):
	$Score.text = "Score: "+  str(new_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Time.text = hr_min_time(GameManager.elapsed_time)

func hr_min_time(time):
	var mins = int(time/60)
	var secs = int(time)%60
	return "%02d:%02d" % [mins, secs]
	
