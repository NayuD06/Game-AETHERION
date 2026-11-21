extends Node2D
## Đòn đánh vào một vùng (Mưa Tên, Thiên Thạch...): hiện vòng cảnh báo, rồi gây sát thương
## cho mọi quái trong vùng. style = "rain" (nhiều đợt tên rơi) hoặc "meteor" (1 cú nổ lớn).

const RING_EFFECT := preload("res://scripts/effects/ring_effect.gd")

var radius := 40.0
var delay := 0.3          # thời gian cảnh báo trước khi đánh
var ticks := 1            # số đợt gây sát thương
var interval := 0.15      # thời gian giữa các đợt
var damage := 10          # sát thương mỗi đợt (trước khi dao động ngẫu nhiên)
var color := Color(1.0, 0.9, 0.5)
var style := "rain"
var armor_pierce := 0.0
var armor_break := 0

var _t := 0.0
var _done_ticks := 0
var _next_tick := 0.0
var _streaks: Array = []  # vệt tên rơi: [vị trí, thời gian còn lại]


func _ready() -> void:
	_next_tick = delay


func _process(delta: float) -> void:
	_t += delta
	if _done_ticks < ticks and _t >= _next_tick:
		_strike()
		_done_ticks += 1
		_next_tick += interval
	for s in _streaks:
		s[1] -= delta
	_streaks = _streaks.filter(func(s): return s[1] > 0.0)
	if _done_ticks >= ticks and _streaks.is_empty() and _t > _next_tick:
		queue_free()
	queue_redraw()


func _strike() -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.is_dead:
			continue
		var to_enemy := enemy.global_position - global_position
		if to_enemy.length() <= radius + enemy.hit_radius:
			var dmg := maxi(1, roundi(damage * randf_range(0.8, 1.2)))
			var push := to_enemy.normalized() * (180.0 if style == "meteor" else 30.0)
			enemy.take_damage(dmg, push, armor_pierce, armor_break)
	if style == "meteor":
		var ring := RING_EFFECT.new()
		ring.max_radius = radius + 8.0
		ring.color = color
		ring.duration = 0.45
		ring.global_position = global_position
		get_parent().add_child(ring)
		Game.burst(global_position, color, 24, 110.0, 0.0, 0.5, 2.5)
		Game.shake(6.0)
		Game.hit_stop(0.06)
	else:
		for i in 4:
			var p := Vector2.RIGHT.rotated(randf() * TAU) * randf() * radius
			_streaks.append([p * Vector2(1.0, 0.6), 0.12])
		Game.dust(global_position + Vector2(randf_range(-radius, radius), randf_range(-radius, radius)) * 0.5, 2)


func _draw() -> void:
	# Vòng cảnh báo trên mặt đất
	var warn := color
	warn.a = 0.25 if _t < delay else 0.12
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
	draw_circle(Vector2.ZERO, radius, warn)
	var edge := color
	edge.a = 0.8 if _done_ticks < ticks else 0.3
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, edge, 1.5)
	if _t < delay:
		draw_arc(Vector2.ZERO, radius * (_t / delay), 0.0, TAU, 32, edge, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Tên rơi xuống / thiên thạch đang lao xuống
	for s in _streaks:
		var p: Vector2 = s[0]
		draw_line(p + Vector2(4, -22), p, Color(1, 1, 0.85, 0.9), 1.5)
	if style == "meteor" and _t < delay:
		var k := _t / delay
		var pos := Vector2(40, -120).lerp(Vector2.ZERO, k)
		draw_circle(pos, 6.0, color)
		draw_circle(pos, 3.5, Color(1, 1, 1, 0.9))
