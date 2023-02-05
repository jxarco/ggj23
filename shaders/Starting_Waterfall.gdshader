shader_type spatial;
render_mode cull_disabled;

uniform sampler2D u_noise_texture;
uniform sampler2D u_displacement_texture;
uniform uint      u_banding_steps;
uniform float      u_min_intensity;
uniform float      u_max_intensity;
uniform float     u_distortion;
uniform float     u_speed;
uniform float     u_total_time;
uniform float     u_current_time;


uniform vec4 tint_base : source_color;

vec3 get_water(in vec2 uv) {
	vec2 timed_UV = vec2(uv.x, uv.y + (TIME * -u_speed));
	vec2 displacement_UV = texture(u_displacement_texture, uv).rg / u_distortion;
	float noise_sample = texture(u_noise_texture, timed_UV + displacement_UV).r;
	
	float intensity = 0.0;
	const float banding_step = 1.0 / float(u_banding_steps);
	for(uint i = 0u; i < u_banding_steps; i++) {
		intensity += step(float(i) * banding_step, noise_sample) * banding_step;
	}
	
	intensity = clamp(intensity, u_min_intensity, u_max_intensity);
	
	return vec3(tint_base.rgb * intensity);
}

float LERP(float b,float x0,float y0,float x1,float y1) {
	return y0 + (b - x0) * (y1 - y0) / (x1 - x0);
}


void fragment() {
	float percentage = u_current_time / (u_total_time);
	if (UV.y > percentage) {
		ALPHA = 0.0;
	} else {
		ALPHA = clamp(1.0 - mix(UV.y / percentage, 1.0, -2.0), 0.0, 1.0);
	}
	
	ALBEDO = get_water(UV);
}
