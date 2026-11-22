class_name Player
extends CharacterBody2D
## Nhân vật chính: điều khiển bằng chuột kiểu Liên Minh Huyền Thoại (hoặc bàn phím WASD),
## 4 loại vũ khí (Kiếm, Thương, Cung, Sách), lướt né, nhận kinh nghiệm (XP) và lên cấp.
## Thông số vũ khí nằm ở scripts/weapons.gd.
##
## Chuột phải lên đất: đi tới đó (tự tìm đường vòng qua vật cản). Giữ chuột phải: đi theo con trỏ.
## Chuột phải lên quái: chạy tới gần rồi tự động đánh.
## Chuột trái: đánh về phía con trỏ (Cung: giữ để gồng).
## A rồi chuột trái: vừa đi vừa đánh quái gặp trên đường. S: đứng lại.
## Q W E: kỹ năng vũ khí, R: tuyệt chiêu (tung về phía con trỏ). F: lướt. D: dùng bình máu.

signal died

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
const SLASH_EFFECT := preload("res://scripts/effects/slash_effect.gd")
const RING_EFFECT := preload("res://scripts/effects/ring_effect.gd")
const FIREBALL_TEXTURE := preload("res://assets/sprites/fireball.png")
const SHADOW_TEXTURE := preload("res://assets/sprites/shadow.png")
const CLICK_MARKER := preload("res://scripts/effects/click_marker.gd")
const AREA_STRIKE := preload("res://scripts/effects/area_strike.gd")
const ARCANE_TEXTURE := preload("res://assets/sprites/arcane_orb.png")
const SKILL_ACTIONS := ["skill_1", "skill_2", "skill_3", "skill_ult"]
const BAG_SLOTS_START := 12    # số ô túi lúc đầu
const BAG_SLOTS_MAX := 20      # tối đa (làm "Ba lô lớn hơn" ở bàn chế tạo để thêm ô)
const ITEM_COOLDOWN := 1.0

# --- Cấp độ mở khóa ---
## Cấp 1 chỉ có đánh thường (chuột) và lướt (F). Kỹ năng mở dần theo cấp:
## Q ở cấp 5, W ở cấp 10, E ở cấp 15, R (tuyệt chiêu) ở cấp 20. Phím D (uống máu nhanh) mở ở cấp 30.
## Mở hết 4 kỹ năng thì đổi được thứ tự kỹ năng (phím K).
const SKILL_UNLOCK_LEVELS := [5, 10, 15, 20]
const QUICK_ITEM_LEVEL := 30
## Kinh nghiệm cần để lên cấp tiếp theo = XP_BASE + XP_STEP x (cấp hiện tại - 1).
## Cấp 1 cần 10, cấp 2 cần 15, cấp 3 cần 20... (tổng: cấp 5 khoảng 70, cấp 10 khoảng 270, cấp 20 khoảng 1000, cấp 30 khoảng 2300)
const XP_BASE := 10
const XP_STEP := 5
## Mỗi lần lên cấp được thêm bao nhiêu
const LEVEL_HP := 8
const LEVEL_ATTACK := 1
## Bấm L để lên cấp ngay. Chỉ chạy khi mở game từ Godot (F5) để thử cho nhanh, bản xuất ra không có.
## Đổi thành false để tắt hẳn.
const TEST_LEVEL_KEY := true

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
var xp_to_next := XP_BASE
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
var dash_speed_now := 280.0
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

# --- Điều khiển bằng chuột ---
var level_ref: Level                 # màn chơi, dùng để tìm đường
var path := PackedVector2Array()     # các điểm cần đi qua
var path_index := 0
## Quái đang bị khóa mục tiêu (chuột phải vào quái). Giữ cho tới khi quái chết hoặc bấm chuột phải xuống đất.
var attack_target: Enemy = null:
	set(value):
		if attack_target != null and is_instance_valid(attack_target):
			attack_target.set_targeted(false)
		attack_target = value
		if value != null and is_instance_valid(value):
			value.set_targeted(true)
var hover_enemy: Enemy = null        # quái đang nằm dưới con trỏ chuột (có viền đỏ)
var aiming_skill := -1               # đang giữ phím Q W E R: hiện tầm kỹ năng, thả phím ra thì tung chiêu
var indicator: Node2D                # lớp vẽ vòng tầm đánh / tầm kỹ năng dưới chân
var repath_timer := 0.0
var stuck_timer := 0.0
var right_hold_timer := 0.0
var face_lock := 0.0                 # > 0: giữ hướng nhìn theo đòn đánh vừa tung
var mouse_attack_pressed := false
var bow_aim_mouse := false           # đang gồng cung bằng chuột (ngắm theo con trỏ)
var attack_move_armed := false       # đã bấm A, chờ bấm chuột trái
var attack_moving := false           # đang vừa đi vừa đánh (A + chuột trái)
var attack_move_dest := Vector2.ZERO
var scan_timer := 0.0

# --- Kỹ năng (Q W E R) ---
## Mỗi ô chỉ ghi id kỹ năng (xem scripts/skills.gd). Lúc vào game lấy bộ mặc định của vũ khí,
## sau này có thể đổi kỹ năng khác vào ô bằng equip_skill().
var skill_slots: Array[String] = ["", "", "", ""]
var skill_cd: Array[float] = [0.0, 0.0, 0.0, 0.0]   # thời gian hồi chiêu còn lại của từng ô
var skill_busy := 0.0                # > 0: đang tung kỹ năng nhiều đòn, chưa tung chiêu khác được
var lock_msg_cd := 0.0               # chống hiện chữ "chưa mở khóa" liên tục
var mouse_on_ui := false             # con trỏ đang ở trên bản đồ nhỏ / bảng giao diện: không đi theo chuột, không chọn quái dưới đó
var weapon_tween: Tween              # chuyển động của vũ khí đang vung
signal skills_changed

# --- Túi đồ (phím B) ---
var bag: Array = []                  # mỗi ô: {"id": String, "count": int}
var bag_slots := BAG_SLOTS_START     # số ô túi hiện có
var item_cd := 0.0
signal bag_changed

# --- Chế tạo (scripts/recipes.gd) ---
var upgrades := {}                   # đồ nâng cấp đã làm: { "bag": 1, "armor": 1, ... }
var regen_left := 0.0                # còn bao nhiêu giây hồi máu từ từ (súp nấm, canh xương)
var regen_rate := 0                  # máu hồi mỗi giây
var regen_tick := 0.0
var buff_attack := 0                 # tấn công đang được thuốc cộng thêm
var buff_attack_time := 0.0
var buff_speed := 0.0                # tốc độ chạy đang được thuốc cộng thêm
var buff_speed_time := 0.0
var cutscene_time := 0.0             # > 0: đang chuyển cảnh (đi qua hang), đứng yên

@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
var weapon_pivot: Node2D     # tâm xoay của vũ khí cầm tay
var weapon_sprite: Sprite2D
var hold_pivot: Node2D       # vũ khí cầm trong tay lúc không đánh
var book_sprite: Sprite2D    # sách phép bay lơ lửng cạnh người


func _ready() -> void:
	add_to_group("player")
	# Vòng tầm đánh / tầm kỹ năng: vẽ sát mặt đất, dưới mọi nhân vật
	indicator = Node2D.new()
	indicator.z_index = -5
	indicator.draw.connect(_draw_indicators)
	add_child(indicator)
	# Bóng dưới chân
	var shadow := Sprite2D.new()
	shadow.texture = SHADOW_TEXTURE
	shadow.position = Vector2(0, 7)
	add_child(shadow)
	move_child(shadow, 0)
	# Vũ khí khi vung đánh (chỉ hiện lúc đánh)
	weapon_pivot = Node2D.new()
	weapon_pivot.position = Vector2(0, -1)
	weapon_sprite = Sprite2D.new()
	weapon_sprite.offset = Vector2(6, 0)  # cán vũ khí nằm ở tâm xoay
	weapon_pivot.add_child(weapon_sprite)
	weapon_pivot.visible = false
	add_child(weapon_pivot)
	# Vũ khí cầm trong tay lúc đi / đứng
	hold_pivot = Node2D.new()
	hold_pivot.add_child(Sprite2D.new())
	add_child(hold_pivot)
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
	hold_pivot.visible = weapon != Weapons.Type.BOOK
	var defaults: Array = Weapons.info(weapon)["skills"]
	for i in mini(defaults.size(), skill_slots.size()):
		skill_slots[i] = defaults[i]
	add_item("potion_hp", 2)  # túi đồ khởi đầu


