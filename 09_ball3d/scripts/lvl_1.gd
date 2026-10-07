extends Node3D


func _ready() -> void:
	GameManager.timer_running = true
	setup_environment()

func setup_environment() -> void:
	var env = $WorldEnvironment.environment
	if not env:
		env = Environment.new()
		$WorldEnvironment.environment = env
	
	env.background_mode = Environment.BG_SKY
	
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("b8d4f0")
	sky_mat.sky_horizon_color = Color("e8dcc8")
	sky_mat.ground_horizon_color = Color("e8dcc8")
	
	sky.sky_material = sky_mat
	env.sky = sky
	
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_sky_contribution = 0.5
	
	env.ssao_enabled = true
	env.glow_enabled = true
	env.glow_bloom = 0.1
	env.glow_intensity = 0.8
	
	var light = $DirectionalLight3D
	light.light_color = Color("fff4e0")
	light.light_energy = 0.3
	light.light_angular_distance = 0.5
	light.shadow_blur = 2.0
	light.shadow_enabled = true
