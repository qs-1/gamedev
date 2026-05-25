shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, unshaded;

uniform vec4 cool_color : source_color = vec4(0.4, 0.0, 0.8, 1.0);
uniform vec4 hot_color : source_color = vec4(1.0, 0.4, 0.0, 1.0); 
uniform float flow_speed = 0.4;
uniform float scale = 4.0; 
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX; 
}

void fragment() {
	vec3 p = local_pos * scale;
	
	float val = sin(p.x + TIME * flow_speed);
	val += sin(p.y + TIME * flow_speed * 0.5);
	val += sin(p.z + TIME * flow_speed);
	
	float cx = p.x + sin(TIME * 0.2) * 5.0;
	float cy = p.y + cos(TIME * 0.3) * 5.0;
	float cz = p.z + sin(TIME * 0.4) * 5.0;
	val += sin(sqrt(cx * cx + cy * cy + cz * cz) + TIME * flow_speed);
	
	float plasma = sin(val * 2.0) * 0.5 + 0.5;
	
	vec3 final_color = mix(cool_color.rgb, hot_color.rgb, plasma);
	
	ALBEDO = final_color;
	EMISSION = final_color * 2.5; 
	ALPHA = alpha;
}
