shader_type canvas_item;

uniform float offset_x = 0;
uniform float offset_y = 0;

uniform float scroll_x = 1;
uniform float scroll_y = 1;

void fragment(){
	vec2 newuv = UV;
	newuv.x += offset_x + scroll_x * TIME;
	newuv.y += offset_y + scroll_y * TIME;
	vec4 c = texture(TEXTURE, newuv);
	COLOR = c;
}