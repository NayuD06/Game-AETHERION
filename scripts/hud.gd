class_name GameHUD
extends CanvasLayer
## Giao diện (HUD): thanh máu / năng lượng / kinh nghiệm, ô kỹ năng,
## thanh máu Boss, thông báo, màn hình tạm dừng / thua / thắng.
## Toàn bộ được tạo bằng code để bạn dễ đọc và chỉnh.

const SCREEN := Vector2(640, 360)

var player: Player

var level_label: Label
var gold_label: Label
var hp_bar: ProgressBar
var hp_text: Label
var mp_bar: ProgressBar
var mp_text: Label
var xp_bar: ProgressBar

var boss_box: Control
var boss_name: Label
var boss_bar: ProgressBar

var message_label: Label
var area_label: Label
var message_queue: Array[String] = []
var message_timer := 0.0

var skill_slots := {}  # tên -> { "cover": ColorRect, "lock": Label, "style": StyleBoxFlat }
var weapon_desc: Label
var shown_weapon := -1

var pause_overlay: Control
var death_overlay: Control
var win_overlay: Control


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_stats_panel()
	_build_skill_bar()
	_build_boss_bar()
	_build_messages()
	pause_overlay = _build_overlay("TẠM DỪNG", _controls_text() + "\n\nNhấn Esc để chơi tiếp")
	death_overlay = _build_overlay("BẠN ĐÃ GỤC NGÃ", "Nhấn R để chơi lại, N để tạo nhân vật mới")
	win_overlay = _build_overlay("HOÀN THÀNH BẢN DEMO!",
		"Bạn đã chạm tới Bệ Thờ Cổ và thức tỉnh sức mạnh nguyên tố.\nCảm ơn bạn đã chơi thử!\n\nNhấn R để chơi lại, N để tạo nhân vật mới")

	Game.message.connect(show_message)
	Game.area_entered.connect(show_area_title)
	Game.boss_started.connect(_on_boss_started)
	Game.boss_health_changed.connect(_on_boss_health)
	Game.boss_armor_changed.connect(_on_boss_armor)
	Game.boss_defeated.connect(func(): boss_box.visible = false)


# ---------------------------------------------------------------- Dựng giao diện

func _make_label(text: String, size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 3)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _make_bar(pos: Vector2, bar_size: Vector2, fill: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.position = pos
	bar.size = bar_size
	bar.custom_minimum_size = bar_size
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.08, 0.06, 0.12, 0.85)
	bg.border_color = Color(0, 0, 0)
	bg.set_border_width_all(1)
	var fg := StyleBoxFlat.new()
	fg.bg_color = fill
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fg)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)
	return bar


func _bar_text(bar: ProgressBar) -> Label:
	var l := _make_label("", 8)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.position = Vector2.ZERO
	l.size = bar.size
	bar.add_child(l)
	return l


func _build_stats_panel() -> void:
	var panel := Panel.new()
	panel.position = Vector2(6, 6)
	panel.size = Vector2(200, 52)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.04, 0.1, 0.6)
	sb.set_corner_radius_all(3)
	panel.add_theme_stylebox_override("panel", sb)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	level_label = _make_label("Cấp 1", 10, Color(1.0, 0.85, 0.3))
	level_label.position = Vector2(10, 6)
	add_child(level_label)
	gold_label = _make_label("Vàng: 0", 9, Color(1.0, 0.9, 0.5))
	gold_label.position = Vector2(156, 22)
	add_child(gold_label)

	hp_bar = _make_bar(Vector2(10, 22), Vector2(140, 10), Color(0.85, 0.2, 0.25))
	hp_text = _bar_text(hp_bar)
	mp_bar = _make_bar(Vector2(10, 35), Vector2(140, 9), Color(0.25, 0.45, 0.95))
	mp_text = _bar_text(mp_bar)
	xp_bar = _make_bar(Vector2(10, 47), Vector2(140, 5), Color(1.0, 0.8, 0.25))
	if not Player.ELEMENTS_ENABLED:
		# Chưa dùng năng lượng: ẩn thanh MP, kéo thanh XP lên
		mp_bar.visible = false
		xp_bar.position.y = 36
		panel.size.y = 42


