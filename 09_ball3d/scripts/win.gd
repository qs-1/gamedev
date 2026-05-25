extends Area3D

@export_file("*.tscn") var next_level: String

@onready var win_ui = get_parent().get_node("win_ui")
@onready var overlay = get_parent().get_node("win_ui/ColorRect")
@onready var labels = get_parent().get_node("win_ui/labels")
@onready var score_label = get_parent().get_node("win_ui/labels/score")
@onready var tip_label = get_parent().get_node("win_ui/labels/tip")

var is_won = false

func _ready() -> void:
	overlay.modulate.a = 0.0
	labels.modulate.a = 0.0

func _process(delta: float) -> void:
	if is_won and next_level != "" and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file(next_level)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball") or body.name == "ball":
		body.get_node("win").play()
		
		if not body.win: 
			is_won = true
			GameManager.timer_running = false
			var mins = int(GameManager.elapsed_time / 60)
			var secs = int(GameManager.elapsed_time) % 60
			var time_str = "%02d:%02d" % [mins, secs]
			
			score_label.text = "Score: " + str(GameManager.score) + " | Time: " + time_str
			
			if next_level == "":
				tip_label.visible = false
			
			var tween = create_tween().set_parallel(true)
			win_ui.visible = true
			
			tween.tween_property(overlay, "modulate:a", 0.5, 2)
			tween.tween_property(labels, "modulate:a", 1.0, 2)
		
		body.win = true
