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

# combo stuff
const COMBO_TIME_LIMIT = 1.1 # seconds left to hit the next cookie
var combo_count = 0
var combo_timer = 0.0
var combo_ui # richtext

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
	$Label.add_theme_font_size_override("font_size", 24)
	$Label.position = Vector2(30, 30)
	
	$TimeLabel.add_theme_font_override("font", custom_font)
	$TimeLabel.add_theme_font_size_override("font_size", 24)
	$TimeLabel.text = "Time: 30"
	$TimeLabel.position = Vector2(screen.x - $TimeLabel.size.x - 75, 30)
	
	$StartButton.add_theme_font_override("font", custom_font)
	$StartButton.add_theme_font_size_override("font_size", 32)
	$StartButton.size = Vector2(250, 60)
	$StartButton.position = Vector2((screen.x / 2.0) - ($StartButton.size.x / 2.0), (screen.y / 2.0) - ($StartButton.size.y / 2.0))
	$StartButton.modulate = Color(1.3, 1.3, 1.3)
	
	$StatsLabel.add_theme_font_override("font", custom_font)
	$StatsLabel.add_theme_font_size_override("font_size", 16)
	$StatsLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$StatsLabel.text = "High Score: %d\nTotal Popped: %d\nTotal Time: %d s" % [high_score, total_popped, int(total_time_played)]
	$StatsLabel.size.x = screen.x
	$StatsLabel.position = Vector2(0, (screen.y / 2.0) + 50)
	
	# create the combo label with bbcode
	combo_ui = RichTextLabel.new()
	combo_ui.bbcode_enabled = true
	combo_ui.fit_content = true
	combo_ui.clip_contents = false
	combo_ui.scroll_active = false
	combo_ui.autowrap_mode = TextServer.AUTOWRAP_OFF
	combo_ui.add_theme_font_override("normal_font", custom_font)
	combo_ui.add_theme_font_size_override("normal_font_size", 32)
	add_child(combo_ui)
	combo_ui.hide()
	
	$SpawnTimer.stop()
	$StartButton.show()
	$StatsLabel.show()



func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		total_time_played += delta
		$TimeLabel.text = "Time: %d" % ceil($RoundTimer.time_left)
		
		# combo timer logic
		if combo_count > 0:
			combo_timer -= delta
			if combo_timer <= 0:
				combo_count = 0 # timer ran out n combo broke
				update_combo_ui()
		
		var mousepos = get_global_mouse_position()
		var hovered = get_top_cookie_at(mousepos)
		
		# enlarging or shrinking animations for cookie
		if hovered_cookie != hovered: # current different from old hovered
			if hovered_cookie != null and is_instance_valid(hovered_cookie) and not hovered_cookie.has_meta("popping"):
				var tween = create_tween()
				tween.tween_property(hovered_cookie, "scale", SCALE_NORMAL, 0.1)
			
			if hovered != null:
				var tween = create_tween()
				tween.tween_property(hovered, "scale", SCALE_HOVER, 0.1).set_trans(Tween.TRANS_BOUNCE)
			
			hovered_cookie = hovered #update with current cookie which is being hovered over



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
		if is_instance_valid(sprite): # prevent queue free on freed node incase game ended
			sprite.queue_free()



func get_top_cookie_at(pos: Vector2): # for finding what the tapped cookie was for mobile
	var all_cookies = get_children()
	all_cookies.reverse()
	
	for cookie in all_cookies:
		if cookie is Sprite2D and not cookie.has_meta("popping"): #only check non explodin cookies
			var width = cookie.texture.get_width() / float(cookie.hframes)
			var radius = ((width / 2.0) * SCALE_NORMAL.x) + TOLERANCE
			
			if cookie.position.distance_to(pos) <= radius:
				return cookie
	return null



func _input(event: InputEvent) -> void:
	if current_state != GameState.PLAYING:
		return
		
	if event is InputEventScreenTouch and event.pressed:
		var tapped = get_top_cookie_at(event.position)
		if tapped != null:
			clicked_cookie(tapped)
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if hovered_cookie != null and is_instance_valid(hovered_cookie) and not hovered_cookie.has_meta("popping"):
			clicked_cookie(hovered_cookie)
			hovered_cookie = null
			
			# ensure the cookie below gets hovered instantly instead of only on mouse position change
			var new_hovered = get_top_cookie_at(get_global_mouse_position())
			if new_hovered != null:
				var tween = create_tween()
				tween.tween_property(new_hovered, "scale", SCALE_HOVER, 0.1).set_trans(Tween.TRANS_BOUNCE)
				hovered_cookie = new_hovered



