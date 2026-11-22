extends Enemy
## Boss hầm ngục (tầng 5): "Malakar - Vua Xương Bất Tử".
## Các chiêu:
##   Cầu Hồn Xoắn Ốc: đứng yên bắn cầu tím xoay vòng quanh người (giai đoạn 3 bắn 2 cánh).
##   Dịch Chuyển: biến mất, vòng tím hiện ra dưới chân bạn, hắn hiện ra ở đó và nổ.
##   Mưa Hồn (giai đoạn 2): nhiều vòng đỏ dưới đất, một lúc sau nổ. Đứng ngoài vòng đỏ!
##   Triệu Hồi (giai đoạn 2): gọi cung thủ xương ra đánh cùng.
## Hạ hắn: Cổng Xoáy mở ra và rơi một Rương kim cương.
## Giai đoạn 2 khi còn 60% máu, giai đoạn 3 (cuồng nộ, ra chiêu nhanh hơn) khi còn 25% máu.

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const ORB_TEXTURE := preload("res://assets/sprites/arcane_orb.png")
const ARCHER_SCENE := preload("res://scenes/enemies/archer.tscn")
const RING_EFFECT := preload("res://scripts/effects/ring_effect.gd")

enum State { IDLE, CHASE, SPIRAL, BLINK_OUT, BLINK_IN, RAIN, SUMMON }

@export var spiral_damage := 12
@export var blast_damage := 24
@export var blast_radius := 40.0
@export var rain_damage := 20
@export var rain_radius := 22.0

var state := State.IDLE
var state_time := 0.0
var stage := 1                 # giai đoạn 1, 2, 3
var attack_index := 0
var shot_timer := 0.0
var spiral_angle := 0.0
var blink_to := Vector2.ZERO
var rain_spots: Array[Vector2] = []
var rain_done := false
var minions: Array = []


func _ready() -> void:
	super._ready()
	add_to_group("boss")


func _process(_delta: float) -> void:
	queue_redraw()


func _set_state(new_state: State) -> void:
	state = new_state
	state_time = 0.0
	shot_timer = 0.0


func _activate() -> void:
	if state != State.IDLE:
		return
	Game.boss_started.emit("%s  (Lv %d)" % [display_name, monster_level])
	Game.boss_health_changed.emit(hp, max_hp)
	Game.boss_armor_changed.emit(armor)
	Game.message.emit("%s: \"Kẻ phàm trần dám bước vào điện thờ của ta sao?\"" % display_name)
	Game.shake(5.0)
	_set_state(State.CHASE)


func _ai(delta: float) -> Vector2:
	state_time += delta
	match state:
		State.IDLE:
			if player_in_range(detect_range):
				_activate()
		State.CHASE:
			if not player_in_range(500.0):
				return Vector2.ZERO
			var wait: float = [1.7, 1.3, 0.9][stage - 1]
			if state_time > wait:
				_choose_attack()
				return Vector2.ZERO
			# Pháp sư: giữ khoảng cách vừa phải với người chơi
			var dist := global_position.distance_to(player.global_position)
			var dir := global_position.direction_to(player.global_position)
			if dist > 110.0:
				return dir * speed
			if dist < 55.0:
				return -dir * speed * 0.8
			return dir.orthogonal() * speed * 0.5
		State.SPIRAL:
			shot_timer -= delta
			if shot_timer <= 0.0:
				shot_timer = 0.09 if stage < 3 else 0.075
				_fire_orb(spiral_angle)
				if stage == 3:
					_fire_orb(spiral_angle + PI)
				spiral_angle += 0.42
			if state_time >= 2.0:
				_set_state(State.CHASE)
		State.BLINK_OUT:
			modulate.a = clampf(1.0 - state_time / 0.5, 0.0, 1.0)
			if state_time >= 0.7:
				global_position = blink_to
				_set_state(State.BLINK_IN)
				_blast()
		State.BLINK_IN:
			modulate.a = clampf(state_time / 0.3, 0.0, 1.0)
			if state_time >= 0.6:
				modulate.a = 1.0
				_set_state(State.CHASE)
		State.RAIN:
			if not rain_done and state_time >= 1.1:
				rain_done = true
				_rain_explode()
			if state_time >= 1.5:
				rain_spots.clear()
				_set_state(State.CHASE)
		State.SUMMON:
			if state_time >= 0.7 and shot_timer == 0.0:
				shot_timer = 1.0
				_summon()
			if state_time >= 1.2:
				_set_state(State.CHASE)
	return Vector2.ZERO