func _unhandled_input(event: InputEvent) -> void:
	if is_dead or cutscene_time > 0.0:
		return
	if event.is_action_pressed("move_click"):
		aiming_skill = -1        # chuột phải: hủy ngắm kỹ năng (giống LMHT)
		attack_move_armed = false
		attack_moving = false
		_command_at_mouse()
		right_hold_timer = 0.2
	elif event.is_action_pressed("attack_mouse"):
		if attack_move_armed:
			attack_move_armed = false
			_attack_move(get_global_mouse_position())
		else:
			mouse_attack_pressed = true
	elif event.is_action_pressed("attack_move"):
		attack_move_armed = true
	elif event.is_action_pressed("stop"):
		attack_move_armed = false
		_clear_commands()
	elif event.is_action_pressed("use_item"):
		if level >= QUICK_ITEM_LEVEL:
			use_item("potion_hp")
		else:
			_locked_message("Phím D mở ở cấp %d. Giờ mở túi (B) bấm vào bình máu để uống" % QUICK_ITEM_LEVEL)
	elif event.is_action_pressed("test_level_up") and TEST_LEVEL_KEY and OS.is_debug_build():
		add_xp(xp_to_next - xp)
	else:
		for i in SKILL_ACTIONS.size():
			if event.is_action_pressed(SKILL_ACTIONS[i]):
				_start_aim(i)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_tick_timers(delta)
	if cutscene_time > 0.0:
		cutscene_time -= delta
		velocity = Vector2.ZERO
		return
	# Thả phím kỹ năng đang giữ: tung chiêu về phía con trỏ
	if aiming_skill != -1 and not Input.is_action_pressed(SKILL_ACTIONS[aiming_skill]):
		var skill_index := aiming_skill
		aiming_skill = -1
		_cast_skill(skill_index)

	# Phím mũi tên (nếu dùng) được ưu tiên và hủy lệnh chuột đang làm
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_dir := input
	if input != Vector2.ZERO:
		_clear_commands()
	else:
		# Giữ chuột phải trên mặt đất: liên tục đi theo con trỏ
		if Input.is_action_pressed("move_click") and attack_target == null and not mouse_on_ui:
			right_hold_timer -= delta
			if right_hold_timer <= 0.0:
				right_hold_timer = 0.12
				_move_to(get_global_mouse_position())
		move_dir = _follow_commands(delta)
	if move_dir != Vector2.ZERO and face_lock <= 0.0:
		facing = move_dir.normalized()

	if dash_timer > 0.0:
		velocity = dash_dir * dash_speed_now
	else:
		var slow := 0.35 if swing_time > 0.0 else (0.45 if charging else 1.0)
		var speed := move_speed * slow
		var target := move_dir.limit_length(1.0) * speed
		var rate := acceleration if move_dir != Vector2.ZERO else friction
		velocity = velocity.move_toward(target, rate * delta) + knockback
		knockback = Vector2.ZERO
	move_and_slide()
	_check_stuck(delta, move_dir)

	if Input.is_action_just_pressed("dash"):
		_try_dash(input)
	var mouse_attack := mouse_attack_pressed
	mouse_attack_pressed = false
	if weapon == Weapons.Type.BOW:
		_handle_bow(delta, mouse_attack)
	elif Input.is_action_just_pressed("attack") or mouse_attack:
		if mouse_attack:
			# Chuột trái lên quái: đánh thẳng vào quái đó
			var aim_enemy: Enemy = hover_enemy if hover_enemy != null and is_instance_valid(hover_enemy) else null
			_aim_at(aim_enemy.global_position if aim_enemy != null else get_global_mouse_position())
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

	_update_visual(delta, move_dir)


func _process(delta: float) -> void:
	# Rê chuột lên quái: quái có viền đỏ, hiện thanh máu, con trỏ đổi thành hình kiếm (giống LMHT)
	var hovered: Enemy = null if (is_dead or mouse_on_ui) else _enemy_at(get_global_mouse_position())
	if hovered != hover_enemy:
		if hover_enemy != null and is_instance_valid(hover_enemy):
			hover_enemy.set_highlight(false)
		hover_enemy = hovered
		if hovered != null:
			hovered.set_highlight(true)
	Game.set_attack_cursor(not is_dead and (attack_move_armed or hovered != null))
	indicator.queue_redraw()
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
		book_sprite.position = Vector2(side * 11.0, -10.0 + sin(book_time * 3.0) * 1.5)
		book_sprite.rotation = sin(book_time * 2.0) * 0.12
	queue_redraw()


## Vẽ thanh gồng cung dưới chân và mũi tên đỏ trên đầu quái đang bị chỉ định tấn công.
func _draw() -> void:
	if attack_target != null and is_instance_valid(attack_target) and not attack_target.is_dead:
		var top := to_local(attack_target.global_position) + Vector2(0, -attack_target.hit_radius - 10.0)
		var bounce := sin(Time.get_ticks_msec() / 120.0) * 1.5
		var tri := PackedVector2Array([top + Vector2(-4, bounce - 4), top + Vector2(4, bounce - 4), top + Vector2(0, bounce + 1)])
		draw_colored_polygon(tri, Color(1.0, 0.25, 0.2))
		draw_polyline(PackedVector2Array([tri[0], tri[1], tri[2], tri[0]]), Color(0.2, 0.05, 0.05), 1.0)
	if not charging:
		return
	var max_t: float = Weapons.info(Weapons.Type.BOW)["charge_time"]
	var k := clampf(charge_time / max_t, 0.0, 1.0)
	var rect := Rect2(-9, 11, 18, 3)
	draw_rect(rect, Color(0.05, 0.05, 0.1, 0.8))
	var fill := Color(1.0, 0.85, 0.3) if k < 1.0 else Color(1.0, 1.0, 1.0)
	draw_rect(Rect2(rect.position + Vector2(1, 1), Vector2((rect.size.x - 2) * k, 1)), fill)


## Vòng tầm đánh (khi bấm A) và vùng ảnh hưởng của kỹ năng đang ngắm (khi giữ Q W E R).
func _draw_indicators() -> void:
	if is_dead:
		return
	if attack_move_armed:
		var reach := float(Weapons.info(weapon)["auto_range"]) + 10.0
		_draw_zone_circle(Vector2.ZERO, reach, Color(1.0, 0.6, 0.3))
	if aiming_skill == -1:
		return
	var s := slot_skill(aiming_skill)
	if s.is_empty():
		return
	var color := Color(0.5, 0.8, 1.0)
	var dir := _mouse_dir()
	var to_mouse := get_global_mouse_position() - global_position
	if s.has("range"):
		# Chiêu chọn chỗ: vòng tầm tối đa + vòng nổ ở chỗ con trỏ
		var max_range := float(s["range"])
		_draw_zone_circle(Vector2.ZERO, max_range, color, 0.04)
		var spot := to_mouse.limit_length(max_range)
		_draw_zone_circle(spot, float(s.get("radius", 8.0)), color, 0.22)
	elif s.has("radius") or s.has("finisher_radius"):
		# Chiêu quanh người
		_draw_zone_circle(Vector2.ZERO, float(s.get("radius", s.get("finisher_radius", 32.0))), color, 0.18)
	elif s.has("arc"):
		# Chém vòng cung phía trước
		var reach := float(s.get("reach", 30.0)) + 8.0
		var half := deg_to_rad(float(s["arc"])) / 2.0
		var points := PackedVector2Array([Vector2.ZERO])
		for k in 17:
			points.append(dir.rotated(-half + half * 2.0 * k / 16.0) * reach)
		indicator.draw_colored_polygon(points, Color(color, 0.2))
		points.append(Vector2.ZERO)
		indicator.draw_polyline(points, Color(color, 0.7), 1.0)
	else:
		# Lướt / đâm / bắn thẳng: một dải theo hướng con trỏ (Lùi Bắn thì lùi ngược lại)
		var length := float(s.get("distance", s.get("reach", 150.0)))
		var line_dir := -dir if str(s["cast"]).contains("backstep") else dir
		var side := line_dir.orthogonal() * 6.0
		var end := line_dir * length
		var rect := PackedVector2Array([side, end + side, end - side, -side])
		indicator.draw_colored_polygon(rect, Color(color, 0.2))
		rect.append(side)
		indicator.draw_polyline(rect, Color(color, 0.7), 1.0)


