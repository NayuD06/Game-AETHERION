extends Enemy
## Boss "Gorrak - Thạch Vương Cổ Đại".
## Các chiêu: Nhảy đập (có vòng đỏ báo trước), Bắn cầu bóng tối tỏa tròn,
## và Triệu hồi slime khi còn dưới một nửa máu (giai đoạn 2).

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const ORB_TEXTURE := preload("res://assets/sprites/dark_orb.png")
const SLIME_SCENE := preload("res://scenes/enemies/slime.tscn")
const RING_EFFECT := preload("res://scripts/effects/ring_effect.gd")

enum State { IDLE, CHASE, WINDUP, LEAP, RECOVER, BURST, SUMMON }

@export var slam_radius := 42.0
@export var slam_damage := 18
@export var orb_damage := 8

var state := State.IDLE
var state_time := 0.0
var phase2 := false
var leap_from := Vector2.ZERO
var leap_to := Vector2.ZERO
var attack_index := 0
var waves_fired := 0
var minions: Array = []


func _ready() -> void:
	super._ready()
	add_to_group("boss")


func _process(_delta: float) -> void:
	queue_redraw()


func _set_state(new_state: State) -> void:
	state = new_state
	state_time = 0.0
	waves_fired = 0


func _activate() -> void:
	if state != State.IDLE:
		return
	Game.boss_started.emit("%s  (Lv %d)" % [display_name, monster_level])
	Game.boss_health_changed.emit(hp, max_hp)
	Game.boss_armor_changed.emit(armor)
	Game.message.emit("%s đã thức giấc! Giáp đá rất dày, hãy dùng Thương để phá giáp." % display_name)
	Game.shake(5.0)
	_set_state(State.CHASE)


func _ai(delta: float) -> Vector2:
	state_time += delta
	match state:
		State.IDLE:
			if player_in_range(detect_range):
				_activate()
		State.CHASE:
			if not player_in_range(600.0):
				return Vector2.ZERO
			if state_time > (1.3 if phase2 else 2.0):
				_choose_attack()
				return Vector2.ZERO
			return global_position.direction_to(player.global_position) * speed
		State.WINDUP:
			if state_time >= (0.55 if phase2 else 0.8):
				leap_from = global_position
				_set_state(State.LEAP)
		State.LEAP:
			var k := clampf(state_time / 0.35, 0.0, 1.0)
			global_position = leap_from.lerp(leap_to, k)
			sprite.position.y = sprite_base_y - sin(k * PI) * 18.0
			if k >= 1.0:
				sprite.position.y = sprite_base_y
				_slam()
				_set_state(State.RECOVER)
		State.RECOVER:
			if state_time >= (0.5 if phase2 else 0.9):
				_set_state(State.CHASE)
		State.BURST:
			var total_waves := 3 if phase2 else 2
			if waves_fired < total_waves and state_time >= 0.5 + waves_fired * 0.55:
				_fire_wave(waves_fired)
				waves_fired += 1
			if state_time >= 0.5 + total_waves * 0.55 + 0.4:
				_set_state(State.CHASE)
		State.SUMMON:
			if state_time >= 0.6 and waves_fired == 0:
				waves_fired = 1
				_summon()
			if state_time >= 1.2:
				_set_state(State.CHASE)
	return Vector2.ZERO


func _choose_attack() -> void:
	var pattern: Array = ["slam", "burst"]
	if phase2:
		pattern = ["slam", "burst", "slam", "summon"]
	var choice: String = pattern[attack_index % pattern.size()]
	attack_index += 1
	match choice:
		"slam":
			leap_to = player.global_position
			_set_state(State.WINDUP)
		"burst":
			_set_state(State.BURST)
		"summon":
			_set_state(State.SUMMON)


