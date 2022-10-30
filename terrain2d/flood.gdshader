shader_type canvas_item;

const float color_diff = 0.00390625;
const vec2 dirs_1[] = {
	vec2( 1.0,  0.0),  // E
	vec2( 1.0,  1.0),  // NE
	vec2( 0.0,  1.0),  // N
	vec2(-1.0,  1.0),  // NW
	vec2(-1.0,  0.0),  // W
	vec2(-1.0, -1.0),  // SW
	vec2( 0.0, -1.0),  // S
	vec2( 1.0, -1.0)   // SE
};

vec4 get_neighbour_color(vec2 uv, vec2 sps, sampler2D tex, vec2 dxy) {
	vec2 neighbour = uv + dxy * sps;
	return texture(tex, neighbour);
}

bool red_nearby(vec2 uv, vec2 sps, sampler2D tex) {
	for (int i = 0; i < dirs_1.length(); i++){
		float red = get_neighbour_color(uv, sps, tex, dirs_1[i]).r;
		if (red >= 1.0) {
			return true;
		}
	}
	return false;
}

bool is_black(vec3 color) {
	return color.r < color_diff && color.g < color_diff && color.b < color_diff;
}

void fragment() {
	vec2 uv = UV;
	vec2 sps = SCREEN_PIXEL_SIZE;
	vec3 color = texture(TEXTURE, uv).rgb;
	
	// If this pixel if black and a red is nearby, set this red
	if (is_black(color) && red_nearby(uv, sps, TEXTURE)) {
		color.r = 1.0;
	}

	COLOR = vec4(color, 1.0);
}
