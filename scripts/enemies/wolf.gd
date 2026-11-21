extends Enemy
## Sói: chạy rất nhanh, tới gần thì vồ tới một cái rồi nghỉ lấy sức. Hay đi theo bầy.

var lunge_time := 0.0
var rest_time := 0.0
var lunge_dir := Vector2.ZERO


func _ai(delta: float) -> Vector2:
	if rest_time > 0.0:
		rest_time -= delta
		return Vector2.ZERO
	if lunge_time > 0.0:
		lunge_time -= delta
		if lunge_time <= 0.0:
			rest_time = 0.55
		return lunge_dir * speed * 2.6
	if player_in_range(detect_range):
		if player_in_range(42.0):
			lunge_dir = global_position.direction_to(player.global_position)
			lunge_time = 0.22
			return Vector2.ZERO
		return global_position.direction_to(player.global_position) * speed
	return _wander(delta)
