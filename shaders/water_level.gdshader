shader_type spatial;

uniform sampler2D u_noise_texture;
uniform sampler2D u_displacement_texture;
uniform vec3  u_world_disturbance_center;

float height(in vec2 uv, in float time) {
	vec2 timed_UV = uv + vec2(0, -0.015) * time;
	vec2 displacement_UV = texture(u_displacement_texture, timed_UV).rg * 2.0;
	return texture(u_noise_texture, timed_UV + displacement_UV).r;
}

void vertex() {
	VERTEX.y += height(UV, TIME) * 0.1;
	TANGENT = normalize(vec3(0.0, height(UV + vec2(0.0, 0.2), TIME) - height(UV + vec2(0.0, -0.2), TIME), 0.4));
	BINORMAL = normalize(vec3(0.4, height(UV + vec2(0.2, 0.0), TIME) - height(UV + vec2(-0.2, 0.0), TIME ), 0.0));
	NORMAL = cross(TANGENT, BINORMAL);
}

void fragment() {	
	ALBEDO = vec3(0.52, 0.52, 0.52);
	//ALBEDO = vec3(0.0, 0.5, 0.9);
	METALLIC = 0.5;
	ROUGHNESS = 0.09;
	ALPHA = 0.4;
	//ALBEDO = normalize(vec3(0.0, height(UV + vec2(0.0, 0.2), TIME) - height(UV + vec2(0.0, -0.2), TIME), 0.4));
}