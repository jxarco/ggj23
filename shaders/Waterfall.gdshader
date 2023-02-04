shader_type spatial;
render_mode unshaded;

uniform sampler2D u_noise_texture;
uniform sampler2D u_displacement_texture;
uniform uint      u_banding_steps;
uniform float      u_min_intensity;
uniform float      u_max_intensity;
uniform float     u_distortion;
uniform float     u_speed;
uniform float     u_scale;
uniform int     u_filter_radius;
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

void fragment() {
	ALBEDO = get_water(UV);
}
