extends Enemy
## Cua bờ biển: bò ngang lại gần, tới sát thì kẹp mạnh một cái rồi lùi ra. Vỏ cứng nên có giáp
## (Thương phá giáp đánh cua rất hiệu quả). Hay nấp quanh bãi cát Làng Chài, Bờ Biển Tây, các đảo.

var side := 1.0
var side_time := 0.0
var pinch_time := 0.0
var back_time := 0.0
var pinch_dir := Vector2.ZERO


func _ai(delta: float) -> Vector2:
	if back_time > 0.0:
		back_time -= delta
		return -pinch_dir * speed * 0.8
	if pinch_time > 0.0:
		pinch_time -= delta
		if pinch_time <= 0.0:
			back_time = 0.45
		return pinch_dir * speed * 2.8
	if player_in_range(detect_range):
		var to_player := global_position.direction_to(player.global_position)
		if player_in_range(26.0):
			pinch_dir = to_player
			pinch_time = 0.18
			return Vector2.ZERO
		# bò ngang: vừa lại gần vừa đổi bên liên tục
		side_time -= delta
		if side_time <= 0.0:
			side_time = randf_range(0.4, 0.9)
			side = -side
		return (to_player * 0.55 + to_player.orthogonal() * side * 0.8).normalized() * speed
	return _wander(delta)


func _animate(delta: float, move: Vector2) -> void:
	super._animate(delta, move)
	sprite.flip_h = false   # cua bò ngang, không quay mặt
