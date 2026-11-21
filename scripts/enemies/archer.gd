extends Enemy
## Cung thủ xương: giữ khoảng cách và bắn tên.

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const ARROW_TEXTURE := preload("res://assets/sprites/arrow.png")

@export var shoot_range := 140.0
@export var preferred_distance := 80.0
@export var shoot_cooldown := 1.8
@export var arrow_damage := 7

var shoot_cd := 1.0
var aim_time := 0.0  # > 0 nghĩa là đang ngắm (nhấp nháy đỏ báo trước)


func _ai(delta: float) -> Vector2:
	shoot_cd -= delta
	if not player_in_range(shoot_range):
		return _wander(delta)

	var to_player := player.global_position - global_position
	if aim_time > 0.0:
		aim_time -= delta
		if aim_time <= 0.0:
			_shoot(to_player)
		return Vector2.ZERO
	if shoot_cd <= 0.0:
		aim_time = 0.4
		return Vector2.ZERO

	# Giữ khoảng cách
	var dist := to_player.length()
	if dist < preferred_distance - 15.0:
		return -to_player.normalized() * speed
	elif dist > preferred_distance + 15.0:
		return to_player.normalized() * speed
	return to_player.normalized().orthogonal() * speed * 0.5


func _shoot(to_player: Vector2) -> void:
	shoot_cd = shoot_cooldown
	var p := PROJECTILE_SCENE.instantiate() as Projectile
	var dmg := int(arrow_damage * (1.5 if is_elite else 1.0))
	p.setup(to_player, 140.0, dmg, false, ARROW_TEXTURE, Color(0.9, 0.9, 0.8))
	p.global_position = global_position
	get_parent().add_child(p)


func _animate(delta: float, move: Vector2) -> void:
	super._animate(delta, move)
	if aim_time > 0.0 and flash_time <= 0.0:
		sprite.modulate = Color(1.6, 0.6, 0.6)
	if player_in_range(shoot_range):
		sprite.flip_h = player.global_position.x < global_position.x
