shader_type canvas_item;

uniform sampler2D last_layer;
uniform float flood_t;
uniform float proximity_fade = 1.0;

const float color_diff = 0.00390625;
const float color_max = 1.0 - color_diff;
const float lod_start = 0.1;
const float lod_inc = 0.1;


bool red_in_proximity(vec2 uv, sampler2D tex) {
	float lod = lod_start;
	float red = textureLod(tex, uv, lod).r;
	while (red < color_diff) {
		lod += lod_inc;
		vec3 col = textureLod(tex, uv, lod).rgb;
		if (col.b > col.r) {
			return false;
		}
		red = col.r;
	}
	return true;
}

bool is_black(vec3 color) {
	return color.r <= 0.0 && color.g <= 0.0 && color.b <=0.0;
}

void fragment() {
	vec2 uv = UV;
	vec3 color = texture(TEXTURE, uv).rgb;
	
	// If this pixel if black and a red is nearby, set this red
	if (is_black(color)) {
		float last_red = texture(last_layer, uv).r;
		if (last_red >= 1.0) {
			color.r = 1.0;
		} else if (red_in_proximity(uv, TEXTURE)) {
			color.r = 1.0;
			color.g = flood_t;
			color.g = proximity_fade;
		}
	}

	COLOR = vec4(color, 1.0);
}
