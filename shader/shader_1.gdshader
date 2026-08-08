shader_type canvas_item;

uniform vec4 shine_color : source_color = vec4(1.0, 0.95, 0.8, 1.0);
// تغییر زاویه به منفی ۴۵ درجه برای چرخش جهت موج
uniform float angle : hint_range(-180.0, 180.0) = -45.0;
uniform float width : hint_range(0.05, 0.8) = 0.25;
uniform float shine_strength : hint_range(0.0, 2.0) = 0.7;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    if (tex_color.a < 0.01) {
        discard;
    }

    float angle_rad = radians(angle);
    vec2 centered_uv = UV - vec2(0.5);
    float rotated_pos = centered_uv.x * cos(angle_rad) - centered_uv.y * sin(angle_rad);

    // معکوس کردن جهت حرکت: از 1.0 (راست/پایین) به 1.0- (چپ/بالا)
    float shine_pos = mix(1.0, -1.0, progress);

    float dist = abs(rotated_pos - shine_pos);

    float shine_wave = smoothstep(width, 0.0, dist);
    shine_wave = smoothstep(0.0, 1.0, shine_wave);

    vec3 blended_rgb = mix(tex_color.rgb, tex_color.rgb + shine_color.rgb, shine_wave * shine_strength);

    COLOR = vec4(blended_rgb, tex_color.a);
}