func _draw_zone_circle(center: Vector2, radius: float, color: Color, fill_alpha: float = 0.08) -> void:
	indicator.draw_circle(center, radius, Color(color, fill_alpha))
	indicator.draw_arc(center, radius, 0.0, TAU, 40, Color(color, 0.7), 1.0)


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
	face_lock = maxf(face_lock - delta, 0.0)
	skill_busy = maxf(skill_busy - delta, 0.0)
	item_cd = maxf(item_cd - delta, 0.0)
	lock_msg_cd = maxf(lock_msg_cd - delta, 0.0)
	_tick_regen(delta)
	_tick_buffs(delta)
	for i in skill_cd.size():
		skill_cd[i] = maxf(skill_cd[i] - delta, 0.0)
	mp = minf(mp + MANA_REGEN * delta, float(max_mp))


# ---------------------------------------------------------------- Hành động

func _try_dash(input: Vector2) -> void:
	if dash_cd > 0.0 or dash_timer > 0.0:
		return
	# Đang bấm phím hướng thì lướt theo phím, không thì lướt về phía con trỏ chuột
	var to_mouse := get_global_mouse_position() - global_position
	if input != Vector2.ZERO:
		dash_dir = input.normalized()
	elif to_mouse.length() > 4.0:
		dash_dir = to_mouse.normalized()
	else:
		dash_dir = facing
	facing = dash_dir
	dash_speed_now = dash_speed
	_clear_commands()
	dash_timer = dash_time
	dash_cd = dash_cooldown
	ghost_timer = 0.0
	Game.dust(global_position + Vector2(0, 7), 8)


# ---------------------------------------------------------------- Điều khiển bằng chuột

## Chuột phải: bấm lên quái thì chỉ định tấn công, bấm lên đất thì đi tới đó.
func _command_at_mouse() -> void:
	var mouse := get_global_mouse_position()
	var enemy := _enemy_at(mouse)
	if enemy != null:
		attack_target = enemy
		path = PackedVector2Array()
		repath_timer = 0.0
		_spawn_marker(enemy.global_position, Color(1.0, 0.3, 0.25))
	else:
		attack_target = null
		_move_to(mouse)
		_spawn_marker(mouse, Color(0.45, 1.0, 0.5))


## Quái gần con trỏ chuột nhất (nếu con trỏ đang nằm trên một con quái).
## Vùng bấm rộng hơn hình quái một chút (xem Enemy.is_under_mouse) cho dễ chọn quái đang chạy.
func _enemy_at(pos: Vector2) -> Enemy:
	var best: Enemy = null
	var best_dist := INF
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.is_dead or not enemy.is_under_mouse(pos):
			continue
		var d := enemy.global_position.distance_to(pos)
		if d < best_dist:
			best = enemy
			best_dist = d
	return best


## Đi tới chỗ world_pos (bấm trên bản đồ nhỏ). show_marker: hiện dấu xanh chỗ đến.
func command_move(world_pos: Vector2, show_marker: bool = true) -> void:
	if is_dead or cutscene_time > 0.0:
		return
	attack_target = null
	attack_move_armed = false
	attack_moving = false
	_move_to(world_pos)
	if show_marker:
		_spawn_marker(world_pos, Color(0.45, 1.0, 0.5))


func _move_to(target: Vector2) -> void:
	if level_ref != null:
		path = level_ref.find_path(global_position, target)
	else:
		path = PackedVector2Array([target])
	path_index = 0
	stuck_timer = 0.0


func _clear_commands() -> void:
	path = PackedVector2Array()
	path_index = 0
	attack_target = null
	attack_moving = false


## A + chuột trái: đi tới chỗ bấm, gặp quái ở gần thì tự đánh rồi đi tiếp.
func _attack_move(pos: Vector2) -> void:
	var enemy := _enemy_at(pos)
	_clear_commands()
	if enemy != null:
		attack_target = enemy
		_spawn_marker(enemy.global_position, Color(1.0, 0.3, 0.25))
		return
	attack_moving = true
	attack_move_dest = pos
	scan_timer = 0.0
	_move_to(pos)
	_spawn_marker(pos, Color(1.0, 0.55, 0.25))


## Quái còn sống gần người chơi nhất trong bán kính radius.
func _nearest_enemy(radius: float) -> Enemy:
	var best: Enemy = null
	var best_dist := radius
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.is_dead:
			continue
		var d := enemy.global_position.distance_to(global_position)
		if d < best_dist:
			best = enemy
			best_dist = d
	return best


func _spawn_marker(pos: Vector2, color: Color) -> void:
	var marker := CLICK_MARKER.new()
	marker.color = color
	if level_ref != null:
		level_ref.add_ground_effect(marker, pos)
	else:
		marker.global_position = pos
		get_parent().add_child(marker)


## Trả về hướng cần đi theo lệnh chuột (độ dài < 1 khi sắp tới nơi để dừng mượt).
func _follow_commands(delta: float) -> Vector2:
	# Đang vừa đi vừa đánh: tìm quái ở gần
	if attack_moving and attack_target == null:
		scan_timer -= delta
		if scan_timer <= 0.0:
			scan_timer = 0.2
			var near := _nearest_enemy(80.0)
			if near != null:
				attack_target = near
	if attack_target != null:
		if not is_instance_valid(attack_target) or attack_target.is_dead:
			attack_target = null
			if attack_moving:
				_move_to(attack_move_dest)  # đi tiếp tới chỗ đã bấm
			else:
				_clear_commands()
			return Vector2.ZERO
		var to_target := attack_target.global_position - global_position
		var reach: float = float(Weapons.info(weapon)["auto_range"]) + attack_target.hit_radius
		var can_see := weapon != Weapons.Type.BOW or level_ref == null \
			or level_ref.segment_clear(global_position, attack_target.global_position, 2.0)
		if to_target.length() <= reach and can_see:
			# Đã tới tầm: đứng lại và tự đánh
			path = PackedVector2Array()
			if not charging:
				facing = to_target.normalized()
				if attack_cd <= 0.0 and swing_time <= 0.0:
					_auto_attack(to_target.normalized())
			return Vector2.ZERO
		# Chưa tới tầm: đuổi theo (tìm đường lại vì quái di chuyển)
		repath_timer -= delta
		if repath_timer <= 0.0 or path_index >= path.size():
			repath_timer = 0.3
			_move_to(attack_target.global_position)
	if path_index >= path.size():
		attack_moving = false
		return Vector2.ZERO
	var to_point := path[path_index] - global_position
	var last := path_index == path.size() - 1
	if to_point.length() <= (2.0 if last else 6.0):
		path_index += 1
		if path_index >= path.size():
			path = PackedVector2Array()
			return Vector2.ZERO
		to_point = path[path_index] - global_position
		last = path_index == path.size() - 1
	if last and to_point.length() < 10.0:
		return to_point / 10.0  # chậm lại khi sắp tới
	return to_point.normalized()


## Bị kẹt (ví dụ quái chắn đường) quá lâu thì bỏ lệnh đi.
func _check_stuck(delta: float, move_dir: Vector2) -> void:
	if path.is_empty() or move_dir == Vector2.ZERO or dash_timer > 0.0:
		stuck_timer = 0.0
		return
	if get_real_velocity().length() < move_speed * 0.15:
		stuck_timer += delta
		if stuck_timer > 0.6:
			stuck_timer = 0.0
			if attack_target != null:
				repath_timer = 0.0  # thử tìm đường khác tới quái
			else:
				path = PackedVector2Array()
	else:
		stuck_timer = 0.0


func _aim_at(pos: Vector2) -> void:
	var dir := pos - global_position
	if dir.length() > 1.0:
		facing = dir.normalized()
		face_lock = 0.25


## Đòn đánh tự động khi đã tới gần quái được chỉ định.
func _auto_attack(dir: Vector2) -> void:
	facing = dir
	face_lock = 0.25
	if weapon == Weapons.Type.BOW:
		_fire_arrow(dir, 0.0)
	else:
		_try_attack()


# ---------------------------------------------------------------- Kỹ năng vũ khí (Q W E R)

## Đặt kỹ năng id vào ô slot (0 = Q, 1 = W, 2 = E, 3 = R).
## Trả về false nếu vũ khí đang cầm không dùng được kỹ năng đó, hoặc sai loại ô
## (tuyệt chiêu chỉ vào ô R). Dùng cho tính năng đội kỹ năng sau này (kỹ năng nguyên tố...).
func equip_skill(slot: int, id: String) -> bool:
	if slot < 0 or slot >= skill_slots.size() or not Skills.can_equip(id, weapon, slot):
		return false
	skill_slots[slot] = id
	skills_changed.emit()
	return true


