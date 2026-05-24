extends Node

signal score_change(new_score)

var score:int = 0:
	set(value):
		score = value
		score_change.emit(value)

var elapsed_time:float = 0.0
var timer_running:bool = false

func timer_reset():
	elapsed_time = 0.0

func _process(delta: float) -> void:
	if timer_running: elapsed_time += delta
