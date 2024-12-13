shader_type canvas_item;

uniform float circle_radius : hint_range(0.0, 0.4) = 0.3;
uniform float circle_border : hint_range(0.0, 0.1) = 0.05;
uniform vec4 circle_color : source_color = vec4(1.0);
const vec2 center = vec2(0.5, 0.5);

void fragment() {
    float distance = length(center - UV);
    if (distance < circle_radius) {
		COLOR = circle_color;
    } else if (distance < circle_radius + circle_border && distance > circle_radius) {
		COLOR = circle_color * vec4(1.0, 1.0, 1.0, 0.5);
	}
	 else {
		discard;
	}
}