## Thông số kỹ năng đang đặt ở ô slot ({} nếu ô trống).
func slot_skill(slot: int) -> Dictionary:
	if slot < 0 or slot >= skill_slots.size():
		return {}
	return Skills.info(skill_slots[slot])


## Cấp cần để dùng kỹ năng id: kỹ năng thứ 1, 2, 3, 4 của vũ khí mở ở cấp 5, 10, 15, 20.
func skill_unlock_level(id: String) -> int:
	var defaults: Array = Weapons.info(weapon)["skills"]
	var index := defaults.find(id)
	if index < 0 or index >= SKILL_UNLOCK_LEVELS.size():
		return 1
	return SKILL_UNLOCK_LEVELS[index]


func is_slot_unlocked(slot: int) -> bool:
	if slot < 0 or slot >= skill_slots.size():
		return false
	return level >= skill_unlock_level(skill_slots[slot])


## Đã mở hết kỹ năng (cấp 20) thì được đổi thứ tự kỹ năng.
func can_reorder_skills() -> bool:
	return level >= SKILL_UNLOCK_LEVELS[SKILL_UNLOCK_LEVELS.size() - 1]


## Đổi chỗ hai kỹ năng ở ô a và ô b (0 = Q, 1 = W, 2 = E, 3 = R). Thời gian hồi chiêu đi theo kỹ năng.
func swap_skills(a: int, b: int) -> bool:
	if not can_reorder_skills() or a == b:
		return false
	if a < 0 or b < 0 or a >= skill_slots.size() or b >= skill_slots.size():
		return false
	var id := skill_slots[a]
	skill_slots[a] = skill_slots[b]
	skill_slots[b] = id
	var cd := skill_cd[a]
	skill_cd[a] = skill_cd[b]
	skill_cd[b] = cd
	aiming_skill = -1
	skills_changed.emit()
	return true


## Trả kỹ năng về thứ tự mặc định của vũ khí (Q W E R như lúc đầu).
func reset_skill_order() -> void:
	var defaults: Array = Weapons.info(weapon)["skills"]
	var old_cd := {}
	for i in skill_slots.size():
		old_cd[skill_slots[i]] = skill_cd[i]
	for i in mini(defaults.size(), skill_slots.size()):
		skill_slots[i] = defaults[i]
		skill_cd[i] = float(old_cd.get(defaults[i], 0.0))
	aiming_skill = -1
	skills_changed.emit()


func _locked_message(text: String) -> void:
	if lock_msg_cd > 0.0:
		return
	lock_msg_cd = 1.2
	Game.popup_text(global_position + Vector2(0, -22), text, Color(0.85, 0.85, 0.9), 9)


## Tung kỹ năng ở ô index (0 = Q, 1 = W, 2 = E, 3 = R), nhắm theo con trỏ chuột.
## Ô chỉ ghi id kỹ năng. Thông số nằm ở scripts/skills.gd, còn cách hoạt động là
## hàm có tên ghi ở "cast" (các hàm _skill_... bên dưới).
## Bấm phím kỹ năng: bắt đầu ngắm (hiện tầm kỹ năng). Thả phím ra thì tung chiêu.
func _start_aim(index: int) -> void:
	if aiming_skill != -1 and aiming_skill != index:
		var held := aiming_skill   # đang ngắm chiêu khác: tung chiêu đó trước
		aiming_skill = -1
		_cast_skill(held)
	if index >= skill_slots.size() or slot_skill(index).is_empty():
		return
	if not is_slot_unlocked(index):
		_locked_message("%s: mở ở cấp %d" % [slot_skill(index)["name"], skill_unlock_level(skill_slots[index])])
		return
	if skill_cd[index] > 0.0:
		return
	aiming_skill = index


func _cast_skill(index: int) -> void:
	if is_dead or skill_busy > 0.0 or dash_timer > 0.0 or charging:
		return
	if index >= skill_slots.size() or skill_cd[index] > 0.0 or not is_slot_unlocked(index):
		return
	var s := slot_skill(index)
	if s.is_empty() or not has_method(s["cast"]):
		return
	var dir := _mouse_dir()
	facing = dir
	face_lock = 0.3
	skill_cd[index] = s["cooldown"]
	if s["ult"]:
		Game.popup_text(global_position + Vector2(0, -26), s["name"] + "!", Color(1.0, 0.85, 0.3), 11)
	call(s["cast"], dir, int(attack * float(s["power"])), s)


# --- Kiếm

## Triple Slash: 3 nhát chém vòng cung liên tiếp về phía trước.
func _skill_triple_slash(dir: Vector2, damage: int, s: Dictionary) -> void:
	var hits := int(s["hits"])
	var gap := 0.13
	_busy(gap * hits)
	swing_time = gap * hits
	for i in hits:
		if is_dead:
			return
		var last := i == hits - 1
		face_lock = 0.25
		knockback = dir * 55.0  # nhích người về trước mỗi nhát
		var reach := float(s["reach"]) + (5.0 if last else 0.0)
		var dmg := int(damage * 1.3) if last else damage
		var color := Color(1.0, 0.85, 0.4) if last else Color(1.0, 1.0, 0.85)
		if _arc_slash(dir, reach, s["arc"], dmg, 140.0 if last else 90.0, i % 2 == 1, color):
			Game.hit_stop(0.05 if last else 0.03)
			Game.shake(2.5 if last else 1.5)
		if not last:
			await get_tree().create_timer(gap).timeout


## Piercing Thrust: lao về trước, kiếm chĩa thẳng, đâm xuyên mọi quái trên đường.
func _skill_piercing_thrust(dir: Vector2, damage: int, s: Dictionary) -> void:
	var w := Weapons.info(weapon)
	_dash_toward(dir, s["distance"], 380.0)
	_busy(dash_timer + 0.1)
	face_lock = dash_timer + 0.15
	_show_weapon(w["texture"], dir.y < -0.5)
	weapon_pivot.rotation = dir.angle()
	weapon_sprite.position = Vector2(6, 0)
	var already_hit: Array = []
	var last_pos := global_position
	while dash_timer > 0.0 and not is_dead:
		await get_tree().physics_frame
		var tip := global_position + dir * 14.0
		if _damage_line_once(last_pos, tip, 16.0, damage, 150.0, already_hit,
				w["armor_pierce"], w["armor_break"]) > 0:
			Game.shake(2.0)
			Game.hit_stop(0.03)
		last_pos = global_position
	weapon_pivot.visible = false
	if is_dead:
		return
	var slash := SLASH_EFFECT.new()
	slash.radius = 18.0
	slash.arc = 0.6
	slash.rotation = dir.angle()
	slash.position = Vector2(0, -1)
	add_child(slash)


## Whirlwind Slash: xoay người chém một vòng 360°.
func _skill_whirlwind(_dir: Vector2, damage: int, s: Dictionary) -> void:
	_busy(0.2)
	swing_time = 0.2
	_spin_slash(s["radius"], damage, 170.0, Color(1.0, 1.0, 0.85))


## Swordstorm: 7 nhát chém cực nhanh, nhát cuối chém mạnh diện rộng.
func _skill_swordstorm(dir: Vector2, damage: int, s: Dictionary) -> void:
	var hits := int(s["hits"])
	var gap := 0.075
	var total := gap * hits + 0.3
	_busy(total)
	swing_time = total
	for i in hits:
		if is_dead:
			return
		face_lock = 0.2
		var aim := dir.rotated(randf_range(-0.7, 0.7))
		if _arc_slash(aim, 34.0, 200.0, damage, 50.0, i % 2 == 1, Color(1.0, 0.95, 0.7)):
			Game.shake(1.5)
		knockback = dir * 20.0
		await get_tree().create_timer(gap).timeout
	if is_dead:
		return
	# Nhát cuối: chém một vòng thật rộng
	var big := int(attack * float(s["finisher_power"]))
	var radius := float(s["finisher_radius"])
	_spin_slash(radius, big, 280.0, Color(1.0, 0.8, 0.35))
	var ring := RING_EFFECT.new()
	ring.max_radius = radius
	ring.color = Color(1.0, 0.85, 0.4)
	ring.global_position = global_position
	get_parent().add_child(ring)
	Game.burst(global_position + Vector2(0, -4), Color(1.0, 0.9, 0.5), 18, 90.0, 0.0, 0.4, 2.0)
	Game.shake(5.0)
	Game.hit_stop(0.09)


