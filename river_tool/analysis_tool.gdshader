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

int highest_green_layer(vec2 uv) {
	int layer = layer_count - 1;
	vec4 color = texture(layers, vec3(uv, float(layer)));
	
	while (color.g <= color_diff && layer > 0) {
		layer -= 1;
		color = texture(layers, vec3(uv, float(layer)));
	}
	return layer;
}

void fragment() {
	vec2 uv = UV;
	float height = texture(TEXTURE, uv).g;
	
	int water_layer = highest_no_red_layer(uv);
	float highest_black = float(water_layer) / float(layer_count);
	float water = (highest_black <= height) ? 0.0 : highest_black;
	
	int fill_layer = highest_green_layer(uv);
	float fill_height = float(fill_layer) / float(layer_count);
	float land = (highest_black <= height) ? fill_height : 0.0;

    COLOR = vec4(0.0, land, water, 1.0);
}