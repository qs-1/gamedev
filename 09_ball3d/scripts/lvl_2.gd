extends Node3D

var spawn_pos 

func _ready() -> void:
	GameManager.timer_running = true
	spawn_pos = $ball.position
	setup_environment()

func reset_ball_pos():
	$ball.position = spawn_pos
	$ball.linear_velocity = Vector3.ZERO
	$ball.angular_velocity = Vector3.ZERO

func setup_environment() -> void:
	var env = $WorldEnvironment.environment
	if not env:
		env = Environment.new()
		$WorldEnvironment.environment = env
	
	env.background_mode = Environment.BG_SKY
	
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	
	sky_mat.sky_top_color = Color("2a3a5c")
	sky_mat.sky_horizon_color = Color("e8844a")
	sky_mat.ground_horizon_color = Color("c86040")
	
	sky.sky_material = sky_mat
	env.sky = sky
	
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_sky_contribution = 0.7
	
	env.tonemap_white = 6.0
	env.ssao_enabled = true
	env.glow_enabled = true
	env.glow_bloom = 0.15
	env.glow_intensity = 1.0
	
	var light = $DirectionalLight3D
	light.light_color = Color("ffcc88")
	light.light_energy = 1.2
	light.light_angular_distance = 0.5
	light.shadow_blur = 1.5
	light.rotation_degrees = Vector3(-30, -60, 0)
	light.shadow_enabled = true