# --- Cung

## Double Shot: bắn nhanh 2 mũi tên. Rê chuột lên quái để nhắm thẳng vào con đó.
func _skill_double_shot(dir: Vector2, damage: int, s: Dictionary) -> void:
	var target := _enemy_at(get_global_mouse_position())
	var arrows := int(s["arrows"])
	var gap := 0.12
	_busy(gap * arrows)
	for i in arrows:
		if is_dead:
			return
		var aim := dir
		if target != null and is_instance_valid(target) and not target.is_dead:
			aim = (target.global_position - global_position).normalized()
		facing = aim
		face_lock = 0.25
		_skill_arrow(aim, 320.0, damage)
		if i < arrows - 1:
			await get_tree().create_timer(gap).timeout


## Piercing Arrow: kéo căng cung một chút rồi bắn mũi tên xuyên qua mọi quái trên đường thẳng.
func _skill_piercing_arrow(dir: Vector2, damage: int, s: Dictionary) -> void:
	var w := Weapons.info(weapon)
	var draw_time := float(s["draw_time"])
	_busy(draw_time + 0.15)
	swing_time = draw_time
	face_lock = draw_time + 0.2
	_show_weapon(w["texture"], dir.y < -0.5)
	weapon_pivot.rotation = dir.angle()
	weapon_sprite.position = Vector2(2, 0)
	weapon_sprite.modulate = Color(1.6, 1.4, 0.8)
	Game.burst(global_position + dir * 10.0, Color(1.0, 0.9, 0.5), 8, 30.0, 0.0, 0.3, 1.5)
	await get_tree().create_timer(draw_time).timeout
	if is_dead:
		return
	var aim := _mouse_dir()  # ngắm lại theo con trỏ lúc thả dây
	facing = aim
	face_lock = 0.25
	weapon_pivot.rotation = aim.angle()
	var p := _shoot(aim, 430.0, damage, w["arrow"], Color(1.0, 0.85, 0.4), global_position + Vector2(0, -1), 1.4)
	p.pierce = 99
	p.heavy = true
	p.life = 0.9
	p.modulate = Color(1.6, 1.3, 0.7)
	knockback = -aim * 50.0
	Game.shake(2.5)
	var tw := _weapon_tween()
	tw.tween_interval(0.15)
	tw.tween_callback(func(): weapon_pivot.visible = false)


## Backstep Shot: lùi nhanh ra sau, vừa lùi vừa bắn 3 mũi tên về phía con trỏ.
func _skill_backstep_shot(dir: Vector2, damage: int, s: Dictionary) -> void:
	_dash_toward(-dir, s["distance"], 320.0)
	var arrows := int(s["arrows"])
	_busy(dash_timer + 0.1)
	for i in arrows:
		if is_dead:
			return
		var aim := _mouse_dir()
		facing = aim
		face_lock = 0.3
		var spread := (i - (arrows - 1) / 2.0) * deg_to_rad(9.0)
		_skill_arrow(aim.rotated(spread), 300.0, damage)
		if i < arrows - 1:
			await get_tree().create_timer(0.06).timeout


## Rain of Arrows: trút mưa tên xuống vùng quanh con trỏ.
func _skill_rain_of_arrows(dir: Vector2, damage: int, s: Dictionary) -> void:
	_busy(0.2)
	_bow_pose(dir)
	_area_strike(_target_point(s["range"]), s["radius"], 0.25, s["ticks"], 0.15, damage,
		Color(1.0, 0.9, 0.5), "rain")


## Bắn 1 mũi tên kỹ năng (giương cung lên một chút).
func _skill_arrow(dir: Vector2, speed: float, damage: int) -> Projectile:
	var w := Weapons.info(weapon)
	_bow_pose(dir)
	var p := _shoot(dir, speed, damage, w["arrow"], Color(0.9, 0.85, 0.75), global_position + Vector2(0, -1))
	p.life = 0.8
	return p


# --- Thương

## Spear Thrust: đâm cực nhanh một đường thẳng dài.
func _skill_spear_thrust(dir: Vector2, damage: int, s: Dictionary) -> void:
	var w := Weapons.info(weapon)
	_busy(0.2)
	_thrust_visual(26.0)
	knockback = dir * 60.0
	var end := global_position + dir * float(s["reach"])
	_line_burst(global_position, end, Color(1.0, 1.0, 0.85))
	if _damage_line(global_position, end, 12.0, damage, 180.0, w["armor_pierce"], w["armor_break"]) > 0:
		Game.hit_stop(0.06)
		Game.shake(2.5)


## Sweeping Strike: quét thương ngang một nửa vòng phía trước.
func _skill_sweeping_strike(dir: Vector2, damage: int, s: Dictionary) -> void:
	var w := Weapons.info(weapon)
	var half := deg_to_rad(float(s["arc"])) / 2.0
	_busy(0.22)
	swing_time = 0.2
	_show_weapon(w["texture"], dir.y < -0.5)
	weapon_pivot.rotation = dir.angle() - half
	var tw := _weapon_tween()
	tw.tween_property(weapon_pivot, "rotation", dir.angle() + half, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func(): weapon_pivot.visible = false)
	var slash := SLASH_EFFECT.new()
	slash.radius = float(s["reach"]) - 4.0
	slash.arc = half
	slash.rotation = dir.angle()
	slash.position = Vector2(0, -1)
	add_child(slash)
	if _hit_cone(s["reach"], s["arc"], damage, 230.0, w["armor_pierce"], w["armor_break"]):
		Game.hit_stop(0.05)
		Game.shake(2.0)


## Impaling Charge: lao tới, đâm trúng con quái đầu tiên thì dừng lại, đẩy lùi và làm choáng nó.
func _skill_impaling_charge(dir: Vector2, damage: int, s: Dictionary) -> void:
	var w := Weapons.info(weapon)
	_dash_toward(dir, s["distance"], 340.0)
	_busy(dash_timer + 0.25)
	face_lock = dash_timer + 0.3
	_show_weapon(w["texture"], dir.y < -0.5)
	weapon_pivot.rotation = dir.angle()
	weapon_sprite.position = Vector2(4, 0)
	var victim: Enemy = null
	while dash_timer > 0.0 and not is_dead:
		await get_tree().physics_frame
		victim = _enemy_near(global_position + dir * 12.0, 8.0)
		if victim != null:
			dash_timer = 0.0  # đâm trúng thì dừng lại ngay
			velocity = Vector2.ZERO
			break
	if is_dead:
		return
	_thrust_visual(16.0)
	var push := float(s["push"])
	var end := global_position + dir * 34.0
	if _damage_line(global_position, end, 16.0, damage, push, w["armor_pierce"], w["armor_break"]) > 0:
		Game.hit_stop(0.08)
		Game.shake(4.0)
		Game.burst(end, Color(1.0, 1.0, 0.85), 10, 60.0, 0.0, 0.3, 2.0)
	if victim != null and is_instance_valid(victim) and not victim.is_dead:
		victim.stun(0.6)


