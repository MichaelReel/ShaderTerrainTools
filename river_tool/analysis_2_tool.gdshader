shader_type canvas_item;

uniform sampler2DArray layers;
uniform int layer_count;

bool has_green(sampler2D tex, vec2 uv) {
	vec4 c = texture(tex, uv);
	return (c.g > 0.0);
}

vec3 something(sampler2D tex, vec2 uv, vec2 sps) {
	vec4 c = texture(tex, uv);
	vec4 n = texture(tex, uv + vec2( sps.x,    0.0));
	vec4 s = texture(tex, uv + vec2(-sps.x,    0.0));
	vec4 e = texture(tex, uv + vec2(   0.0,  sps.y));
	vec4 w = texture(tex, uv + vec2(   0.0, -sps.y));
	
	float red_diff = abs(c.r - ((n.r + s.r + e.r + w.r) * 0.25));
	float green_diff = abs(c.g - ((n.g + s.g + e.g + w.g) * 0.25));
	float blue_diff = abs(c.b - ((n.b + s.b + e.b + w.b) * 0.25));
	
	return vec3(red_diff, green_diff, blue_diff);
}

float highest_near_blue(sampler2D tex, vec2 uv, vec2 sps) {
	float near_blue = 0.0;
	near_blue = max(near_blue, texture(tex, uv + vec2( sps.x,    0.0)).b);
	near_blue = max(near_blue, texture(tex, uv + vec2(-sps.x,    0.0)).b);
	near_blue = max(near_blue, texture(tex, uv + vec2(   0.0,  sps.y)).b);
	near_blue = max(near_blue, texture(tex, uv + vec2(   0.0, -sps.y)).b);

	return near_blue;
}

void fragment() {
	vec3 color = vec3(0.0);
	if (has_green(TEXTURE, SCREEN_UV)) {
		float near_blue = highest_near_blue(TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE);
		float green = texture(TEXTURE, SCREEN_UV).g;
//		color = something(TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE);
		color = (green <= near_blue + 0.003921569) ? vec3(1.0) : vec3(0.0);
	}
	COLOR = vec4(color, 1.0);
}