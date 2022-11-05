shader_type canvas_item;


uniform sampler2D last_layer; 

const float color_diff = 0.00390625;
const float color_max = 1.0 - color_diff;

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

bool red_in_los(vec2 uv, vec2 sps, sampler2D tex) {
	for (int i = 0; i < dirs_1.length(); i++){
		vec4 nc = get_neighbour_color(uv, sps, tex, dirs_1[i]);
		float red = nc.r;
		float green = nc.g;
		float blue = nc.b;
		int seek = 2;
		// Scan until we hit something that isn't black
		while (red < color_diff && green < color_diff && blue < color_diff) {
			nc = get_neighbour_color(uv, sps, tex, dirs_1[i] * float(seek));
			red = nc.r;
			green = nc.g;
			blue = nc.b;
			seek += 1;
		}
		
		if (red > color_max) {
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
	if (is_black(color)) {
		float last_red = texture(last_layer, uv).r;
		if (last_red > color_max || red_in_los(uv, sps, TEXTURE)) {
			color.r = 1.0;
		}
	}

	COLOR = vec4(color, 1.0);
}
