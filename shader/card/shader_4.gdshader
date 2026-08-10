shader_type canvas_item;

uniform vec2 mouse_pos = vec2(0.0); 
uniform float hovering = 0.0;
uniform float tilt_intensity : hint_range(0.0, 1.0) = 0.3; 

void vertex() {
	if (hovering > 0.0) {
		
		vec2 c_uv = UV - vec2(0.5);
		
		float perspective_x = c_uv.y * mouse_pos.x * tilt_intensity;
		float perspective_y = c_uv.x * mouse_pos.y * tilt_intensity;
		
		VERTEX.x += (c_uv.x * perspective_x) * 100.0 * hovering;
		VERTEX.y += (c_uv.y * perspective_y) * 100.0 * hovering;
		VERTEX += mouse_pos * length(c_uv) * 15.0 * hovering;
	}
}