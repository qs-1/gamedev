extends Node2D

enum GameState { MENU, PLAYING, GAMEOVER }
var current_state = GameState.MENU

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


var high_score = 0
var total_popped = 0
var total_time_played = 0.0

var pop_sounds = []



func _ready() -> void:
	screen = get_viewport_rect().size
	
	pop_sounds = [
		load("res://assets/hit1.wav"),
		load("res://assets/hit2.wav"),
		load("res://assets/hit3.wav"),
		load("res://assets/hit4.wav")]
	
	var custom_font = load("res://assets/Minecraft.ttf")
	
	$Label.add_theme_font_override("font", custom_font)
	$Label.text = "Score: %d" % display_score
	$Label.add_theme_font_size_override("font_size", 22)
	$Label.position = Vector2(30, 30)
	
	$TimeLabel.add_theme_font_override("font", custom_font)
	$TimeLabel.add_theme_font_size_override("font_size", 22)
	$TimeLabel.text = "Time: 30"
	$TimeLabel.position = Vector2(screen.x - $TimeLabel.size.x - 75, 30)
	
	$StartButton.add_theme_font_override("font", custom_font)
	$StartButton.add_theme_font_size_override("font_size", 32)
	$StartButton.size = Vector2(250, 60)
	$StartButton.position = Vector2((screen.x / 2.0) - ($StartButton.size.x / 2.0), (screen.y / 2.0) - ($StartButton.size.y / 2.0))
	$StartButton.modulate = Color(1.3, 1.3, 1.3)
	
	
	
	$StatsLabel.add_theme_font_override("font", custom_font)
	$StatsLabel.add_theme_font_size_override("font_size", 18)
	
	$StatsLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	
	$StatsLabel.text = "High Score: %d\nTotal Popped: %d\nTime Played: %d s" % [high_score, total_popped, int(total_time_played)]
	$StatsLabel.size.x = screen.x
	$StatsLabel.position = Vector2(0, (screen.y / 2.0) + 50)
	
	
	
	$SpawnTimer.stop()
	$StartButton.show()
	$StatsLabel.show()



func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		total_time_played += delta
		$TimeLabel.text = "Time: %d" % ceil($RoundTimer.time_left)



func _on_spawn_timer_timeout() -> void:
	if current_state != GameState.PLAYING:
		return
		
	var sprite = Sprite2D.new()
	sprite.position = Vector2(randf_range(100, screen.x-100), randf_range(100, screen.y-100))
	
	sprite.texture = load("res://assets/cookie_sheet.png")
	sprite.hframes = 3
	sprite.frame = randi() % 3
	
	sprite.scale = Vector2.ZERO
	add_child(sprite)
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", SCALE_NORMAL, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(randf_range(1.5, 2.0)).timeout
	
	if is_instance_valid(sprite) and not sprite.has_meta("popping"):
		sprite.set_meta("popping", true)
		var shrink = create_tween()
		shrink.tween_property(sprite, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_SINE)
		await shrink.finished
		if is_instance_valid(sprite):
			sprite.queue_free()



func _input(event: InputEvent) -> void:
	if current_state != GameState.PLAYING:
		return
		
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
			if hovered_cookie != null and is_instance_valid(hovered_cookie) and not hovered_cookie.has_meta("popping"):
				var tween = create_tween()
				tween.tween_property(hovered_cookie, "scale", SCALE_NORMAL, 0.1)
			
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
	
	var sfx = AudioStreamPlayer.new()
	sfx.stream = pop_sounds.pick_random()
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)
	
	var points = 0
	if cookie.frame == 0:
		points = 100
	elif cookie.frame == 1:
		points = 250
	elif cookie.frame == 2:
		points = 500
		
	actual_score += points
	total_popped += 1
	
	var score_tween = create_tween()
	score_tween.tween_property(self, "display_score", actual_score, 0.5)
	
	spawn_floating_text(cookie.position, points)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(cookie, "scale", SCALE_POP, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cookie, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cookie, "rotation", TAU, 0.3).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	if is_instance_valid(cookie):
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
	if is_instance_valid(float_label):
		float_label.queue_free()



func _on_start_button_pressed() -> void:
	current_state = GameState.PLAYING
	$StartButton.hide()
	$StatsLabel.hide()
	
	actual_score = 0
	display_score = 0
	
	$RoundTimer.start()
	$SpawnTimer.start()



func _on_round_timer_timeout() -> void:
	current_state = GameState.GAMEOVER
	$SpawnTimer.stop()
	
	for cookie in get_children():
		if cookie is Sprite2D:
			cookie.queue_free()
			
	if actual_score > high_score:
		high_score = actual_score
			
	$StatsLabel.text = "High Score: %d\nTotal Popped: %d\nTime Played: %d s" % [high_score, total_popped, int(total_time_played)]
	$StatsLabel.size.x = screen.x
	$StatsLabel.position = Vector2(0, (screen.y / 2.0) + 50)
	$StatsLabel.show()
			
	$StartButton.text = "PLAY AGAIN"
	$StartButton.position = Vector2((screen.x / 2.0) - ($StartButton.size.x / 2.0), (screen.y / 2.0) - ($StartButton.size.y / 2.0))
	$StartButton.show()
	$TimeLabel.text = "Time: 0"
