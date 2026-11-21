extends Enemy
## Dơi: bay nhanh, lượn zic-zắc khi lao vào người chơi.

var zig_time := 0.0


func _ai(delta: float) -> Vector2:
	zig_time += delta
	if player_in_range(detect_range):
		var dir := global_position.direction_to(player.global_position)
		var side := dir.orthogonal() * sin(zig_time * 7.0) * 0.9
		return (dir + side).normalized() * speed
	return _wander(delta)


func _animate(delta: float, move: Vector2) -> void:
	anim_time += delta * 4.0  # vỗ cánh liên tục kể cả khi đứng yên
	super._animate(delta, move)
	sprite.position.y = sin(anim_time * 0.8) * 2.0 - 4.0  # bay lơ lửng
