extends Area2D

var FLAP_STRENGTH = -250
var GRAVITY = 800
var MAX_FALL_SPEED = 400

var alive = true
var velocity = Vector2.ZERO

func _ready() -> void:
	add_to_group("bird")
	
func _process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = FLAP_STRENGTH
		$flap.play()
	velocity.y = clamp(velocity.y, -MAX_FALL_SPEED, MAX_FALL_SPEED)
	position.y += velocity.y * delta
	
	rotation = clamp(velocity.y/MAX_FALL_SPEED, -0.5, 1)

func die():
	alive = false
func reset():
	rotation = 0
	position = Vector2(120, 144)
	velocity = Vector2.ZERO
	alive = true
