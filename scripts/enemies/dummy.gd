extends Enemy
## Bù nhìn tập đánh: đứng yên, không đánh lại, không bao giờ chết.
## Dùng để thử cảm giác chém và combo.

var wobble := 0.0
var armor_restore := 0.0  # bù nhìn có giáp: tự mặc lại giáp sau vài giây


func _ready() -> void:
	super._ready()
	collision_layer = 1 | 4  # chặn đường người chơi như một vật cản


func _ai(_delta: float) -> Vector2:
	return Vector2.ZERO


func take_damage(amount: int, push: Vector2 = Vector2.ZERO, armor_pierce: float = 0.0,
		armor_break: int = 0) -> void:
	super.take_damage(amount, Vector2.ZERO, armor_pierce, armor_break)
	if max_armor > 0 and armor < max_armor:
		armor_restore = 4.0
	hp = max_hp  # hồi đầy máu ngay, không bao giờ gục
	wobble = 0.35 * (1.0 if push.x >= 0.0 else -1.0)


func _animate(delta: float, move: Vector2) -> void:
	super._animate(delta, move)
	if armor_restore > 0.0:
		armor_restore -= delta
		if armor_restore <= 0.0:
			armor = max_armor
			shield_icon.visible = true
			Game.popup_text(global_position + Vector2(0, -16), "Giáp hồi lại", Color(0.7, 0.8, 0.9), 8)
	# Lắc lư khi bị đánh
	wobble = move_toward(wobble, 0.0, delta * 2.0)
	sprite.rotation = sin(Time.get_ticks_msec() / 40.0) * wobble


func _drop_loot() -> void:
	pass
