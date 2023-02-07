shader_type spatial;
//render_mode depth_prepass_alpha;

uniform sampler2D u_color_channel;
uniform sampler2D u_mask;

uniform float u_total_time;
uniform float u_current_time;

void fragment() {
	float time = u_current_time / u_total_time;
	vec2 final_uv = UV;
	if (final_uv.y < 1.0 - time) discard;

	vec4 curr_mask = texture(u_mask, final_uv);
	float mask = (curr_mask.g);
	vec4 base_color = texture(u_color_channel, final_uv);
	ALBEDO = base_color.rgb;
	ALPHA = clamp(time, 0.0, 1.0) * base_color.a;

}
