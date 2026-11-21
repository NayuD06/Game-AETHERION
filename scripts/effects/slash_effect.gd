extends Node2D
## Hiệu ứng vệt chém hình vòng cung (vẽ bằng code, không cần ảnh).

var radius := 20.0
var color := Color(1.0, 1.0, 0.85)
var alpha := 1.0


func _ready() -> void:
	z_index = 5
	var tw := create_tween()
	tw.tween_property(self, "alpha", 0.0, 0.16)
	tw.tween_callback(queue_free)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var c := color
	c.a = alpha
	draw_arc(Vector2.ZERO, radius, -1.2, 1.2, 14, c, 4.0)
	draw_arc(Vector2.ZERO, radius - 4.0, -0.9, 0.9, 10, Color(1, 1, 1, alpha * 0.6), 2.0)
