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

// from https://www.shadertoy.com/view/MsXSz4
 vec3 kuwahara( in vec2 uv, in int radius ) 
 {
     float n = float((radius + 1) * (radius + 1));
     int i; 
	 int j;
     vec3 m0 = vec3(0.0); vec3 m1 = vec3(0.0); vec3 m2 = vec3(0.0); vec3 m3 = vec3(0.0);
     vec3 s0 = vec3(0.0); vec3 s1 = vec3(0.0); vec3 s2 = vec3(0.0); vec3 s3 = vec3(0.0);
     vec3 c;

     for (int j = -radius; j <= 0; ++j)  {
         for (int i = -radius; i <= 0; ++i)  {
             c = get_water(uv + vec2(float(i),float(j)) * u_scale);
             m0 += c;
             s0 += c * c;
         }
		
		for (int i = 0; i <= radius; ++i)  {
             c = get_water(uv + vec2(float(i),float(j)) * u_scale);
             m1 += c;
             s1 += c * c;
         }
     }

     for (int j = 0; j <= radius; ++j)  {
         for (int i = 0; i <= radius; ++i)  {
             c = get_water(uv + vec2(float(i),float(j)) * u_scale);
             m2 += c;
             s2 += c * c;
         }
		
		for (int i = -radius; i <= 0; ++i)  {
             c = get_water(uv + vec2(float(i),float(j)) * u_scale);
             m3 += c;
             s3 += c * c;
         }
     }


     float min_sigma2 = 1e+2;
     m0 /= n;
     s0 = abs(s0 / n - m0 * m0);

     float sigma2 = s0.r + s0.g + s0.b;
     if (sigma2 < min_sigma2) {
         min_sigma2 = sigma2;
         return m0;
     }

     m1 /= n;
     s1 = abs(s1 / n - m1 * m1);

     sigma2 = s1.r + s1.g + s1.b;
     if (sigma2 < min_sigma2) {
         min_sigma2 = sigma2;
         return m1;
     }

     m2 /= n;
     s2 = abs(s2 / n - m2 * m2);

     sigma2 = s2.r + s2.g + s2.b;
     if (sigma2 < min_sigma2) {
         min_sigma2 = sigma2;
         return m2;
     }

     m3 /= n;
     s3 = abs(s3 / n - m3 * m3);

     sigma2 = s3.r + s3.g + s3.b;
     if (sigma2 < min_sigma2) {
         min_sigma2 = sigma2;
         return m3;
     }
 }

void fragment() {

	ALBEDO = kuwahara(UV, u_filter_radius);
}
