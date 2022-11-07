shader_type canvas_item;

uniform sampler2DArray layers;
uniform int layer_count;

const float color_diff = 0.00390625;

float highest_black(vec2 uv) {
	int layer = layer_count - 1;
	vec4 color = texture(layers, vec3(uv, float(layer)));
	
	while ((color.r >= color_diff || color.g >= color_diff || color.b >= color_diff) && layer > 0) {
		layer -= 1;
		color = texture(layers, vec3(uv, float(layer)));
	}
	return float(layer) / float(layer_count);
}


void fragment() {
	vec2 uv = UV;

	float height = texture(TEXTURE, uv).g;
	float water = max(height, highest_black(uv));
	if (water <= height) {
		water = 0.0;
	}

    COLOR = vec4(0.0, height, water, 1.0);
}