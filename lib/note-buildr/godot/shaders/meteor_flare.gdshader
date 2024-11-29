// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;

void vertex() {
	// Calculate rotation angle based on time and rotation speed
    float theta = TIME * 1.0;

    // Calculate sine and cosine of the rotation angle
    float c = cos(theta);
    float s = sin(theta);

    // Rotate vertex position around the y-axis
    float x = VERTEX.x * c + VERTEX.y * s;
    float y = -VERTEX.x * s + VERTEX.y * c;

    // Update vertex position
    VERTEX.x = x;
    VERTEX.y = y;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}
vec3 hueShift(vec3 color, float hue)
{
	const vec3 k = vec3(0.57735, 0.57735, 0.57735);
	float cosAngle = cos(hue);
	return vec3(color * cosAngle + cross(k, color) * sin(hue) + k * dot(k, color) * (1.0 - cosAngle));
}


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV) * albedo;
	ALPHA *= albedo.a * albedo_tex.a;
	float sin_wave = (sin(TIME * 4.0) + 1.0) / 2.0;
	vec3 hued = hueShift(albedo_tex.rgb, sin_wave * 1.5);
	EMISSION = hued * 2.0 * brightness;
	ALBEDO = hued;

}
