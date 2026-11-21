extends Enemy
## Heo rừng: thấy người chơi thì cào chân lấy đà, rồi húc thẳng một đường rất mạnh.
## Né sang bên khi nó đang lấy đà! Da dày nên có chút giáp.

enum State { NORMAL, WINDUP, CHARGE, REST }

var state := State.NORMAL
var state_time := 0.0
var charge_dir := Vector2.ZERO


func _ai(delta: float) -> Vector2:
	state_time -= delta
	match state:
		State.WINDUP:
			if state_time <= 0.0:
				state = State.CHARGE
				state_time = 0.7
			return Vector2.ZERO
		State.CHARGE:
			if state_time <= 0.0:
				state = State.REST
				state_time = 1.0
			return charge_dir * speed * 3.5
		State.REST:
			if state_time <= 0.0:
				state = State.NORMAL
			return Vector2.ZERO
	if player_in_range(detect_range):
		if player_in_range(90.0):
			state = State.WINDUP
			state_time = 0.55
			charge_dir = global_position.direction_to(player.global_position)
			return Vector2.ZERO
		return global_position.direction_to(player.global_position) * speed * 0.6
	return _wander(delta)


func _animate(delta: float, move: Vector2) -> void:
	super._animate(delta, move)
	if state == State.WINDUP:
		sprite.flip_h = charge_dir.x < 0.0
		sprite.position.x = sin(state_time * 70.0)   # rung người lấy đà
		if randf() < 0.3:
			Game.dust(global_position + Vector2(0, 7), 1)
	else:
		sprite.position.x = 0.0
