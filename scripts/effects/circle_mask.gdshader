shader_type canvas_item;
// Chỉ vẽ phần nằm trong hình tròn (dùng cho bản đồ nhỏ hình tròn).
// center, radius tính theo toạ độ của khung (Control). enabled = false thì vẽ bình thường.

uniform vec2 center = vec2(50.0, 50.0);
uniform float radius = 50.0;
uniform bool enabled = true;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	if (enabled) {
		float d = distance(local_pos, center);
		// mép tròn mịn, không răng cưa
		COLOR.a *= clamp(radius - d + 0.5, 0.0, 1.0);
	}
}