func _build_skill_bar() -> void:
	# Ô vũ khí (đã chọn lúc tạo nhân vật), ô Lướt, và ô kỹ năng nguyên tố nếu được bật.
	# Sau này có thể thêm ô cho các kỹ năng riêng của từng loại vũ khí ở đây.
	var weapon_index := int(Game.appearance.get("weapon", 0)) % Weapons.ORDER.size()
	var w := Weapons.info(Weapons.ORDER[weapon_index])
	var slots := []
	slots.append(["weapon", "J", w["name"], w["icon"]])
	slots.append(["dash", "Space", "Lướt", null])
	if Player.ELEMENTS_ENABLED:
		slots.append(["fire", "U", "Lửa", null])
		slots.append(["thunder", "I", "Sấm", null])
	var slot_size := Vector2(44, 40)
	var gap := 5.0
	var total_w := slots.size() * slot_size.x + (slots.size() - 1) * gap
	var x := (SCREEN.x - total_w) / 2.0
	var y := SCREEN.y - slot_size.y - 8.0
	for s in slots:
		var slot := Panel.new()
		slot.position = Vector2(x, y)
		slot.size = slot_size
		slot.clip_contents = true
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.1, 0.08, 0.16, 0.8)
		sb.border_color = Color(0.6, 0.55, 0.75)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(3)
		slot.add_theme_stylebox_override("panel", sb)
		add_child(slot)

		if s[3] != null:
			var icon := TextureRect.new()
			icon.texture = s[3]
			icon.position = Vector2((slot_size.x - 24) / 2.0, 4)
			icon.size = Vector2(24, 24)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(icon)
		var name_label := _make_label(s[2], 8 if s[3] != null else 10)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.size = Vector2(slot_size.x, 12)
		name_label.position = Vector2(0, 27 if s[3] != null else 12)
		slot.add_child(name_label)
		var key_label := _make_label(s[1], 7, Color(0.8, 0.8, 0.9))
		key_label.position = Vector2(3, 1)
		slot.add_child(key_label)

		var cover := ColorRect.new()
		cover.color = Color(0, 0, 0, 0.6)
		cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cover.size = Vector2(slot_size.x, 0)
		slot.add_child(cover)

		var lock := _make_label("Khóa", 8, Color(0.7, 0.7, 0.7))
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock.size = Vector2(slot_size.x, 12)
		lock.position = Vector2(0, 26)
		lock.visible = false
		slot.add_child(lock)

		skill_slots[s[0]] = {"cover": cover, "lock": lock, "height": slot_size.y, "style": sb}
		x += slot_size.x + gap

	weapon_desc = _make_label("", 8, Color(0.92, 0.92, 1.0))
	weapon_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_desc.size = Vector2(SCREEN.x, 12)
	weapon_desc.position = Vector2(0, y - 14)
	add_child(weapon_desc)


func _build_boss_bar() -> void:
	boss_box = Control.new()
	boss_box.position = Vector2((SCREEN.x - 300) / 2.0, 8)
	boss_box.size = Vector2(300, 30)
	boss_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_box.visible = false
	add_child(boss_box)
	boss_name = _make_label("", 10, Color(1.0, 0.75, 0.6))
	boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_name.size = Vector2(300, 14)
	boss_box.add_child(boss_name)
	boss_bar = _make_bar(Vector2.ZERO, Vector2(300, 8), Color(0.75, 0.15, 0.55))
	remove_child(boss_bar)
	boss_bar.position = Vector2(0, 16)
	boss_box.add_child(boss_bar)


func _build_messages() -> void:
	message_label = _make_label("", 11)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.size = Vector2(520, 30)
	message_label.position = Vector2((SCREEN.x - 520) / 2.0, SCREEN.y - 90)
	add_child(message_label)

	area_label = _make_label("", 22, Color(1.0, 0.95, 0.8))
	area_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	area_label.size = Vector2(SCREEN.x, 30)
	area_label.position = Vector2(0, 70)
	area_label.modulate.a = 0.0
	add_child(area_label)


func _build_overlay(title: String, body: String) -> Control:
	var root := ColorRect.new()
	root.color = Color(0, 0, 0, 0.7)
	root.position = Vector2.ZERO
	root.size = SCREEN
	root.visible = false
	add_child(root)
	var t := _make_label(title, 24, Color(1.0, 0.85, 0.4))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.size = Vector2(SCREEN.x, 32)
	t.position = Vector2(0, 70)
	root.add_child(t)
	var b := _make_label(body, 10)
	b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.size = Vector2(SCREEN.x, 200)
	b.position = Vector2(0, 115)
	root.add_child(b)
	return root


