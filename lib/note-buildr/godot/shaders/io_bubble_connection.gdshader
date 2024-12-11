shader_type canvas_item;

uniform vec2 scale = vec2(1.0, 1.0);
uniform vec4 line_input_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 line_output_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_width : hint_range(0.00, 0.5) = 0.5;
uniform float dash_spacing : hint_range(0.00, 1.0) = 0.1;
uniform float dash_length : hint_range(0.00, 5.0) = 0.1;

// void fragment() {

// 	if (length(UV.y - 0.5) > line_width) {
// 		discard;
// 	}
// 	float dash_period = dash_spacing + dash_length;
// 	float dash_offset = mod((1.0 - UV.x), dash_period);
// 	if (dash_offset > dash_length) {
// 		discard;
// 	} else {
// 		bool drawn = false;

// //		START
// 		if (!drawn && dash_offset < line_width) {
// 			float first_corner_length = length(vec2(dash_offset, UV.y) - vec2(line_width, 0.5));
// 			if (first_corner_length <= line_width) {
// 				COLOR = mix(line_input_color, line_output_color, UV.x);
// 				drawn = true;
// 			}
// 		}
// //		MIDDLE
// 		if (!drawn && dash_offset > line_width && dash_offset <= dash_length - line_width) {
// 			COLOR = mix(line_input_color, line_output_color, UV.x);
// 			drawn = true;
// 		}
// //		END
// 		if (!drawn && dash_offset >= dash_length - line_width){
// 			float last_corner_length = length(vec2(dash_offset, UV.y) - vec2(dash_length -  line_width, 0.5));
// 			if (last_corner_length <= line_width){
// 				COLOR = mix(line_input_color, line_output_color, UV.x);
// 				drawn = true;
// 			}
// 		}
		
// 		if (!drawn) {
// 			discard;
// 		}
// 	}
// }
void fragment() {
	// Skip top and bottom padding
	if (length(UV.y - 0.5) > line_width) {
		discard;
	}
	// Scale X so it wont stretch
	float ratio = scale.x / scale.y;
	vec2 scaled_uv = vec2(UV.x * ratio, UV.y);
	float dash_period = dash_spacing + dash_length;
	float dash_offset = mod(ratio - scaled_uv.x, dash_period);

	// Skip space between dash
	if (dash_offset > dash_length) {
		discard;
	} else {
		bool drawn = false;

//		START
		if (!drawn && dash_offset < line_width) {
			float first_corner_length = length(vec2(dash_offset, UV.y) - vec2(line_width, 0.5));
			if (first_corner_length <= line_width) {
				COLOR = mix(line_input_color, line_output_color, UV.x);
				drawn = true;
			}
		}
//		MIDDLE
		if (!drawn && dash_offset > line_width && dash_offset <= dash_length - line_width) {
			COLOR = mix(line_input_color, line_output_color, UV.x);
			drawn = true;
		}
//		END
		if (!drawn && dash_offset >= dash_length - line_width){
			float last_corner_length = length(vec2(dash_offset, UV.y) - vec2(dash_length -  line_width, 0.5));
			if (last_corner_length <= line_width){
				COLOR = mix(line_input_color, line_output_color, UV.x);
				drawn = true;
			}
		}
		
		if (!drawn) {
			discard;
		}
	}
}
