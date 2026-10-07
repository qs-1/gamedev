extends Area2D

var FLAP_STRENGTH = -250
var GRAVITY = 900
var MAX_FALL_SPEED = 400

var alive = true
var velocity = Vector2.ZERO

signal flapped

func _ready() -> void:
	add_to_group("bird")
	reset_pos()
	
func _process(delta: float) -> void:
	if not alive: return
	velocity.y += GRAVITY * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = FLAP_STRENGTH
		$AnimatedSprite2D.play("flap")
		flapped.emit()
		
	velocity.y = clamp(velocity.y, -MAX_FALL_SPEED, MAX_FALL_SPEED)
	position.y += velocity.y * delta
	
	rotation = clamp(velocity.y/MAX_FALL_SPEED, -0.5, 1)

func die():
	alive = false
	$AnimatedSprite2D.stop()
	
func reset():
	rotation = 0
	velocity = Vector2.ZERO
	reset_pos()
	alive = true

func reset_pos():
	position = Vector2(get_viewport_rect().size.x / 2.0, get_viewport_rect().size.y / 2.0)
	
	
