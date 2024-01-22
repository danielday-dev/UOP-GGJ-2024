shader_type canvas_item;

uniform sampler2D mask : filter_nearest;
uniform sampler2D maskGrid : repeat_enable, filter_nearest;
uniform sampler2D maskDiamond : repeat_enable, filter_nearest;
uniform float maskScale = 1.0;

void fragment() {
	vec2 screenUV = (SCREEN_UV / SCREEN_PIXEL_SIZE) / maskScale;
	vec4 maskColor = texture(mask, UV);
	
	vec4 maskDiamondColor = texture(maskDiamond, screenUV);
	COLOR = mix(COLOR, maskDiamondColor, maskColor.r * maskDiamondColor.a);
	
	vec4 maskGridColor = texture(maskGrid, screenUV);
	COLOR = mix(COLOR, maskGridColor, maskColor.b * maskGridColor.a);
}

