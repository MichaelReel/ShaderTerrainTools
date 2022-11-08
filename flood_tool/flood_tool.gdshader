shader_type canvas_item;


uniform float tide_line;
uniform sampler2D last_layer; 

const float color_diff = 0.00390625;
const float color_max = 1.0 - color_diff;



bool red_in_proximity(vec2 uv, vec2 sps, sampler2D tex) {
	float red = textureLod(tex, uv, 0.1).r;
	return (red >= color_diff);
}

bool is_black(vec3 color) {
	return color.r <= 0.0 && color.g <= 0.0 && color.b <=0.0;
}

void fragment() {
	vec2 uv = UV;
//	vec2 sps = SCREEN_PIXEL_SIZE;
	vec2 sps = TEXTURE_PIXEL_SIZE;
	vec3 color = texture(TEXTURE, uv).rgb;
	
	// If this pixel if black and a red is nearby, set this red
	if (is_black(color)) {
		float last_red = texture(last_layer, uv).r;
		if (last_red >= 1.0) {
			color.r = 1.0;
		} else if (red_in_proximity(uv, sps, TEXTURE)) {
			color.r = 1.0;
			color.g = tide_line;
		}
	}

	COLOR = vec4(color, 1.0);
}
