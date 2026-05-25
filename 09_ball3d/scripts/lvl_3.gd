extends Node3D

var spawn_pos 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_pos = $ball.position

func reset_ball():
	$ball.position = spawn_pos
	$ball.linear_velocity = Vector3.ZERO
	$ball.angular_velocity = Vector3.ZERO
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
