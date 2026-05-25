shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled;

uniform vec4 bubble_color : source_color = vec4(0.0, 0.8, 1.0, 0.5); // Glowing Cyan
uniform float glow_thickness : hint_range(1.0, 8.0) = 2.0;           // How sharp the edge ring is
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	float pulse = 1.0 + (sin(TIME * pulse_speed) * 0.3);
	float edge = 1.0 - dot(NORMAL, VIEW);
	float glow_ring = pow(edge, glow_thickness);
	ALBEDO = bubble_color.rgb;
	EMISSION = bubble_color.rgb * glow_ring * pulse * 5.0;
	ALPHA = glow_ring * bubble_color.a * pulse * 2.0;
}
