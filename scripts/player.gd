class_name Player
extends CharacterBody2D
## Nhân vật chính: di chuyển 8 hướng, 4 loại vũ khí (Kiếm, Thương, Cung, Sách),
## lướt né, nhận kinh nghiệm (XP) và lên cấp. Thông số vũ khí nằm ở scripts/weapons.gd.

signal died

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const SLASH_EFFECT := preload("res://scripts/effects/slash_effect.gd")
const RING_EFFECT := preload("res://scripts/effects/ring_effect.gd")
const FIREBALL_TEXTURE := preload("res://assets/sprites/fireball.png")
const SHADOW_TEXTURE := preload("res://assets/sprites/shadow.png")

# --- Di chuyển (chỉnh trong Inspector khi chọn node Player) ---
@export var move_speed := 95.0
@export var acceleration := 900.0     # tăng tốc nhanh cỡ nào
@export var friction := 1100.0        # dừng lại nhanh cỡ nào
@export var dash_speed := 280.0
@export var dash_time := 0.18
@export var dash_cooldown := 0.6

# --- Đánh thường ---
@export var combo_window := 0.5        # Kiếm: bấm tiếp trong khoảng này để nối combo

# --- Kỹ năng nguyên tố ---
## Tạm TẮT theo kế hoạch: làm đánh thường trước, nguyên tố làm sau.
## Đổi thành true để bật lại Cầu Lửa (Q) và Sấm Nộ (E).
const ELEMENTS_ENABLED := false
const FIRE_COST := 6
const FIRE_COOLDOWN := 0.7
const THUNDER_COST := 15
const THUNDER_COOLDOWN := 4.0
const THUNDER_RADIUS := 72.0
const MANA_REGEN := 2.5  # năng lượng hồi mỗi giây

# --- Chỉ số (thay đổi khi lên cấp / nhặt đồ) ---
var level := 1
var xp := 0
var xp_to_next := 20
var max_hp := 60
var hp := 60
var max_mp := 30
var mp := 30.0
var attack := 8
var gold := 0

# --- Sức mạnh nguyên tố đã thức tỉnh ---
var fire_unlocked := false
var thunder_unlocked := false

# --- Bộ đếm thời gian nội bộ ---
var facing := Vector2.DOWN
var attack_cd := 0.0
var dash_timer := 0.0
var dash_cd := 0.0
var dash_dir := Vector2.ZERO
var fire_cd := 0.0
var thunder_cd := 0.0
var invuln := 0.0
var knockback := Vector2.ZERO
var is_dead := false
var walk_time := 0.0
var ghost_timer := 0.0
var dust_timer := 0.0
var shake_strength := 0.0
var combo_step := 0          # 0, 1, 2 = đòn 1, 2, 3
var combo_timer := 0.0       # còn bao lâu để nối combo
var swing_time := 0.0        # > 0 khi đang vung kiếm (đi chậm lại)
var attack_buffered := false # bấm chém hơi sớm thì ghi nhớ lại
var last_attack_cooldown := 0.2

# --- Vũ khí ---
var weapon: int = Weapons.Type.SWORD  # chọn lúc tạo nhân vật, không đổi khi chơi
var charging := false        # đang gồng cung
var charge_time := 0.0
var charge_full_notified := false
var book_time := 0.0
var book_msg_cd := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
var weapon_pivot: Node2D     # tâm xoay của vũ khí cầm tay
var weapon_sprite: Sprite2D
var hold_sprite: Sprite2D    # vũ khí cầm trong tay lúc không đánh
var book_sprite: Sprite2D    # sách phép bay lơ lửng cạnh người


