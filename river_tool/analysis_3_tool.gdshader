shader_type canvas_item;

uniform sampler2DArray layers;
uniform int layer_count;

const float color_diff = 0.00390625;

int highest_no_red_layer(vec2 uv) {
	int layer = layer_count - 1;
	vec4 color = texture(layers, vec3(uv, float(layer)));
	
	while (color.r >= color_diff && layer > 0) {
		layer -= 1;
		color = texture(layers, vec3(uv, float(layer)));
	}
	return layer;
}

vec3 color_from_layer(vec2 uv, int layer) {
	return texture(layers, vec3(uv, float(layer))).rgb;
}

void fragment() {
	vec2 uv = UV;
	float height = texture(TEXTURE, uv).g;
	vec3 color = vec3(0.0);
	
	int water_layer = highest_no_red_layer(uv);
	float highest_black = float(water_layer) / float(layer_count);
	if (highest_black > height) {
		color = color_from_layer(uv, water_layer + 1);
	}

    COLOR = vec4(color, 1.0);
}