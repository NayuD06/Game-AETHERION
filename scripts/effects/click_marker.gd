extends Node2D
## Dấu hiệu chỗ vừa bấm chuột phải: xanh lá = đi tới đây, đỏ = tấn công con quái này.
## Một vòng tròn dẹt thu nhỏ dần cùng 4 mũi tên chỉ vào giữa, rồi biến mất.

const LIFE := 0.45

var color := Color(0.45, 1.0, 0.5)
var time := 0.0


func _process(delta: float) -> void:
	time += delta
	if time >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := time / LIFE
	var c := color
	c.a = 1.0 - k * k
	var radius := lerpf(10.0, 4.0, k)
	# Vẽ dẹt theo chiều dọc cho giống nằm trên mặt đất
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 20, Color(0, 0, 0, c.a * 0.5), 2.0)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 20, c, 1.0)
	for i in 4:
		var dir := Vector2.RIGHT.rotated(PI / 4.0 + i * PI / 2.0)
		var tip := dir * (radius + 1.0)
		var back := dir * (radius + 5.0)
		var side := dir.orthogonal() * 2.5
		draw_colored_polygon(PackedVector2Array([tip, back + side, back - side]), c)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
