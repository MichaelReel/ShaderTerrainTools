shader_type canvas_item;

uniform float warping_1 = 0.2;
uniform float warping_2 = 0.2;
uniform float x_shape = 0.4;
uniform float depth = 0.5;
uniform float min_range = 0.2;
uniform float max_range = 0.7;
uniform vec2 root_offset = vec2(0.0, 0.0);
uniform vec2 warp_offset_1 = vec2(0.0, 0.3);
uniform vec2 warp_offset_2 = vec2(5.2, 1.3);

const float K1 = 0.366025404; // (sqrt(3)-1)/2;
const float K2 = 0.211324865; // (3-sqrt(3))/6;

vec2 hash( vec2 p )
{
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise( in vec2 p )
{
	vec2  i = floor(p + (p.x + p.y) * K1);
	vec2  a = p - i + (i.x + i.y) * K2;
	float m = step(a.y, a.x); 
	vec2  o = vec2(m, 1.0 - m);
	vec2  b = a - o + K2;
	vec2  c = a - 1.0 + 2.0 * K2;
	vec3  h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
	vec3  n = h * h * h * h * vec3(dot(a, hash(i+0.0)), dot(b, hash(i+o)), dot(c, hash(i+1.0)));
	return dot(n, vec3(70.0));
}

float fbm(vec2 uv) {
	uv *= 5.0;
	mat2 m = mat2(vec2(1.6,  1.2), vec2(-1.2,  1.6));
	
	float f = 0.0;
	f  = 0.5000 * noise(uv);
	uv = m * uv;
	f += 0.2500 * noise(uv);
	uv = m * uv;
	f += 0.1250 * noise(uv);
	uv = m * uv;
	f += 0.0625 * noise(uv);
	uv = m * uv;
	
	f = 0.5 + 0.5 * f;
	
	// Re-level the noise to be more 0.0 to 1.0
	f = smoothstep(min_range, max_range, f);
	
	return f;
}

float get_edge_fade(vec2 uv) {
	// Circular, around the middle
	float cf = clamp((1.0 - depth) - distance(uv, vec2(0.5)), 0.0, 1.0);

	// Find the nearest edges
	float vert = step(0.5, uv.y);
	float hort = step(0.5, uv.x);
	float sf = min(abs(vert - uv.y), abs(hort - uv.x)) + 0.5 - depth;

	float f = mix(cf, sf, x_shape);

	return f;
}

void fragment() {
	vec2 uv = UV;
	
	
	// Adding time to the input of the combining noise causes an inplace \"flow\"
	float f1 = fbm(uv + warp_offset_1) * warping_1; 
	float f2 = fbm(uv + warp_offset_2) * warping_2;
	vec2 mod_uv = uv + root_offset - vec2(f1, f2);
	float height = fbm(mod_uv);
	float fade = get_edge_fade(uv);
	
	float f = smoothstep(0.0, height, fade);
	
	COLOR = vec4(vec3(f), 1.0);
}
