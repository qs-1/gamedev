extends Node2D

var popped: bool = false
var remove: bool = false
@export var points : int = 1
@export var speed: float = 100.0

func _ready():
	var area = $Area2D
	area.connect("area_entered", _on_collision)
	area.connect("body_entered", _on_collision)

func _on_collision(body):
	var parent = body.get_parent()
	if parent is Player:
		if not popped:
			get_parent().pop_sound()
			
			var sprite = $AnimatedSprite2D
			sprite.play("pop")
			sprite.connect("animation_finished", _on_animation_finished)
			if points<0:
				get_parent().lives-=1
				speed=0
			popped = true

			############################
			# Add points to score:
			get_parent().add_score(points)
			
			# make le big
			if self.is_in_group("powerup"):
				get_parent().apply_powerup()
				
			#pop
			if points>0:
				get_parent().play_pop_particles(self.global_position)
			############################
			
			

			############################
			# the 1 popup animated, add to MAIN SCENE
			var popup = Label.new()
			popup.text = "+" + str(points)
			popup.global_position = self.global_position
			get_parent().add_child(popup)
			var tween = get_parent().create_tween()
			tween.set_parallel(true)
			tween.tween_property(popup, "position", Vector2(global_position.x, global_position.y - 30), 0.5)
			tween.tween_property(popup, "modulate:a", 0, 0.5)
			tween.chain().tween_callback(popup.queue_free)
			############################




func _on_animation_finished():
	remove = true

func _process(delta):
	position += Vector2(0, -speed * delta)
	if popped:
		pass
