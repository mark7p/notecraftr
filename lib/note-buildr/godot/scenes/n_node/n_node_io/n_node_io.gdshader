shader_type canvas_item;

uniform float circle_radius : hint_range(0.0, 0.4) = 0.3;
uniform float circle_border : hint_range(0.0, 0.1) = 0.05;
uniform vec4 circle_color : source_color = vec4(1.0);
const vec2 center = vec2(0.5, 0.5);
uniform float clip_radius : hint_range(0.0, 0.4) = 0.3;
uniform float clip_border : hint_range(0.0, 0.1) = 0.05;
uniform float clip_center : hint_range(-2.0, 2.0) = 0.3;

void fragment() {
    float center_to_uv = length(center - UV);
    if (center_to_uv > circle_radius + circle_border) {
        discard;
    }
    
    float clip_center_to_uv = length(center + vec2(-clip_center, 0.0) - UV);
    
    if (clip_center_to_uv < clip_radius){
        discard;
    }
    else if (clip_center_to_uv < clip_radius + clip_border && center_to_uv > circle_radius){
        discard;
    }
    
    float opacity = center_to_uv >= circle_radius ? 0.5: circle_color.a;
    COLOR = vec4(circle_color.r, circle_color.g, circle_color.b, opacity);
}