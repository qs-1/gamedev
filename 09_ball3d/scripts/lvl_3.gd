extends Node3D

var spawn_pos 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	sky_mat.sky_top_color = Color("0a0f1e")
	sky_mat.sky_horizon_color = Color("1a2a5c")
	sky_mat.ground_horizon_color = Color("0d1428")
	
	sky.sky_material = sky_mat
	env.sky = sky
	
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("1a2040")
	env.ambient_light_energy = 1.2
	
	env.ssao_enabled = true
	env.ssil_enabled = true
	env.glow_enabled = true
	env.glow_bloom = 0.3
	env.glow_intensity = 1.1
	
	var light = $DirectionalLight3D
	light.light_color = Color("c8d8ff")
	light.light_energy = 0.6
	light.light_angular_distance = 0.3
	light.shadow_blur = 2.0
	light.rotation_degrees = Vector3(-20, 30, 0)
	light.shadow_enabled = true
	
