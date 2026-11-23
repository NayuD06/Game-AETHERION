extends Enemy
## Bọ cạp sa mạc: tới gần thì dựng đuôi rung lên (báo trước), rồi chích một cú rất đau.
## Thấy nó rung đuôi thì lùi ra xa! Sống ở Sa Mạc Cát Vàng, Hẻm Núi Đỏ, quanh Ốc Đảo.

enum State { NORMAL, WINDUP, STING, REST }

const STING_BONUS := 1.6   # cú chích đau hơn va chạm thường

var state := State.NORMAL
var state_time := 0.0
var sting_dir := Vector2.ZERO
var base_contact := 0


func _ai(delta: float) -> Vector2:
	state_time -= delta
	match state:
		State.WINDUP:
			if state_time <= 0.0:
				state = State.STING
				state_time = 0.2
				base_contact = contact_damage
				contact_damage = roundi(contact_damage * STING_BONUS)
			return Vector2.ZERO
		State.STING:
			if state_time <= 0.0:
				state = State.REST
				state_time = 0.8
				contact_damage = base_contact
			return sting_dir * speed * 3.2
		State.REST:
			if state_time <= 0.0:
				state = State.NORMAL
			return Vector2.ZERO
	if player_in_range(detect_range):
		if player_in_range(40.0):
			state = State.WINDUP
			state_time = 0.5
			sting_dir = global_position.direction_to(player.global_position)
			return Vector2.ZERO
		return global_position.direction_to(player.global_position) * speed
	return _wander(delta)


func _animate(delta: float, move: Vector2) -> void:
	super._animate(delta, move)
	if state == State.WINDUP:
		sprite.flip_h = sting_dir.x < 0.0
		sprite.frame = 1
		sprite.position.x = sin(state_time * 80.0) * 0.8   # rung đuôi báo trước
		sprite.modulate = base_modulate.lerp(Color(1.0, 0.55, 0.45), 0.5)
	else:
		sprite.position.x = 0.0
