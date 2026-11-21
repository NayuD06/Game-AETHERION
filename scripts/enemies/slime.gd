extends Enemy
## Slime: nhảy từng nhịp về phía người chơi.

var hop_timer := 0.0


func _ai(delta: float) -> Vector2:
	hop_timer += delta
	# Nhịp nhảy 0.9 giây: 0.35 giây đầu lao tới, phần còn lại đứng nghỉ
	var phase := fmod(hop_timer, 0.9)
	if phase > 0.35:
		return Vector2.ZERO
	if player_in_range(detect_range):
		return global_position.direction_to(player.global_position) * speed * 2.2
	return _wander(delta) * 2.0


func _animate(delta: float, move: Vector2) -> void:
	super._animate(delta, move)
	# Khung 0 = đang nhảy, khung 1 = bẹp xuống nghỉ
	sprite.frame = 0 if move != Vector2.ZERO else 1