func _ready() -> void:
	add_to_group("player")
	# Bóng dưới chân
	var shadow := Sprite2D.new()
	shadow.texture = SHADOW_TEXTURE
	shadow.position = Vector2(0, 7)
	add_child(shadow)
	move_child(shadow, 0)
	# Vũ khí cầm tay (chỉ hiện khi đánh)
	weapon_pivot = Node2D.new()
	weapon_pivot.position = Vector2(0, 2)
	weapon_sprite = Sprite2D.new()
	weapon_sprite.offset = Vector2(6, 0)  # cán vũ khí nằm ở tâm xoay
	weapon_pivot.add_child(weapon_sprite)
	weapon_pivot.visible = false
	add_child(weapon_pivot)
	hold_sprite = Sprite2D.new()
	add_child(hold_sprite)
	# Sách phép
	book_sprite = Sprite2D.new()
	book_sprite.texture = Weapons.info(Weapons.Type.BOOK)["texture"]
	book_sprite.scale = Vector2.ONE * 0.75
	book_sprite.visible = false
	add_child(book_sprite)
	# Ngoại hình và vũ khí lấy từ màn hình tạo nhân vật
	CharacterParts.apply_to_sprite(sprite, Game.appearance)
	weapon = Weapons.ORDER[int(Game.appearance.get("weapon", 0)) % Weapons.ORDER.size()]
	book_sprite.visible = weapon == Weapons.Type.BOOK
	hold_sprite.texture = Weapons.info(weapon).get("held")


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_tick_timers(delta)

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input != Vector2.ZERO:
		facing = input.normalized()

	if dash_timer > 0.0:
		velocity = dash_dir * dash_speed
	else:
		var slow := 0.35 if swing_time > 0.0 else (0.45 if charging else 1.0)
		var speed := move_speed * slow
		var target := input * speed
		var rate := acceleration if input != Vector2.ZERO else friction
		velocity = velocity.move_toward(target, rate * delta) + knockback
		knockback = Vector2.ZERO
	move_and_slide()

	if Input.is_action_just_pressed("dash"):
		_try_dash(input)
	if weapon == Weapons.Type.BOW:
		_handle_bow(delta)
	elif Input.is_action_just_pressed("attack"):
		if attack_cd > 0.0:
			attack_buffered = attack_cd < 0.18
		else:
			_try_attack()
	elif attack_buffered and attack_cd <= 0.0:
		attack_buffered = false
		_try_attack()
	if ELEMENTS_ENABLED and Input.is_action_just_pressed("skill_fire"):
		_try_fire()
	if ELEMENTS_ENABLED and Input.is_action_just_pressed("skill_thunder"):
		_try_thunder()

	_update_visual(delta, input)


func _process(delta: float) -> void:
	# Camera nhìn trước một chút theo hướng đang đi
	var look := facing * 14.0 if velocity.length() > 10.0 else Vector2.ZERO
	camera.position = camera.position.lerp(look, 3.0 * delta)
	# Rung camera
	if shake_strength > 0.0:
		camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
		shake_strength = maxf(shake_strength - 30.0 * delta, 0.0)
	else:
		camera.offset = Vector2.ZERO
	# Sách phép bay lơ lửng sau vai
	if book_sprite.visible:
		book_time += delta
		var side := -1.0 if facing.x >= 0.0 else 1.0
		book_sprite.position = Vector2(side * 9.0, -7.0 + sin(book_time * 3.0) * 1.5)
		book_sprite.rotation = sin(book_time * 2.0) * 0.12
	queue_redraw()


## Vẽ thanh gồng cung dưới chân.
func _draw() -> void:
	if not charging:
		return
	var max_t: float = Weapons.info(Weapons.Type.BOW)["charge_time"]
	var k := clampf(charge_time / max_t, 0.0, 1.0)
	var rect := Rect2(-9, 11, 18, 3)
	draw_rect(rect, Color(0.05, 0.05, 0.1, 0.8))
	var fill := Color(1.0, 0.85, 0.3) if k < 1.0 else Color(1.0, 1.0, 1.0)
	draw_rect(Rect2(rect.position + Vector2(1, 1), Vector2((rect.size.x - 2) * k, 1)), fill)


func _tick_timers(delta: float) -> void:
	attack_cd = maxf(attack_cd - delta, 0.0)
	book_msg_cd = maxf(book_msg_cd - delta, 0.0)
	combo_timer = maxf(combo_timer - delta, 0.0)
	swing_time = maxf(swing_time - delta, 0.0)
	dust_timer = maxf(dust_timer - delta, 0.0)
	dash_timer = maxf(dash_timer - delta, 0.0)
	dash_cd = maxf(dash_cd - delta, 0.0)
	fire_cd = maxf(fire_cd - delta, 0.0)
	thunder_cd = maxf(thunder_cd - delta, 0.0)
	invuln = maxf(invuln - delta, 0.0)
	mp = minf(mp + MANA_REGEN * delta, float(max_mp))