## Heaven's Spear: lấy đà, nhảy lên rồi giáng thương xuống đất, gây sát thương diện rộng.
func _skill_heavens_spear(_dir: Vector2, damage: int, s: Dictionary) -> void:
	var w := Weapons.info(weapon)
	var target := _target_point(s["range"])
	var windup := 0.22
	var air := 0.45
	_busy(windup + air + 0.25)
	_clear_commands()
	swing_time = windup
	face_lock = windup + air + 0.3
	# Lấy đà: thụp người xuống
	var tw := create_tween()
	tw.tween_property(sprite, "scale", Vector2(1.15, 0.82), windup)
	Game.dust(global_position + Vector2(0, 7), 6)
	await get_tree().create_timer(windup).timeout
	if is_dead:
		sprite.scale = Vector2.ONE
		return
	sprite.scale = Vector2.ONE
	# Nhảy lên cao về phía con trỏ (đang trên không thì không bị trúng đòn)
	var to_target := target - global_position
	var dist := maxf(to_target.length(), 1.0)
	var jump_dir := to_target.normalized() if to_target.length() > 1.0 else facing
	_dash_toward(jump_dir, dist, dist / air)
	_show_weapon(w["texture"], false)
	weapon_pivot.rotation = PI / 2.0  # mũi thương chĩa xuống đất
	weapon_sprite.position = Vector2(-6, 0)
	var jump := create_tween().set_parallel(true)
	jump.tween_property(sprite, "position:y", -22.0, air * 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	jump.tween_property(weapon_pivot, "position:y", -23.0, air * 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	jump.chain().tween_property(sprite, "position:y", 0.0, air * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	jump.tween_property(weapon_pivot, "position:y", -1.0, air * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(air).timeout
	sprite.position.y = 0.0
	weapon_pivot.position = Vector2(0, -1)
	if is_dead:
		return
	# Tiếp đất: cắm thương xuống
	var stab := _weapon_tween()
	stab.tween_property(weapon_sprite, "position:x", 8.0, 0.06)
	stab.tween_interval(0.25)
	stab.tween_callback(func(): weapon_pivot.visible = false)
	var radius := float(s["radius"])
	var ring := RING_EFFECT.new()
	ring.max_radius = radius
	ring.color = Color(1.0, 0.9, 0.6)
	ring.global_position = global_position
	get_parent().add_child(ring)
	Game.dust(global_position + Vector2(0, 7), 16)
	Game.burst(global_position, Color(1.0, 0.95, 0.7), 20, 110.0, 0.0, 0.45, 2.0)
	Game.shake(6.0)
	if _damage_circle(global_position, radius, damage, 260.0, 1.0, 3) > 0:
		Game.hit_stop(0.1)


# --- Sách phép (tạm thời, sau này thay bằng phép nguyên tố)

func _skill_book_orb(dir: Vector2, damage: int, _s: Dictionary) -> void:
	_book_flash()
	var p := _shoot(dir, 200.0, damage, ARCANE_TEXTURE, Color(0.75, 0.55, 1.0), book_sprite.global_position, 1.8)
	p.pierce = 1


func _skill_book_nova(_dir: Vector2, damage: int, s: Dictionary) -> void:
	_book_flash()
	var radius := float(s["radius"])
	var ring := RING_EFFECT.new()
	ring.max_radius = radius
	ring.color = Color(0.75, 0.55, 1.0)
	ring.global_position = global_position
	get_parent().add_child(ring)
	_damage_circle(global_position, radius, damage, 230.0)
	Game.shake(3.0)


func _skill_book_blink(_dir: Vector2, _damage: int, s: Dictionary) -> void:
	_blink(_target_point(s["range"]))


func _skill_book_meteor(_dir: Vector2, damage: int, s: Dictionary) -> void:
	_book_flash()
	_area_strike(_target_point(s["range"]), s["radius"], 0.7, 1, 0.1, damage,
		Color(0.75, 0.5, 1.0), "meteor", 1)


# --- Các hàm dùng chung cho kỹ năng

## Không cho đánh thường hay tung kỹ năng khác trong time giây (kỹ năng có nhiều đòn).
func _busy(time: float) -> void:
	skill_busy = maxf(skill_busy, time)
	if time > attack_cd:
		attack_cd = time
		last_attack_cooldown = maxf(time, 0.01)


## Tạo tween mới cho vũ khí đang vung, hủy tween cũ để 2 đòn liền nhau không giành nhau.
func _weapon_tween() -> Tween:
	if weapon_tween != null and weapon_tween.is_valid():
		weapon_tween.kill()
	weapon_tween = create_tween()
	return weapon_tween


func _mouse_dir() -> Vector2:
	var d := get_global_mouse_position() - global_position
	return d.normalized() if d.length() > 2.0 else facing


## Điểm con trỏ chuột, nhưng không xa người chơi quá max_dist.
func _target_point(max_dist: float) -> Vector2:
	return global_position + (get_global_mouse_position() - global_position).limit_length(max_dist)


## Con quái còn sống đầu tiên chạm vào vòng tròn (pos, radius).
func _enemy_near(pos: Vector2, radius: float) -> Enemy:
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy != null and not enemy.is_dead \
				and enemy.global_position.distance_to(pos) <= radius + enemy.hit_radius:
			return enemy
	return null


## Một nhát chém vòng cung về hướng dir (reverse = vung ngược chiều). Trả về true nếu trúng quái.
func _arc_slash(dir: Vector2, reach: float, arc_degrees: float, damage: int, push: float,
		reverse: bool, color: Color) -> bool:
	var w := Weapons.info(weapon)
	facing = dir
	var half := deg_to_rad(arc_degrees) / 2.0
	var from := dir.angle() - half
	var to := dir.angle() + half
	if reverse:
		var tmp := from
		from = to
		to = tmp
	_show_weapon(w["texture"], dir.y < -0.5)
	weapon_pivot.rotation = from
	var tw := _weapon_tween()
	tw.tween_property(weapon_pivot, "rotation", to, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.03)
	tw.tween_callback(func(): weapon_pivot.visible = false)
	var slash := SLASH_EFFECT.new()
	slash.radius = reach - 4.0
	slash.arc = minf(half, PI)
	slash.color = color
	slash.rotation = dir.angle()
	slash.position = Vector2(0, -1)
	add_child(slash)
	return _hit_cone(reach, arc_degrees, damage, push, w.get("armor_pierce", 0.0), w.get("armor_break", 0))


## Gây sát thương cho mọi quái trong vòng tròn. Trả về số quái trúng đòn.
func _damage_circle(center: Vector2, radius: float, damage: int, push: float,
		armor_pierce: float = 0.0, armor_break: int = 0) -> int:
	var hits := 0
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.is_dead:
			continue
		var to_enemy := enemy.global_position - center
		if to_enemy.length() <= radius + enemy.hit_radius:
			enemy.take_damage(roll_damage(damage), to_enemy.normalized() * push, armor_pierce, armor_break)
			hits += 1
	return hits


## Gây sát thương cho mọi quái nằm trên đoạn thẳng (rộng width pixel).
func _damage_line(from: Vector2, to: Vector2, width: float, damage: int, push: float,
		armor_pierce: float = 0.0, armor_break: int = 0) -> int:
	return _damage_line_once(from, to, width, damage, push, [], armor_pierce, armor_break)


## Giống _damage_line nhưng bỏ qua quái đã có trong already_hit (mỗi con chỉ trúng 1 lần).
func _damage_line_once(from: Vector2, to: Vector2, width: float, damage: int, push: float,
		already_hit: Array, armor_pierce: float = 0.0, armor_break: int = 0) -> int:
	var hits := 0
	var dir := (to - from).normalized() if to.distance_to(from) > 0.5 else facing
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.is_dead or already_hit.has(enemy):
			continue
		var closest := Geometry2D.get_closest_point_to_segment(enemy.global_position, from, to)
		if closest.distance_to(enemy.global_position) <= width * 0.5 + enemy.hit_radius:
			enemy.take_damage(roll_damage(damage), dir * push, armor_pierce, armor_break)
			already_hit.append(enemy)
			hits += 1
	return hits


func _line_burst(from: Vector2, to: Vector2, color: Color) -> void:
	for i in 6:
		Game.burst(from.lerp(to, i / 5.0), color, 3, 30.0, 0.0, 0.25, 1.5)


## Lướt nhanh theo hướng dir một quãng distance (không bị trúng đòn khi lướt).
func _dash_toward(dir: Vector2, distance: float, speed: float) -> void:
	dash_dir = dir.normalized()
	dash_speed_now = speed
	dash_timer = distance / speed
	ghost_timer = 0.0
	_clear_commands()
	Game.dust(global_position + Vector2(0, 7), 6)


## Vòng chém quanh người (Whirlwind Slash, nhát cuối của Swordstorm).
func _spin_slash(radius: float, damage: int, push: float, color: Color) -> void:
	if is_dead:
		return
	var w := Weapons.info(weapon)
	_show_weapon(w["texture"], false)
	weapon_pivot.rotation = facing.angle()
	var tw := _weapon_tween()
	tw.tween_property(weapon_pivot, "rotation", facing.angle() + TAU, 0.16)
	tw.tween_callback(func(): weapon_pivot.visible = false)
	var slash := SLASH_EFFECT.new()
	slash.radius = radius - 4.0
	slash.arc = PI
	slash.color = color
	slash.position = Vector2(0, -1)
	add_child(slash)
	if _damage_circle(global_position, radius, damage, push, w.get("armor_pierce", 0.0), w.get("armor_break", 0)) > 0:
		Game.hit_stop(0.04)
		Game.shake(2.0)


## Đâm vũ khí thẳng về phía trước rồi rút về.
func _thrust_visual(reach: float) -> void:
	var w := Weapons.info(weapon)
	_show_weapon(w["texture"], facing.y < -0.5)
	weapon_pivot.rotation = facing.angle()
	weapon_sprite.position = Vector2(-4, 0)
	var tw := _weapon_tween()
	tw.tween_property(weapon_sprite, "position:x", reach, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.08)
	tw.tween_property(weapon_sprite, "position:x", 0.0, 0.12)
	tw.tween_callback(func(): weapon_pivot.visible = false)
	swing_time = maxf(swing_time, 0.2)


## Giương cung về phía dir một chút (khi dùng kỹ năng cung).
func _bow_pose(dir: Vector2) -> void:
	var w := Weapons.info(weapon)
	_show_weapon(w["texture"], dir.y < -0.5)
	weapon_pivot.rotation = dir.angle()
	weapon_sprite.position = Vector2(2, 0)
	var tw := _weapon_tween()
	tw.tween_interval(0.2)
	tw.tween_callback(func(): weapon_pivot.visible = false)


func _area_strike(pos: Vector2, radius: float, delay: float, ticks: int, interval: float,
		damage: int, color: Color, style: String, armor_break: int = 0) -> void:
	var strike := AREA_STRIKE.new()
	strike.armor_break = armor_break
	strike.radius = radius
	strike.delay = delay
	strike.ticks = ticks
	strike.interval = interval
	strike.damage = damage
	strike.color = color
	strike.style = style
	if level_ref != null:
		level_ref.add_ground_effect(strike, pos)
	else:
		strike.global_position = pos
		get_parent().add_child(strike)


## Dịch chuyển tức thời tới target (lùi lại nếu chỗ đó là tường / cây).
func _blink(target: Vector2) -> void:
	var start := global_position
	var dest := target
	if level_ref != null:
		var dir := (target - start).normalized() if target.distance_to(start) > 1.0 else facing
		var tries := 0
		while not level_ref.can_teleport(start, dest) and tries < 20:
			dest -= dir * 5.0
			tries += 1
		if not level_ref.can_teleport(start, dest):
			dest = start
	Game.burst(start + Vector2(0, -6), Color(0.75, 0.55, 1.0), 14, 60.0, 0.0, 0.4, 1.8)
	_spawn_ghost()
	_clear_commands()
	global_position = dest
	Game.burst(dest + Vector2(0, -6), Color(0.85, 0.7, 1.0), 14, 60.0, 0.0, 0.4, 1.8)
	invuln = maxf(invuln, 0.2)


# ---------------------------------------------------------------- Túi đồ

## Cất vật phẩm vào túi. Trả về false nếu túi đầy.
func add_item(id: String, count: int = 1) -> bool:
	for slot in bag:
		if slot["id"] == id:
			slot["count"] += count
			bag_changed.emit()
			return true
	if bag.size() >= bag_slots:
		return false
	bag.append({"id": id, "count": count})
	bag_changed.emit()
	return true


func count_item(id: String) -> int:
	for slot in bag:
		if slot["id"] == id:
			return slot["count"]
	return 0


## Bỏ bớt vật phẩm khỏi túi (dùng khi chế tạo). Hết thì ô đó trống ra.
func remove_item(id: String, count: int = 1) -> void:
	for i in bag.size():
		if bag[i]["id"] == id:
			bag[i]["count"] -= count
			if bag[i]["count"] <= 0:
				bag.remove_at(i)
			bag_changed.emit()
			return


## Đồ nâng cấp làm ở bàn chế tạo: túi thêm ô, áo giáp thêm máu, bùa thêm tấn công.
func apply_upgrade(kind: String, amount: int) -> void:
	upgrades[kind] = int(upgrades.get(kind, 0)) + 1
	match kind:
		"bag":
			bag_slots = mini(bag_slots + amount, BAG_SLOTS_MAX)
			Game.popup_text(global_position + Vector2(0, -20), "Túi đồ: %d ô" % bag_slots, Color(1.0, 0.85, 0.5), 10)
			bag_changed.emit()
		"armor":
			max_hp += amount
			hp += amount
			Game.popup_text(global_position + Vector2(0, -20), "Máu tối đa +%d" % amount, Color(0.5, 1.0, 0.5), 10)
		"charm":
			add_attack(amount)


## Thuốc tăng sức mạnh / tốc độ trong một thời gian. buff = [loại, lượng, số giây].
func _apply_buff(buff: Array) -> void:
	var kind := str(buff[0])
	var secs := float(buff[2])
	match kind:
		"attack":
			attack -= buff_attack          # uống lại thì không cộng dồn, chỉ làm mới thời gian
			buff_attack = int(buff[1])
			attack += buff_attack
			buff_attack_time = secs
			Game.popup_text(global_position + Vector2(0, -20), "Tấn công +%d" % buff_attack, Color(1.0, 0.7, 0.3), 10)
		"speed":
			move_speed -= buff_speed
			buff_speed = move_speed * float(buff[1])
			move_speed += buff_speed
			buff_speed_time = secs
			Game.popup_text(global_position + Vector2(0, -20), "Chạy nhanh hơn!", Color(0.5, 1.0, 0.9), 10)


func _tick_buffs(delta: float) -> void:
	if buff_attack_time > 0.0:
		buff_attack_time -= delta
		if buff_attack_time <= 0.0:
			attack -= buff_attack
			buff_attack = 0
			Game.popup_text(global_position + Vector2(0, -20), "Hết thuốc sức mạnh", Color(0.8, 0.8, 0.8), 8)
	if buff_speed_time > 0.0:
		buff_speed_time -= delta
		if buff_speed_time <= 0.0:
			move_speed -= buff_speed
			buff_speed = 0.0
			Game.popup_text(global_position + Vector2(0, -20), "Hết thuốc nhanh nhẹn", Color(0.8, 0.8, 0.8), 8)


## Đứng yên một lúc (khi đi qua hang chuyển cảnh).
func stop_for_cutscene() -> void:
	_clear_commands()
	aiming_skill = -1
	velocity = Vector2.ZERO
	cutscene_time = 0.9


## Dịch chuyển tới chỗ mới (đi qua hang), camera theo ngay không trượt.
func teleport_to(world_pos: Vector2) -> void:
	global_position = world_pos
	velocity = Vector2.ZERO
	knockback = Vector2.ZERO
	_clear_commands()
	facing = Vector2.DOWN
	camera.position = Vector2.ZERO
	camera.reset_smoothing()


## Hồi máu từ từ: mỗi giây hồi regen_rate máu cho tới khi hết regen_left giây.
func _tick_regen(delta: float) -> void:
	if regen_left <= 0.0 or is_dead:
		return
	regen_left -= delta
	regen_tick -= delta
	if regen_tick <= 0.0:
		regen_tick = 1.0
		if hp < max_hp:
			heal(regen_rate)


## Dùng vật phẩm theo tên (phím D dùng "potion_hp").
func use_item(id: String) -> bool:
	for i in bag.size():
		if bag[i]["id"] == id:
			return use_bag_slot(i)
	if id == "potion_hp" and item_cd <= 0.0:
		item_cd = 0.5
		Game.popup_text(global_position + Vector2(0, -20), "Hết bình máu", Color(0.8, 0.8, 0.8), 9)
	return false


## Dùng vật phẩm ở ô thứ index trong túi.
func use_bag_slot(index: int) -> bool:
	if is_dead or item_cd > 0.0 or index < 0 or index >= bag.size():
		return false
	var id: String = bag[index]["id"]
	var data := Items.info(id)
	var msg_pos := global_position + Vector2(0, -20)
	if data.get("tool", false):
		Game.popup_text(msg_pos, "Công cụ: cứ để trong túi là dùng được", Color(0.8, 0.8, 0.8), 9)
		return false
	match id:
		"potion_mp":
			restore_mana(int(data["mana"]))
		_:
			if data.has("place"):
				# Bộ lửa trại: đặt xuống ngay trước mặt
				if level_ref == null:
					return false
				var err: String = level_ref.place_station(data["place"], global_position + facing * 14.0)
				if err != "":
					Game.popup_text(msg_pos, err, Color(1.0, 0.6, 0.5), 9)
					return false
			elif data.has("buff"):
				_apply_buff(data["buff"])
			elif data.has("heal_ratio"):
				# Bình máu: hồi theo % máu tối đa
				if hp >= max_hp:
					Game.popup_text(msg_pos, "Máu đang đầy", Color(0.8, 0.8, 0.8), 9)
					return false
				heal(roundi(max_hp * float(data["heal_ratio"])))
			elif not data.has("heal") and not data.has("regen"):
				Game.popup_text(msg_pos, "Nguyên liệu để chế tạo", Color(0.8, 0.8, 0.8), 9)
				return false
			# Đồ ăn (quả mọng, táo, thịt nướng...): hồi máu. Súp, canh: hồi máu từ từ
			elif hp >= max_hp:
				Game.popup_text(msg_pos, "Máu đang đầy", Color(0.8, 0.8, 0.8), 9)
				return false
			elif data.has("regen"):
				var regen: Array = data["regen"]
				regen_rate = int(regen[0])
				regen_left = float(regen[1])
				regen_tick = 0.0
				Game.popup_text(msg_pos, "Hồi máu từ từ", Color(0.6, 1.0, 0.6), 9)
			else:
				heal(int(data["heal"]))
	item_cd = ITEM_COOLDOWN
	bag[index]["count"] -= 1
	if bag[index]["count"] <= 0:
		bag.remove_at(index)
	bag_changed.emit()
	return true


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
	weapon_sprite.offset = Vector2(Weapons.info(weapon).get("grip", 6.0), 0)
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
	slash.position = Vector2(0, -1)
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
	var tw := _weapon_tween()
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
	var tw := _weapon_tween()
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
func _handle_bow(delta: float, mouse_pressed: bool) -> void:
	var w := Weapons.info(Weapons.Type.BOW)
	var key_pressed := Input.is_action_just_pressed("attack")
	if (key_pressed or mouse_pressed) and attack_cd <= 0.0 and not charging:
		charging = true
		charge_time = 0.0
		charge_full_notified = false
		bow_aim_mouse = mouse_pressed
	if not charging:
		return
	if bow_aim_mouse:
		_aim_at(get_global_mouse_position())  # ngắm theo con trỏ khi gồng
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
	var held := Input.is_action_pressed("attack_mouse") if bow_aim_mouse else Input.is_action_pressed("attack")
	if not held:
		charging = false
		_fire_arrow(facing, clampf(charge_time / float(w["charge_time"]), 0.0, 1.0))


## Bắn một mũi tên. charge từ 0 (bắn nhanh) tới 1 (gồng đầy).
func _fire_arrow(dir: Vector2, charge: float) -> void:
	var w := Weapons.info(Weapons.Type.BOW)
	var k := charge
	var full := k >= 1.0
	facing = dir
	face_lock = 0.2
	# Giương cung về phía bắn
	_show_weapon(w["texture"], facing.y < -0.5)
	weapon_pivot.rotation = facing.angle()
	weapon_sprite.position = Vector2(2, 0)
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
	p.global_position = global_position + Vector2(0, -1) + facing * 6.0
	get_parent().add_child(p)
	var tw := _weapon_tween()
	tw.tween_interval(0.12)
	tw.tween_callback(func(): weapon_pivot.visible = false)


# --- Sách phép: thiết kế trước, sức mạnh nguyên tố sẽ thêm sau
func _attack_book() -> void:
	var w := Weapons.info(Weapons.Type.BOOK)
	attack_cd = w["cooldown"]
	last_attack_cooldown = attack_cd
	_book_flash()
	_shoot(facing, w["bolt_speed"], int(attack * float(w["damage"])), ARCANE_TEXTURE,
		Color(0.75, 0.55, 1.0), book_sprite.global_position, 0.8)


## Sách phép nháy sáng khi niệm phép.
func _book_flash() -> void:
	Game.burst(book_sprite.global_position, Color(0.75, 0.55, 1.0), 8, 35.0, -20.0, 0.4, 1.5)
	var tw := create_tween()
	tw.tween_property(book_sprite, "scale", Vector2.ONE * 1.0, 0.08)
	tw.tween_property(book_sprite, "scale", Vector2.ONE * 0.75, 0.15)


## Bắn một viên đạn của người chơi, trả về viên đạn để chỉnh thêm (xuyên, phá giáp...).
func _shoot(dir: Vector2, speed: float, damage: int, texture: Texture2D, color: Color,
		from: Vector2, scale_mult: float = 1.0) -> Projectile:
	var p := PROJECTILE_SCENE.instantiate() as Projectile
	p.setup(dir, speed, roll_damage(damage), true, texture, color)
	p.global_position = from + dir * 4.0
	p.scale = Vector2.ONE * scale_mult
	get_parent().add_child(p)
	return p


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
	_clear_commands()
	hold_pivot.visible = false
	weapon_pivot.visible = false
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


## Kinh nghiệm cần để từ cấp lv lên cấp lv + 1.
static func xp_needed(lv: int) -> int:
	return XP_BASE + XP_STEP * (lv - 1)


func _level_up() -> void:
	level += 1
	xp_to_next = xp_needed(level)
	max_hp += LEVEL_HP
	max_mp += 3
	attack += LEVEL_ATTACK
	hp = max_hp
	mp = max_mp
	Game.popup_text(global_position + Vector2(0, -10), "LÊN CẤP!", Color(1.0, 0.85, 0.3), 12)
	Game.message.emit("Lên cấp %d!  Máu +%d, Tấn công +%d" % [level, LEVEL_HP, LEVEL_ATTACK])
	_check_unlocks()
	if ELEMENTS_ENABLED and level >= 2 and not fire_unlocked:
		fire_unlocked = true
		Game.message.emit("Thức tỉnh nguyên tố LỬA! Nhấn Q (hoặc chuột phải) để bắn Cầu Lửa")


## Lên tới cấp mở khóa: báo kỹ năng mới (hoặc phím D) và tỏa vòng sáng.
func _check_unlocks() -> void:
	var text := ""
	var index := SKILL_UNLOCK_LEVELS.find(level)
	if index != -1:
		var id: String = Weapons.info(weapon)["skills"][index]
		var slot := skill_slots.find(id)
		var key: String = Skills.SLOT_KEYS[slot] if slot != -1 else Skills.SLOT_KEYS[index]
		text = "Mở khóa kỹ năng %s (phím %s)!" % [Skills.info(id).get("name", id), key]
		Game.popup_text(global_position + Vector2(0, -32), "MỞ KHÓA %s!" % key, Color(0.6, 1.0, 0.7), 12)
		if index == SKILL_UNLOCK_LEVELS.size() - 1:
			text += "  Đã mở hết kỹ năng: bấm K để đổi thứ tự kỹ năng theo ý bạn."
	elif level == QUICK_ITEM_LEVEL:
		text = "Mở khóa phím D: bấm D để uống bình máu nhanh!"
		Game.popup_text(global_position + Vector2(0, -32), "MỞ KHÓA D!", Color(0.6, 1.0, 0.7), 12)
	if text == "":
		return
	Game.message.emit(text)
	var ring := RING_EFFECT.new()
	ring.max_radius = 46.0
	ring.color = Color(0.6, 1.0, 0.7)
	ring.global_position = global_position
	get_parent().add_child(ring)


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

func _update_visual(delta: float, move_dir: Vector2) -> void:
	# Chọn hàng trong sprite sheet: 0 = xuống, 1 = lên, 2 = ngang
	var row := 0
	if absf(facing.x) > absf(facing.y) * 0.9:
		row = 2
		sprite.flip_h = facing.x < 0.0
	elif facing.y < 0.0:
		row = 1
	# Chọn khung hình đi bộ (4 khung)
	var col := 0
	if move_dir != Vector2.ZERO and dash_timer <= 0.0:
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
	hold_pivot.modulate.a = sprite.modulate.a
	# Bóng mờ khi lướt
	if dash_timer > 0.0:
		ghost_timer -= delta
		if ghost_timer <= 0.0:
			ghost_timer = 0.03
			_spawn_ghost()


## Vũ khí cầm trong tay: đổi chỗ theo hướng nhìn, nhún theo bước chân, ẩn khi đang vung đánh.
func _update_held_weapon(row: int, col: int) -> void:
	hold_pivot.visible = weapon != Weapons.Type.BOOK and not weapon_pivot.visible
	if hold_pivot.visible:
		Weapons.pose_held(hold_pivot, sprite, weapon, row, col, row == 2 and sprite.flip_h)


func _spawn_ghost() -> void:
	var ghost := Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.offset = sprite.offset
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
			copy.offset = layer.offset
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
