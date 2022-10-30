shader_type canvas_item;

uniform float slice_height = 0.15;


void fragment() {
	float height = texture(TEXTURE, UV).r;
	ivec2 size = textureSize(TEXTURE, 0);
	vec3 color = vec3(step(slice_height, height));
	
	if (
		FRAGCOORD.x <= 1.0 || FRAGCOORD.y <= 1.0 ||
		FRAGCOORD.x >= float(size.x - 1) || FRAGCOORD.y >= float(size.y - 1)
	) {
		color.r = 1.0;
	}
	
	COLOR = vec4(color, 1.0);
	
	
}