# ---------------------------------------------------------------- Hành động

func _try_dash(input: Vector2) -> void:
	if dash_cd > 0.0 or dash_timer > 0.0:
		return
	dash_dir = input.normalized() if input != Vector2.ZERO else facing
	dash_timer = dash_time
	dash_cd = dash_cooldown
	ghost_timer = 0.0
	Game.dust(global_position + Vector2(0, 7), 8)


# ---------------------------------------------------------------- Vũ khí

func _try_attack() -> void:
	if attack_cd > 0.0:
		return
	match weapon:
		Weapons.Type.SWORD:
			_attack_sword()
		Weapons.Type.SPEAR:
			_attack_spear()
		Weapons.Type.BOOK:
			_attack_book()


## Gây sát thương cho mọi quái nằm trong hình quạt trước mặt. Trả về true nếu trúng ít nhất 1 con.
func _hit_cone(reach: float, arc_degrees: float, damage: int, push: float,
		armor_pierce: float, armor_break: int) -> bool:
	var half_arc := deg_to_rad(arc_degrees) / 2.0
	var hit_any := false
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.is_dead:
			continue
		var to_enemy := enemy.global_position - global_position
		if to_enemy.length() > reach + enemy.hit_radius:
			continue
		if to_enemy.length() > 6.0 and absf(facing.angle_to(to_enemy)) > half_arc:
			continue
		enemy.take_damage(roll_damage(damage), to_enemy.normalized() * push, armor_pierce, armor_break)
		hit_any = true
	return hit_any


func _show_weapon(texture: Texture2D, behind: bool) -> void:
	weapon_sprite.texture = texture
	weapon_sprite.position = Vector2.ZERO
	weapon_sprite.modulate = Color.WHITE
	weapon_pivot.visible = true
	weapon_pivot.scale = Vector2.ONE
	# Hướng lên trên thì vũ khí nằm sau lưng nhân vật
	move_child(weapon_pivot, 1 if behind else get_child_count() - 1)


# --- Kiếm: nhanh, combo 3 đòn
func _attack_sword() -> void:
	var w := Weapons.info(Weapons.Type.SWORD)
	# Nối combo nếu bấm kịp, không thì quay về đòn 1
	combo_step = (combo_step + 1) % 3 if combo_timer > 0.0 else 0
	var is_finisher := combo_step == 2
	attack_cd = w["finisher_cooldown"] if is_finisher else w["cooldown"]
	last_attack_cooldown = attack_cd
	combo_timer = combo_window
	swing_time = 0.14
	knockback = facing * (70.0 if is_finisher else 45.0)  # nhích người về trước

	_swing_sword(w["texture"], is_finisher)
	var slash := SLASH_EFFECT.new()
	slash.radius = float(w["range"]) - 4.0
	slash.rotation = facing.angle()
	slash.position = Vector2(0, 2)
	if is_finisher:
		slash.color = Color(1.0, 0.85, 0.4)
	add_child(slash)

	var mult: float = w["finisher_damage"] if is_finisher else w["damage"]
	var reach: float = float(w["range"]) + (4.0 if is_finisher else 0.0)
	var push: float = float(w["knockback"]) * (1.7 if is_finisher else 1.0)
	if _hit_cone(reach, w["arc"], int(attack * mult), push, w["armor_pierce"], w["armor_break"]):
		Game.hit_stop(0.07 if is_finisher else 0.035)
		Game.shake(3.0 if is_finisher else 1.5)


## Vung thanh kiếm thành một vòng cung quanh người.
func _swing_sword(texture: Texture2D, is_finisher: bool) -> void:
	var base := facing.angle()
	var arc := deg_to_rad(170.0 if is_finisher else 130.0)
	var from := base - arc / 2.0
	var to := base + arc / 2.0
	if combo_step == 1:  # đòn 2 vung ngược lại
		var tmp := from
		from = to
		to = tmp
	_show_weapon(texture, facing.y < -0.5)
	weapon_pivot.rotation = from
	weapon_pivot.scale = Vector2.ONE * (1.15 if is_finisher else 1.0)
	var tw := create_tween()
	tw.tween_property(weapon_pivot, "rotation", to, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.04)
	tw.tween_callback(func(): weapon_pivot.visible = false)