func _choose_attack() -> void:
	var pattern: Array = ["spiral", "blink"]
	if stage >= 2:
		pattern = ["spiral", "rain", "blink", "summon", "rain", "blink"]
	var choice: String = pattern[attack_index % pattern.size()]
	attack_index += 1
	match choice:
		"spiral":
			spiral_angle = randf() * TAU
			_set_state(State.SPIRAL)
		"blink":
			blink_to = _open_spot_near(player.global_position, 18.0)
			_set_state(State.BLINK_OUT)
		"rain":
			rain_spots.clear()
			rain_done = false
			rain_spots.append(player.global_position)
			var count := 5 if stage == 2 else 8
			for i in count - 1:
				rain_spots.append(player.global_position + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(28.0, 80.0))
			_set_state(State.RAIN)
		"summon":
			_set_state(State.SUMMON)


## Chỗ đứng được (không phải tường) gần điểm p.
func _open_spot_near(p: Vector2, spread: float) -> Vector2:
	var level: Level = player.level_ref
	for i in 12:
		var spot := p + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(0.0, spread)
		if level == null or level.is_open(spot, 10.0):
			return spot
	return global_position


func _fire_orb(angle: float) -> void:
	var dir := Vector2.RIGHT.rotated(angle)
	var p := PROJECTILE_SCENE.instantiate() as Projectile
	p.setup(dir, 100.0, spiral_damage, false, ORB_TEXTURE, Color(0.8, 0.45, 1.0))
	p.life = 3.0
	p.global_position = global_position + dir * 12.0
	get_parent().add_child(p)


func _blast() -> void:
	Game.shake(6.0)
	Game.burst(global_position, Color(0.75, 0.4, 1.0), 22, 110.0, 40.0, 0.5, 2.5)
	var ring := RING_EFFECT.new()
	ring.max_radius = blast_radius
	ring.color = Color(0.75, 0.4, 1.0)
	ring.global_position = global_position
	get_parent().add_child(ring)
	if player_in_range(blast_radius):
		player.take_damage(blast_damage, player.global_position - global_position)


func _rain_explode() -> void:
	Game.shake(5.0)
	var hit := false
	for spot in rain_spots:
		var ring := RING_EFFECT.new()
		ring.max_radius = rain_radius
		ring.color = Color(1.0, 0.3, 0.35)
		ring.global_position = spot
		get_parent().add_child(ring)
		Game.burst(spot, Color(1.0, 0.35, 0.45), 8, 60.0, 30.0, 0.4, 1.5)
		if not hit and player != null and not player.is_dead and player.global_position.distance_to(spot) <= rain_radius:
			hit = true
	if hit:
		player.take_damage(rain_damage, Vector2.ZERO)


func _summon() -> void:
	minions = minions.filter(func(m): return is_instance_valid(m) and not m.is_dead)
	if minions.size() >= 3:
		return
	Game.message.emit("Malakar gọi lính xương trỗi dậy!")
	for i in 2:
		var archer := ARCHER_SCENE.instantiate() as Enemy
		archer.position = _open_spot_near(global_position + Vector2(-30 if i == 0 else 30, 18), 10.0)
		archer.apply_floor(Dungeon.FLOORS[Dungeon.FLOORS.size() - 1]["power"], Color(0.9, 0.75, 1.0), true)
		archer.set_level(maxi(monster_level - 4, 1))   # lính xương thấp hơn Malakar 4 cấp
		archer.xp_reward = 6
		get_parent().add_child(archer)
		Game.burst(archer.position, Color(0.7, 0.4, 1.0), 10, 50.0)
		minions.append(archer)