func _slam() -> void:
	Game.shake(7.0)
	Game.burst(global_position + Vector2(0, 12), Color(0.75, 0.72, 0.65), 24, 110.0, 60.0, 0.6, 3.0)
	var ring := RING_EFFECT.new()
	ring.max_radius = slam_radius
	ring.color = Color(1.0, 0.5, 0.2)
	ring.global_position = global_position
	get_parent().add_child(ring)
	if player_in_range(slam_radius):
		player.take_damage(slam_damage, player.global_position - global_position)


func _fire_wave(index: int) -> void:
	var count := 14 if phase2 else 10
	var offset := (PI / count) * (index % 2)
	for i in count:
		var dir := Vector2.RIGHT.rotated(TAU * i / count + offset)
		var p := PROJECTILE_SCENE.instantiate() as Projectile
		p.setup(dir, 95.0, orb_damage, false, ORB_TEXTURE, Color(0.7, 0.3, 1.0))
		p.life = 3.0
		p.global_position = global_position + dir * 12.0
		get_parent().add_child(p)


func _summon() -> void:
	minions = minions.filter(func(m): return is_instance_valid(m))
	if minions.size() >= 4:
		return
	Game.message.emit("Gorrak triệu hồi tay sai!")
	for i in 2:
		var slime := SLIME_SCENE.instantiate() as Enemy
		slime.position = global_position + Vector2(-24 if i == 0 else 24, 16)
		slime.set_level(maxi(monster_level - 2, 1))   # tay sai thấp hơn Boss 2 cấp
		slime.xp_reward = 2
		get_parent().add_child(slime)
		minions.append(slime)


# ---------------------------------------------------------------- Ghi đè

func take_damage(amount: int, push: Vector2 = Vector2.ZERO, armor_pierce: float = 0.0,
		armor_break: int = 0) -> void:
	if is_dead:
		return
	_activate()
	super.take_damage(amount, push, armor_pierce, armor_break)
	Game.boss_health_changed.emit(maxi(hp, 0), max_hp)
	Game.boss_armor_changed.emit(armor)
	if not phase2 and hp > 0 and hp <= max_hp / 2:
		phase2 = true
		speed *= 1.35
		base_modulate = Color(1.0, 0.65, 0.65)
		Game.message.emit("%s nổi cơn thịnh nộ!" % display_name)
		Game.shake(6.0)


func _die() -> void:
	Game.shake(10.0)
	if Player.ELEMENTS_ENABLED:
		Pickup.spawn(get_parent(), Pickup.Kind.ELEMENT_CORE, global_position)
	for i in 3:
		Pickup.spawn(get_parent(), Pickup.Kind.POTION_HP, global_position, 30)
	super._die()
	Game.boss_defeated.emit()


func _animate(delta: float, move: Vector2) -> void:
	super._animate(delta, move)
	# Khung 1 = giơ tay lên (khi chuẩn bị tung chiêu)
	var raising := state == State.WINDUP or state == State.LEAP or state == State.BURST or state == State.SUMMON
	sprite.frame = 1 if raising else 0
	if state == State.WINDUP and flash_time <= 0.0:
		sprite.modulate = Color(1.5, 0.8, 0.6)
	elif (state == State.BURST or state == State.SUMMON) and flash_time <= 0.0:
		sprite.modulate = Color(1.2, 0.8, 1.6)


func _draw() -> void:
	super._draw()   # vòng chọn mục tiêu dưới chân
	# Vòng đỏ báo trước chỗ Boss sẽ đáp xuống
	if state == State.WINDUP or state == State.LEAP:
		var center := to_local(leap_to)
		var k := 1.0
		if state == State.WINDUP:
			k = clampf(state_time / (0.55 if phase2 else 0.8), 0.0, 1.0)
		draw_circle(center, slam_radius, Color(1, 0.1, 0.1, 0.15))
		draw_circle(center, slam_radius * k, Color(1, 0.2, 0.1, 0.25))
		draw_arc(center, slam_radius, 0.0, TAU, 32, Color(1, 0.2, 0.2, 0.8), 1.5)