# --- Thương: đâm thẳng, tầm xa, phá giáp
func _attack_spear() -> void:
	var w := Weapons.info(Weapons.Type.SPEAR)
	attack_cd = w["cooldown"]
	last_attack_cooldown = attack_cd
	swing_time = 0.2
	knockback = facing * 65.0

	_show_weapon(w["texture"], facing.y < -0.5)
	weapon_pivot.rotation = facing.angle()
	weapon_sprite.position = Vector2(-4, 0)
	var tw := create_tween()
	tw.tween_property(weapon_sprite, "position:x", 14.0, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.06)
	tw.tween_property(weapon_sprite, "position:x", 0.0, 0.12)
	tw.tween_callback(func(): weapon_pivot.visible = false)

	var dmg := int(attack * float(w["damage"]))
	if _hit_cone(w["range"], w["arc"], dmg, w["knockback"], w["armor_pierce"], w["armor_break"]):
		Game.burst(global_position + facing * 28.0, Color(1, 1, 0.85), 6, 50.0, 0.0, 0.25, 2.0)
		Game.hit_stop(0.05)
		Game.shake(2.0)


# --- Cung: giữ để gồng, thả để bắn
func _handle_bow(delta: float) -> void:
	var w := Weapons.info(Weapons.Type.BOW)
	if Input.is_action_just_pressed("attack") and attack_cd <= 0.0 and not charging:
		charging = true
		charge_time = 0.0
		charge_full_notified = false
	if not charging:
		return
	var max_t: float = w["charge_time"]
	charge_time = minf(charge_time + delta, max_t)
	# Cầm cung hướng về phía trước, rung nhẹ khi gồng đầy
	_show_weapon(w["texture"], facing.y < -0.5)
	weapon_pivot.rotation = facing.angle()
	weapon_sprite.position = Vector2(2, 0)
	if charge_time >= max_t:
		weapon_sprite.position += Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
		weapon_sprite.modulate = Color(1.6, 1.4, 0.8)
		if not charge_full_notified:
			charge_full_notified = true
			Game.burst(global_position + facing * 10.0, Color(1, 0.9, 0.5), 8, 30.0, 0.0, 0.3, 1.5)
	if not Input.is_action_pressed("attack"):
		_release_bow()


func _release_bow() -> void:
	var w := Weapons.info(Weapons.Type.BOW)
	charging = false
	var k := clampf(charge_time / float(w["charge_time"]), 0.0, 1.0)
	var full := k >= 1.0
	attack_cd = w["cooldown"]
	last_attack_cooldown = attack_cd
	var mult := lerpf(w["damage"], w["charged_damage"], k * k)
	var speed := lerpf(w["arrow_speed"], w["charged_speed"], k)
	var p := PROJECTILE_SCENE.instantiate() as Projectile
	var color := Color(1.0, 0.9, 0.5) if full else Color(0.9, 0.85, 0.75)
	p.setup(facing, speed, roll_damage(int(attack * mult)), true, w["arrow"], color)
	p.armor_pierce = w["armor_pierce"]
	p.armor_break = w["armor_break"]
	if full:
		p.pierce = w["charged_pierce"]
		p.heavy = true
		p.scale = Vector2.ONE * 1.3
		p.modulate = Color(1.5, 1.3, 0.8)
		p.life = 1.6
		knockback = -facing * 50.0  # giật lùi
		Game.shake(2.0)
	p.global_position = global_position + facing * 6.0
	get_parent().add_child(p)
	var tw := create_tween()
	tw.tween_interval(0.12)
	tw.tween_callback(func(): weapon_pivot.visible = false)


# --- Sách phép: thiết kế trước, sức mạnh nguyên tố sẽ thêm sau
func _attack_book() -> void:
	attack_cd = Weapons.info(Weapons.Type.BOOK)["cooldown"]
	last_attack_cooldown = attack_cd
	Game.burst(book_sprite.global_position, Color(0.75, 0.55, 1.0), 10, 35.0, -20.0, 0.5, 1.5)
	var tw := create_tween()
	tw.tween_property(book_sprite, "scale", Vector2.ONE * 1.0, 0.08)
	tw.tween_property(book_sprite, "scale", Vector2.ONE * 0.75, 0.15)
	if book_msg_cd <= 0.0:
		book_msg_cd = 4.0
		Game.message.emit("Sách Phép đang ngủ yên... Sức mạnh nguyên tố sẽ được thức tỉnh sau.")


