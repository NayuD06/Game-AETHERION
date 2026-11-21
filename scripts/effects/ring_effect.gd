extends Node2D
## Hiệu ứng vòng tròn lan rộng (nổ, Sấm Nộ...). Vẽ bằng code.

var max_radius := 40.0
var color := Color(1.0, 0.6, 0.2)
var lightning := false  # vẽ thêm tia sét
var duration := 0.35

var _t := 0.0
var _bolts: Array[PackedVector2Array] = []


func _ready() -> void:
	z_index = 5
	if lightning:
		for i in 8:
			var angle := TAU * i / 8.0 + randf_range(-0.2, 0.2)
			var points := PackedVector2Array([Vector2.ZERO])
			var steps := 5
			for s in range(1, steps + 1):
				var r := max_radius * s / float(steps)
				var jitter := Vector2(randf_range(-6, 6), randf_range(-6, 6))
				points.append(Vector2.RIGHT.rotated(angle) * r + jitter)
			_bolts.append(points)


func _process(delta: float) -> void:
	_t += delta
	if _t >= duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := _t / duration
	var c := color
	c.a = 1.0 - k
	draw_arc(Vector2.ZERO, max_radius * k, 0.0, TAU, 32, c, 3.0)
	draw_circle(Vector2.ZERO, max_radius * k * 0.6, Color(c.r, c.g, c.b, c.a * 0.25))
	for bolt in _bolts:
		draw_polyline(bolt, Color(1, 1, 1, c.a), 1.5)
