shader_type canvas_item;
// Viền màu quanh hình quái khi rê chuột lên (giống Liên Minh Huyền Thoại).
// outline_on = true thì vẽ viền, false thì hình giữ nguyên.

uniform vec4 outline_color : source_color = vec4(1.0, 0.3, 0.25, 1.0);
uniform bool outline_on = false;

void fragment() {
	// COLOR đã là màu hình gốc, chỉ tô màu viền vào các ô trống sát mép hình
	if (outline_on) {
		vec4 tex = texture(TEXTURE, UV);
		if (tex.a < 0.5) {
			vec2 p = TEXTURE_PIXEL_SIZE;
			float n = texture(TEXTURE, UV + vec2(p.x, 0.0)).a;
			n = max(n, texture(TEXTURE, UV - vec2(p.x, 0.0)).a);
			n = max(n, texture(TEXTURE, UV + vec2(0.0, p.y)).a);
			n = max(n, texture(TEXTURE, UV - vec2(0.0, p.y)).a);
			if (n > 0.5) {
				COLOR = outline_color;
			}
		}
	}
}