func _try_fire() -> void:
	if not fire_unlocked:
		Game.message.emit("Bạn chưa thức tỉnh nguyên tố Lửa (đạt cấp 2)")
		return
	if fire_cd > 0.0 or mp < FIRE_COST:
		return
	fire_cd = FIRE_COOLDOWN
	mp -= FIRE_COST
	var p := PROJECTILE_SCENE.instantiate() as Projectile
	p.setup(facing, 230.0, roll_damage(int(attack * 1.6) + 4), true, FIREBALL_TEXTURE, Color(1.0, 0.55, 0.2))
	p.global_position = global_position + facing * 8.0
	get_parent().add_child(p)


func _try_thunder() -> void:
	if not thunder_unlocked:
		Game.message.emit("Nguyên tố Sấm vẫn còn ngủ yên... (hạ Boss để thức tỉnh)")
		return
	if thunder_cd > 0.0 or mp < THUNDER_COST:
		return
	thunder_cd = THUNDER_COOLDOWN
	mp -= THUNDER_COST
	var ring := RING_EFFECT.new()
	ring.max_radius = THUNDER_RADIUS
	ring.color = Color(1.0, 0.95, 0.4)
	ring.lightning = true
	ring.global_position = global_position
	get_parent().add_child(ring)
	Game.shake(4.0)
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.is_dead:
			continue
		var to_enemy := enemy.global_position - global_position
		if to_enemy.length() <= THUNDER_RADIUS + enemy.hit_radius:
			enemy.take_damage(roll_damage(attack * 2 + 10), to_enemy.normalized() * 200.0)
			enemy.stun(1.0)


## Sát thương dao động ±20%, 10% cơ hội chí mạng x2.
func roll_damage(base: int) -> int:
	var dmg := float(base) * randf_range(0.8, 1.2)
	if randf() < 0.1:
		dmg *= 2.0
	return maxi(1, roundi(dmg))


# ---------------------------------------------------------------- Nhận sát thương

## Trả về true nếu thật sự bị trúng đòn (không đang lướt / bất tử).
func take_damage(amount: int, push_dir: Vector2 = Vector2.ZERO) -> bool:
	if is_dead or invuln > 0.0 or dash_timer > 0.0:
		return false
	hp = maxi(hp - amount, 0)
	invuln = 0.8
	if push_dir != Vector2.ZERO:
		knockback = push_dir.normalized() * 170.0
	Game.popup_text(global_position, "-%d" % amount, Color(1.0, 0.3, 0.3))
	Game.shake(3.0)
	if hp <= 0:
		_die()
	return true


func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)
	Game.popup_text(global_position, "+%d" % amount, Color(0.4, 1.0, 0.4))


func restore_mana(amount: int) -> void:
	mp = minf(mp + amount, float(max_mp))
	Game.popup_text(global_position, "+%d MP" % amount, Color(0.5, 0.7, 1.0))


func _die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	var tw := create_tween()
	tw.tween_property(sprite, "rotation", PI / 2.0, 0.4)
	tw.parallel().tween_property(sprite, "modulate", Color(0.5, 0.5, 0.5, 0.8), 0.4)
	died.emit()


# ---------------------------------------------------------------- Kinh nghiệm & lên cấp

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		_level_up()


func _level_up() -> void:
	level += 1
	xp_to_next = int(xp_to_next * 1.5) + 5
	max_hp += 12
	max_mp += 5
	attack += 3
	hp = max_hp
	mp = max_mp
	Game.popup_text(global_position + Vector2(0, -10), "LÊN CẤP!", Color(1.0, 0.85, 0.3), 12)
	Game.message.emit("Lên cấp %d!  Máu +12, Tấn công +3" % level)
	if ELEMENTS_ENABLED and level >= 2 and not fire_unlocked:
		fire_unlocked = true
		Game.message.emit("Thức tỉnh nguyên tố LỬA! Nhấn Q (hoặc chuột phải) để bắn Cầu Lửa")


