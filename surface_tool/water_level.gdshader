shader_type spatial;
render_mode unshaded;

uniform sampler2D height_map;
uniform sampler2D surface_map;
uniform float height_scale = 1.0;
uniform float min_water_level = 0.0;

void vertex() {
	float height = max(min_water_level, texture(height_map, VERTEX.xz).b);
	VERTEX.y += height * height_scale;
}

void fragment() {
	vec3 color = texture(surface_map, UV).rgb;
	ALBEDO = color;
}