# ---------------------------------------------------------------- Ghi đè

func take_damage(amount: int, push: Vector2 = Vector2.ZERO, armor_pierce: float = 0.0,
		armor_break: int = 0) -> void:
	if is_dead or state == State.BLINK_OUT:
		return   # đang biến mất thì không đánh trúng được
	_activate()
	super.take_damage(amount, push, armor_pierce, armor_break)
	Game.boss_health_changed.emit(maxi(hp, 0), max_hp)
	Game.boss_armor_changed.emit(armor)
	if hp <= 0:
		return
	if stage == 1 and hp <= max_hp * 0.6:
		stage = 2
		Game.message.emit("Malakar: \"Trỗi dậy đi, những linh hồn bị nguyền rủa!\" (Coi chừng vòng đỏ dưới đất)")
		Game.shake(6.0)
	elif stage == 2 and hp <= max_hp * 0.25:
		stage = 3
		speed *= 1.3
		base_modulate = Color(1.0, 0.7, 0.8)
		Game.message.emit("Malakar nổi cơn cuồng nộ!")
		Game.shake(7.0)


func _die() -> void:
	Game.shake(10.0)
	modulate.a = 1.0
	for i in 4:
		Pickup.spawn(get_parent(), Pickup.Kind.POTION_HP, global_position, 40)
	for i in 3:
		Pickup.spawn(get_parent(), Pickup.Kind.POWER_CRYSTAL, global_position, 4)
	for m in minions:
		if is_instance_valid(m) and not m.is_dead:
			m.take_damage(9999)
	# Phần thưởng: một Rương kim cương (đã mở khoá) ngay chỗ hắn ngã xuống
	var level: Level = player.level_ref if player != null else null
	Chest.spawn_reward(get_parent(), position, "diamond", Dungeon.FLOORS.size(), level)
	super._die()
	Game.boss_defeated.emit()


func _animate(delta: float, move: Vector2) -> void:
	super._animate(delta, move)
	# Lơ lửng nhẹ; khung 1 = giơ tay niệm phép
	sprite.position.y = sprite_base_y + sin(anim_time * 1.5) * 1.5
	var casting := state == State.SPIRAL or state == State.RAIN or state == State.SUMMON or state == State.BLINK_OUT
	sprite.frame = 1 if casting else 0
	if casting and flash_time <= 0.0:
		sprite.modulate = Color(1.3, 0.9, 1.6)


func _draw() -> void:
	super._draw()   # vòng chọn mục tiêu dưới chân
	# Vòng tím: chỗ Malakar sắp hiện ra
	if state == State.BLINK_OUT:
		var c := to_local(blink_to)
		var k := clampf(state_time / 0.7, 0.0, 1.0)
		draw_circle(c, blast_radius, Color(0.6, 0.2, 1.0, 0.12))
		draw_circle(c, blast_radius * k, Color(0.7, 0.3, 1.0, 0.22))
		draw_arc(c, blast_radius, 0.0, TAU, 32, Color(0.8, 0.5, 1.0, 0.85), 1.5)
	# Vòng đỏ: Mưa Hồn sắp nổ
	if state == State.RAIN and not rain_done:
		var k := clampf(state_time / 1.1, 0.0, 1.0)
		for spot in rain_spots:
			var c := to_local(spot)
			draw_circle(c, rain_radius, Color(1, 0.1, 0.15, 0.14))
			draw_circle(c, rain_radius * k, Color(1, 0.2, 0.2, 0.25))
			draw_arc(c, rain_radius, 0.0, TAU, 24, Color(1, 0.25, 0.3, 0.85), 1.2)
