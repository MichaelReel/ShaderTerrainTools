shader_type canvas_item;

uniform sampler2DArray layers;
uniform int layer_count;

const float color_diff = 0.00390625;

int highest_black_layer(vec2 uv) {
	int layer = layer_count - 1;
	vec4 color = texture(layers, vec3(uv, float(layer)));
	
	while ((color.r >= color_diff || color.g >= color_diff || color.b >= color_diff) && layer > 0) {
		layer -= 1;
		color = texture(layers, vec3(uv, float(layer)));
	}
	return layer;
}

void fragment() {
	vec2 uv = UV;
	float height = texture(TEXTURE, uv).g;
	int water_layer = highest_black_layer(uv);
	float highest_black = float(water_layer) / float(layer_count);
	float water = max(height, highest_black);
	water = (water <= height) ? 0.0 : water;

    COLOR = vec4(0.0, 0.0, water, 1.0);
}