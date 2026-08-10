shader_type canvas_item;

uniform float t : hint_range(0.0, 1.0) = 0.0;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D noise_tex;
uniform float noise_scale = 1.0;

void fragment() {
	float noise = texture(noise_tex, UV * noise_scale).r;
	
	float mask = step(t, noise);
	if (mask < 1.0) { 
		discard; 
	}
	
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = tex_color * albedo_color;
}