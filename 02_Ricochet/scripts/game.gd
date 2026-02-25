extends Node2D

var player_scene = preload("res://prefabs/player.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			#spawn limit
			if get_tree().get_nodes_in_group("player").size() < 10:
				var new_player = player_scene.instantiate()
				new_player.position = event.position
				add_child(new_player)
