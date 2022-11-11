shader_type canvas_item;

uniform sampler2DArray layers;
uniform int layer_count;

int highest_black_layer(vec2 uv) {
	int layer = layer_count;
	vec4 color = texture(layers, vec3(uv, float(layer)));
	
	while ((color.r > 0.0 || color.g > 0.0 || color.b > 0.0) && layer > 0) {
		layer -= 1;
		color = texture(layers, vec3(uv, float(layer)));
	}
	return layer;
}

vec3 something(vec2 uv, vec2 sps) {
	int layer = layer_count - 1;
	float blue_diff = 0.0;
	float red_diff = 0.0;
	float green_diff = 0.0;
	while (blue_diff + green_diff + red_diff <= 0.0 && layer > 0) {
		vec4 c = texture(layers, vec3(uv, float(layer)));
		vec4 n = texture(layers, vec3(uv + vec2( sps.x,    0.0), float(layer)));
		vec4 s = texture(layers, vec3(uv + vec2(-sps.x,    0.0), float(layer)));
		vec4 e = texture(layers, vec3(uv + vec2(   0.0,  sps.y), float(layer)));
		vec4 w = texture(layers, vec3(uv + vec2(   0.0, -sps.y), float(layer)));
		
		blue_diff = abs(c.b - ((n.b + s.b + e.b + w.b) * 0.25));
		red_diff = abs(c.r - ((n.r + s.r + e.r + w.r) * 0.25));
		green_diff = abs(c.g - ((n.g + s.g + e.g + w.g) * 0.25));
		layer -= 1;
	}
	
	return vec3(blue_diff, red_diff, green_diff);
}

void fragment() {
//	vec2 uv = UV;
//	float height = texture(TEXTURE, uv).g;
//	int water_layer = highest_black_layer(uv);
//	float highest_black = float(water_layer) / float(layer_count);
//	float bleed = 0.0;
//
//	if (highest_black >= height) {
//		bleed = textureLod(layers, vec3(UV, float(water_layer)), 10.0).r;
//	}
//
//	if (bleed > 0.0) {
//		bleed = 1.0;
//	}
//
//	float water = max(height, highest_black);
//	water = (water <= height) ? 0.0 : 1.0;
//
//    COLOR = vec4(bleed, bleed, water, 1.0);
	vec3 color = something(SCREEN_UV, SCREEN_PIXEL_SIZE);
	COLOR = vec4(color, 1.0);
}