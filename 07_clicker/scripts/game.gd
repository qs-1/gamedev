extends Node2D

var screen = Vector2.ZERO

# cooki stuff
const SCALE_NORMAL = Vector2(3.0, 3.0)
const SCALE_HOVER = Vector2(4.0, 4.0)
const SCALE_POP = Vector2(2.0, 2.0)
const TOLERANCE = 10 # click dist tolerance
var hovered_cookie = null 

var actual_score = 0
var display_score = 0:
	set(value):
		display_score = value
		if is_inside_tree():
			$Label.text = "Score: %d" % display_score

func _ready() -> void:
	screen = get_viewport_rect().size
	
	var custom_font = load("res://assets/Minecraft.ttf")
	$Label.add_theme_font_override("font", custom_font)
	$Label.text = "Score: %d" % display_score
	$Label.add_theme_font_size_override("font_size", 22)
	
	$Label.position = Vector2(30, 30)

func _on_spawn_timer_timeout() -> void:
	var sprite = Sprite2D.new()
	sprite.position = Vector2(randf_range(100, screen.x-100), randf_range(100, screen.y-100))
	
	sprite.texture = load("res://assets/cookie_sheet.png")
	sprite.hframes = 3
	sprite.frame = randi() % 3
	
	sprite.scale = Vector2.ZERO
	add_child(sprite)
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", SCALE_NORMAL, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mousepos = get_global_mouse_position()
		var all_cookies = get_children()
		all_cookies.reverse()
		
		var hovered = null
		
		for cookie in all_cookies:
			if cookie is Sprite2D and not cookie.has_meta("popping"): #only check non explodin cookies
				var width = cookie.texture.get_width() / float(cookie.hframes)
				var radius = ((width / 2.0) * SCALE_NORMAL.x) + TOLERANCE
				
				if cookie.position.distance_to(mousepos) <= radius:
					hovered = cookie
					break
		
		if hovered_cookie != hovered: # current different from old hovered
			#reset old hovered cookie if there was one
			if hovered_cookie != null and is_instance_valid(hovered_cookie) and not hovered_cookie.has_meta("popping"):
				var tween = create_tween()
				tween.tween_property(hovered_cookie, "scale", SCALE_NORMAL, 0.1)
			
			#hover effect for new cookie 
			if hovered != null:
				var tween = create_tween()
				tween.tween_property(hovered, "scale", SCALE_HOVER, 0.1).set_trans(Tween.TRANS_BOUNCE)
			
			hovered_cookie = hovered #update with current cookie which is being hovered over

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if hovered_cookie != null and is_instance_valid(hovered_cookie) and not hovered_cookie.has_meta("popping"):
			clicked_cookie(hovered_cookie)
			hovered_cookie = null

func clicked_cookie(cookie):
	cookie.set_meta("popping", true) # so we dont delete it again as its disappearin
	
	var points = 0
	if cookie.frame == 0:
		points = 100
	elif cookie.frame == 1:
		points = 250
	elif cookie.frame == 2:
		points = 500
		
	actual_score += points
	var score_tween = create_tween()
	score_tween.tween_property(self, "display_score", actual_score, 0.5)
	
	spawn_floating_text(cookie.position, points)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(cookie, "scale", SCALE_POP, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cookie, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cookie, "rotation", TAU, 0.3).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	cookie.queue_free()

func spawn_floating_text(spawn_pos, points):
	var float_label = Label.new()
	float_label.text = "+%d" % points
	
	var custom_font = load("res://assets/Minecraft.ttf")
	float_label.add_theme_font_override("font", custom_font)
	float_label.add_theme_font_size_override("font_size", 18)
	
	float_label.position = spawn_pos + Vector2(20, -10)
	add_child(float_label)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(float_label, "position", float_label.position + Vector2(0, -50), 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(float_label, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	float_label.queue_free()