func clicked_cookie(cookie):
	cookie.set_meta("popping", true) # so we dont delete it again as its disappearin
	
	# increment combo and refill timer
	combo_count += 1
	combo_timer = COMBO_TIME_LIMIT
	var multiplier = combo_count
	
	update_combo_ui()
	
	var sfx = AudioStreamPlayer.new()
	sfx.stream = pop_sounds.pick_random()
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)
	
	var points = 100
		
	
	var actual_points = points * multiplier
	actual_score += actual_points
	total_popped += 1
	
	var score_tween = create_tween()
	score_tween.tween_property(self, "display_score", actual_score, 0.5)
	
	spawn_floating_text(cookie.position, actual_points, multiplier)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(cookie, "scale", SCALE_POP, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cookie, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cookie, "rotation", TAU, 0.3).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	if is_instance_valid(cookie):
		cookie.queue_free()



func update_combo_ui():
	if combo_count >= 2:
		combo_ui.show()
		combo_ui.modulate.a = 1.0 # if it wasnt 1 alpha already
		
		var text = ""
		if combo_count >= 5:
			text = "[rainbow][pulse freq=5.0]COMBO x%d[/pulse][/rainbow]" % combo_count
		elif combo_count == 4:
			text = "[color=red][tornado radius=3.0 freq=5.0]COMBO x4[/tornado][/color]"
		elif combo_count == 3:
			text = "[color=orange][shake]COMBO x3[/shake][/color]"
		elif combo_count == 2:
			text = "[color=yellow][wave]COMBO x2[/wave][/color]"
		
		combo_ui.text = text
		await get_tree().process_frame # fix wrong positioning bug
		combo_ui.position = Vector2(round((screen.x / 2.0) - (combo_ui.size.x / 2.0)), 30)
		
		# pop out effect
		combo_ui.pivot_offset = combo_ui.size / 2.0 # scale outwards and not to rightdown cuz of 0,0 default
		combo_ui.scale = Vector2(1.3, 1.3)
		var t = create_tween()
		t.tween_property(combo_ui, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BOUNCE)
	else:
		# fadeout
		var t = create_tween()
		t.tween_property(combo_ui, "modulate:a", 0.0, 0.3)
		await t.finished
		
		# only hide if combo broke ie 0
		if combo_count < 2: 
			combo_ui.hide()



func spawn_floating_text(spawn_pos, points, tier):
	var float_label = RichTextLabel.new()
	float_label.bbcode_enabled = true
	float_label.fit_content = true
	float_label.clip_contents = false
	float_label.scroll_active = false
	float_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	var custom_font = load("res://assets/Minecraft.ttf")
	float_label.add_theme_font_override("normal_font", custom_font)
	
	var base_size = 18
	var final_text = ""
	
	if tier >= 5:
		float_label.add_theme_font_size_override("normal_font_size", base_size + 16)
		final_text = "[rainbow][pulse freq=5.0]+%d[/pulse][/rainbow]" % points
	elif tier == 4:
		float_label.add_theme_font_size_override("normal_font_size", base_size + 12)
		final_text = "[color=#cc4444][tornado radius=3.0 freq=5.0]+%d[/tornado][/color]" % points
	elif tier == 3:
		float_label.add_theme_font_size_override("normal_font_size", base_size + 8)
		final_text = "[color=orange][shake]+%d[/shake][/color]" % points
	elif tier == 2:
		float_label.add_theme_font_size_override("normal_font_size", base_size + 4)
		final_text = "[color=yellow][wave]+%d[/wave][/color]" % points
	else:
		float_label.add_theme_font_size_override("normal_font_size", base_size)
		final_text = "+%d" % points
		
	float_label.text = final_text
	float_label.position = spawn_pos + Vector2(20, -10)
	add_child(float_label)
	
	# move up n fade
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
	combo_count = 0
	combo_ui.hide()
	
	$RoundTimer.start()
	$SpawnTimer.start()



func _on_round_timer_timeout() -> void:
	current_state = GameState.GAMEOVER
	$SpawnTimer.stop()
	combo_ui.hide()
	
	for cookie in get_children():
		if cookie is Sprite2D:
			cookie.queue_free()
			
	if actual_score > high_score:
		high_score = actual_score
			
	$StatsLabel.text = "High Score: %d\nTotal Popped: %d\nTotal Time: %d s" % [high_score, total_popped, int(total_time_played)]
	$StatsLabel.size.x = screen.x
	$StatsLabel.position = Vector2(0, (screen.y / 2.0) + 50)
	$StatsLabel.show()
			
	$StartButton.text = "PLAY AGAIN"
	$StartButton.position = Vector2(round((screen.x / 2.0) - ($StartButton.size.x / 2.0)), round((screen.y / 2.0) - ($StartButton.size.y / 2.0)))
	$StartButton.show()
	$TimeLabel.text = "Time: 0"
