shader_type spatial;

uniform sampler2D u_color_channel;
uniform sampler2D u_mask;

uniform float u_total_time;
uniform float u_current_time;

void fragment() {
	float time = u_current_time / u_total_time;
	vec4 curr_mask = texture(u_mask, UV);
	float mask = (1.0 - curr_mask.g) * curr_mask.a;
	mask = 1.0 - mask;
	vec4 base_color = texture(u_color_channel, UV);
	ALBEDO = base_color.rgb;
	if (mask >= time) {
		ALPHA = 0.0;
	} else {
		ALPHA = clamp(1.0 - mix(mask / time, 1.0, -2.0), 0.0, 1.0);
	}
}