func add_attack(amount: int) -> void:
	attack += amount
	Game.popup_text(global_position, "+%d Tấn công" % amount, Color(0.8, 0.5, 1.0))


func unlock_thunder() -> void:
	if thunder_unlocked or not ELEMENTS_ENABLED:
		return
	thunder_unlocked = true
	Game.message.emit("Thức tỉnh nguyên tố SẤM! Nhấn E để tung Sấm Nộ quanh người")
	var ring := RING_EFFECT.new()
	ring.max_radius = 50.0
	ring.color = Color(1.0, 0.95, 0.4)
	ring.global_position = global_position
	get_parent().add_child(ring)


# ---------------------------------------------------------------- Hình ảnh

func _update_visual(delta: float, input: Vector2) -> void:
	# Chọn hàng trong sprite sheet: 0 = xuống, 1 = lên, 2 = ngang
	var row := 0
	if absf(facing.x) > absf(facing.y) * 0.9:
		row = 2
		sprite.flip_h = facing.x < 0.0
	elif facing.y < 0.0:
		row = 1
	# Chọn khung hình đi bộ (4 khung)
	var col := 0
	if input != Vector2.ZERO and dash_timer <= 0.0:
		walk_time += delta * 10.0
		col = int(walk_time) % 4
		if dust_timer <= 0.0:
			dust_timer = 0.28
			Game.dust(global_position + Vector2(0, 7), 2)
	else:
		walk_time = 0.0
	sprite.frame = row * 4 + col
	CharacterParts.sync_frames(sprite)  # tóc, áo, mũ đi theo khung hình của thân
	_update_held_weapon(row, col)
	# Nhấp nháy khi bất tử
	if invuln > 0.0:
		sprite.modulate.a = 0.35 if int(invuln * 20.0) % 2 == 0 else 1.0
	else:
		sprite.modulate.a = 1.0
	hold_sprite.modulate.a = sprite.modulate.a
	# Bóng mờ khi lướt
	if dash_timer > 0.0:
		ghost_timer -= delta
		if ghost_timer <= 0.0:
			ghost_timer = 0.03
			_spawn_ghost()


## Vũ khí cầm trong tay: đổi chỗ theo hướng nhìn, nhún theo bước chân, ẩn khi đang vung đánh.
func _update_held_weapon(row: int, col: int) -> void:
	hold_sprite.visible = hold_sprite.texture != null and not weapon_pivot.visible
	if not hold_sprite.visible:
		return
	var pose: Array = Weapons.HOLD_POSES[Weapons.direction_name(row, facing.x < 0.0)]
	hold_sprite.position = pose[0] + Vector2(0, -1 if col % 2 == 1 else 0)
	hold_sprite.flip_h = pose[2]
	# Vẽ sau lưng thì đặt ngay trước thân trong danh sách con, không thì ngay sau
	var behind: bool = pose[1]
	var target := sprite.get_index() if behind else sprite.get_index() + 1
	if hold_sprite.get_index() < sprite.get_index():
		target -= 1  # đang nằm trước thân thì vị trí thân lệch đi 1 khi lấy ra
	if hold_sprite.get_index() != target:
		move_child(hold_sprite, target)


func _spawn_ghost() -> void:
	var ghost := Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.global_position = sprite.global_position
	ghost.modulate = Color(0.5, 0.8, 1.0, 0.6)
	# Bóng mờ cũng có tóc, áo, mũ giống nhân vật
	for layer in sprite.get_children():
		if layer is Sprite2D and layer.visible:
			var copy := Sprite2D.new()
			copy.texture = layer.texture
			copy.hframes = layer.hframes
			copy.vframes = layer.vframes
			copy.frame = layer.frame
			copy.flip_h = layer.flip_h
			ghost.add_child(copy)
	get_parent().add_child(ghost)
	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tw.tween_callback(ghost.queue_free)


func shake(strength: float) -> void:
	shake_strength = maxf(shake_strength, strength)


func set_camera_limits(rect: Rect2) -> void:
	camera.limit_left = int(rect.position.x)
	camera.limit_top = int(rect.position.y)
	camera.limit_right = int(rect.end.x)
	camera.limit_bottom = int(rect.end.y)