func _controls_text() -> String:
	return "\n".join([
		"Di chuyển: W A S D / phím mũi tên",
		"Đánh: J / chuột trái  (Cung: giữ để gồng, thả để bắn)",
		"Nhấn N để tạo nhân vật mới (chọn lại vũ khí, ngoại hình)",
		"Lướt né (bất tử khi lướt): Space / K",
	])


# ---------------------------------------------------------------- Cập nhật mỗi khung hình

func _process(delta: float) -> void:
	_update_messages(delta)
	if player == null or not is_instance_valid(player):
		return
	level_label.text = "%s  -  Cấp %d" % [Game.appearance.get("name", ""), player.level]
	gold_label.text = "Vàng: %d" % player.gold
	hp_bar.max_value = player.max_hp
	hp_bar.value = player.hp
	hp_text.text = "%d / %d" % [player.hp, player.max_hp]
	mp_bar.max_value = player.max_mp
	mp_bar.value = player.mp
	mp_text.text = "%d / %d" % [int(player.mp), player.max_mp]
	xp_bar.max_value = player.xp_to_next
	xp_bar.value = player.xp

	# Ô vũ khí: che tối theo thời gian hồi chiêu, viền sáng khi đang gồng cung
	var style: StyleBoxFlat = skill_slots["weapon"]["style"]
	style.border_color = Color(1.0, 0.85, 0.3)
	style.set_border_width_all(2 if player.charging else 1)
	_set_cooldown("weapon", player.attack_cd / maxf(player.last_attack_cooldown, 0.01), true)
	if shown_weapon != player.weapon:
		shown_weapon = player.weapon
		weapon_desc.text = Weapons.info(player.weapon)["desc"]
		# Hiện mô tả vũ khí vài giây lúc vào game rồi mờ dần
		weapon_desc.modulate.a = 1.0
		var tw := create_tween()
		tw.tween_interval(6.0)
		tw.tween_property(weapon_desc, "modulate:a", 0.0, 1.0)
	_set_cooldown("dash", player.dash_cd / player.dash_cooldown, true)
	if not Player.ELEMENTS_ENABLED:
		return
	_set_cooldown("fire", player.fire_cd / Player.FIRE_COOLDOWN, player.fire_unlocked,
		player.mp < Player.FIRE_COST)
	_set_cooldown("thunder", player.thunder_cd / Player.THUNDER_COOLDOWN, player.thunder_unlocked,
		player.mp < Player.THUNDER_COST)


func _set_cooldown(skill: String, ratio: float, unlocked: bool, no_mana: bool = false) -> void:
	var slot: Dictionary = skill_slots[skill]
	var cover: ColorRect = slot["cover"]
	var lock: Label = slot["lock"]
	var h: float = slot["height"]
	lock.visible = not unlocked
	if not unlocked:
		cover.size.y = h
		cover.position.y = 0
		return
	var r := clampf(ratio, 0.0, 1.0)
	if no_mana and r <= 0.0:
		r = 1.0  # thiếu năng lượng: tô tối cả ô
		cover.color = Color(0.05, 0.1, 0.35, 0.6)
	else:
		cover.color = Color(0, 0, 0, 0.6)
	cover.size.y = h * r
	cover.position.y = h - h * r


func _update_messages(delta: float) -> void:
	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.6:
			message_label.modulate.a = message_timer / 0.6
		if message_timer <= 0.0:
			message_label.text = ""
	if message_timer <= 0.0 and not message_queue.is_empty():
		message_label.text = message_queue.pop_front()
		message_label.modulate.a = 1.0
		message_timer = 3.0


# ---------------------------------------------------------------- Sự kiện

func show_message(text: String) -> void:
	message_queue.append(text)


func show_area_title(area_name: String) -> void:
	area_label.text = area_name
	var tw := create_tween()
	tw.tween_property(area_label, "modulate:a", 1.0, 0.5)
	tw.tween_interval(1.8)
	tw.tween_property(area_label, "modulate:a", 0.0, 0.8)


var boss_title := ""

func _on_boss_started(boss_display_name: String) -> void:
	boss_title = boss_display_name
	boss_name.text = boss_display_name
	boss_box.visible = true


func _on_boss_armor(armor: int) -> void:
	boss_name.text = boss_title + ("   [Giáp %d]" % armor if armor > 0 else "   [Đã phá giáp]")


func _on_boss_health(current: int, maximum: int) -> void:
	boss_bar.max_value = maximum
	boss_bar.value = current


func set_paused(paused: bool) -> void:
	pause_overlay.visible = paused


func show_death() -> void:
	death_overlay.visible = true


func show_win() -> void:
	win_overlay.visible = true
