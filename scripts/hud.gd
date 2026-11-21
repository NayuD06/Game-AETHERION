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

var skill_slots := {}  # tên -> { "cover": ColorRect, "lock": Label, "style": StyleBoxFlat, ... }
var bag_panel: Panel
var bag_buttons: Array = []  # mỗi ô: [Button, Label số lượng]
var bag_gold: Label
var bag_hint: Label
var shown_bag_slots := -1
var craft_panel: Panel
var craft_rows: Array = []   # mỗi dòng: { "recipe": Dictionary, "button": Button, "needs": [[id, cần, Label], ...] }
var craft_station := ""
var bound_player: Player = null
var weapon_desc: Label
var shown_weapon := -1
var shown_skills := ""   # id các kỹ năng đang hiện trên ô Q W E R (để biết khi nào đổi)

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
		"Bạn đã vượt qua Hầm Ngục Cổ và bước vào Cổng Xoáy.\nVùng đất mới và sức mạnh nguyên tố sẽ có ở phần sau.\nCảm ơn bạn đã chơi thử!\n\nNhấn R để chơi lại, N để tạo nhân vật mới")
	_ignore_mouse(self)
	_build_bag()
	_build_craft_panel()

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
	# Ô đánh thường, 4 ô kỹ năng Q W E R của vũ khí, ô D (bình máu), ô F (lướt)
	# và ô kỹ năng nguyên tố nếu được bật.
	var weapon_index := int(Game.appearance.get("weapon", 0)) % Weapons.ORDER.size()
	var w := Weapons.info(Weapons.ORDER[weapon_index])
	var slots := []
	slots.append(["weapon", "Chuột", w["name"], w["icon"]])
	var skills: Array = w["skills"]
	for i in skills.size():
		slots.append(["skill_%d" % i, Skills.SLOT_KEYS[i], Skills.info(skills[i]).get("short", ""), null])
	slots.append(["gap", "", "", null])
	slots.append(["item", "D", "Bình máu", Items.info("potion_hp")["icon"]])
	slots.append(["dash", "F", "Lướt", null])
	if Player.ELEMENTS_ENABLED:
		slots.append(["fire", "U", "Lửa", null])
		slots.append(["thunder", "I", "Sấm", null])
	var slot_size := Vector2(44, 40)
	var gap := 5.0
	var total_w := -gap
	for s in slots:
		total_w += (10.0 if s[0] == "gap" else slot_size.x) + gap
	var x := (SCREEN.x - total_w) / 2.0
	var y := SCREEN.y - slot_size.y - 8.0
	for s in slots:
		if s[0] == "gap":
			x += 10.0 + gap
			continue
		var slot := Panel.new()
		slot.position = Vector2(x, y)
		slot.size = slot_size
		slot.clip_contents = true
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.1, 0.08, 0.16, 0.8)
		sb.border_color = Color(0.6, 0.55, 0.75)
		if str(s[0]) == "skill_3":
			sb.border_color = Color(1.0, 0.6, 0.3)  # tuyệt chiêu có viền cam
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(3)
		slot.add_theme_stylebox_override("panel", sb)
		add_child(slot)

		if s[3] != null:
			var icon := TextureRect.new()
			icon.texture = s[3]
			icon.position = Vector2((slot_size.x - 22) / 2.0, 5)
			icon.size = Vector2(22, 22)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			slot.add_child(icon)
		var small: bool = s[3] != null or str(s[0]).begins_with("skill_")
		var name_label := _make_label(s[2], 8 if small else 9)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.size = Vector2(slot_size.x, 24)
		name_label.position = Vector2(0, 27 if s[3] != null else 10)
		slot.add_child(name_label)
		var key_label := _make_label(s[1], 7, Color(1.0, 0.9, 0.5))
		key_label.position = Vector2(3, 1)
		slot.add_child(key_label)

		var cover := ColorRect.new()
		cover.color = Color(0, 0, 0, 0.6)
		cover.size = Vector2(slot_size.x, 0)
		slot.add_child(cover)

		var cd_label := _make_label("", 12, Color(1, 1, 1))
		cd_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cd_label.size = Vector2(slot_size.x, 16)
		cd_label.position = Vector2(0, 10)
		slot.add_child(cd_label)

		var lock := _make_label("Khóa", 8, Color(0.7, 0.7, 0.7))
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock.size = Vector2(slot_size.x, 12)
		lock.position = Vector2(0, 26)
		lock.visible = false
		slot.add_child(lock)

		var count_label := _make_label("", 8, Color(1, 1, 1))
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count_label.size = Vector2(slot_size.x - 3, 10)
		count_label.position = Vector2(0, 1)
		slot.add_child(count_label)

		skill_slots[s[0]] = {"cover": cover, "lock": lock, "height": slot_size.y, "style": sb,
			"cd_label": cd_label, "count": count_label, "name": name_label}
		x += slot_size.x + gap

	weapon_desc = _make_label("", 8, Color(0.92, 0.92, 1.0))
	weapon_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_desc.size = Vector2(SCREEN.x, 12)
	weapon_desc.position = Vector2(0, y - 14)
	add_child(weapon_desc)


## Túi đồ (phím B): 8 ô, bấm vào vật phẩm để dùng.
func _build_bag() -> void:
	bag_panel = Panel.new()
	bag_panel.position = Vector2(SCREEN.x - 160, 64)
	bag_panel.size = Vector2(152, 164)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.09, 0.07, 0.92)
	sb.border_color = Color(0.75, 0.6, 0.4)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	bag_panel.add_theme_stylebox_override("panel", sb)
	bag_panel.visible = false
	add_child(bag_panel)
	var title := _make_label("Túi đồ  (B để đóng)", 10, Color(1.0, 0.85, 0.5))
	title.position = Vector2(8, 4)
	bag_panel.add_child(title)
	for i in Player.BAG_SLOTS_MAX:
		var button := Button.new()
		button.position = Vector2(8 + (i % 4) * 35, 22 + floori(i / 4.0) * 35)
		button.size = Vector2(32, 32)
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.focus_mode = Control.FOCUS_NONE
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.22, 0.17, 0.12)
		normal.border_color = Color(0.45, 0.35, 0.25)
		normal.set_border_width_all(1)
		var hover := normal.duplicate() as StyleBoxFlat
		hover.border_color = Color(1.0, 0.85, 0.4)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", hover)
		button.pressed.connect(_on_bag_slot_pressed.bind(i))
		bag_panel.add_child(button)
		var count := _make_label("", 8)
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count.size = Vector2(30, 10)
		count.position = Vector2(0, 21)
		button.add_child(count)
		bag_buttons.append([button, count])
	bag_gold = _make_label("", 9, Color(1.0, 0.9, 0.5))
	bag_panel.add_child(bag_gold)
	bag_hint = _make_label("Bấm vào vật phẩm để dùng / ăn", 8, Color(0.85, 0.8, 0.75))
	bag_panel.add_child(bag_hint)
	_resize_bag(Player.BAG_SLOTS_START)


## Túi đồ lớn dần khi làm "Ba lô lớn hơn": chỉ hiện số ô đang có, khung túi cao theo số hàng.
func _resize_bag(slots: int) -> void:
	shown_bag_slots = slots
	var rows := ceili(slots / 4.0)
	for i in bag_buttons.size():
		(bag_buttons[i][0] as Button).visible = i < slots
	var bottom := 22 + rows * 35
	bag_gold.position = Vector2(8, bottom + 2)
	bag_hint.position = Vector2(8, bottom + 16)
	bag_panel.size = Vector2(152, bottom + 35)


func _refresh_bag() -> void:
	if player == null or not is_instance_valid(player):
		return
	if player.bag_slots != shown_bag_slots:
		_resize_bag(player.bag_slots)
	_refresh_craft()
	for i in bag_buttons.size():
		var button: Button = bag_buttons[i][0]
		var count: Label = bag_buttons[i][1]
		if i < player.bag.size():
			var slot: Dictionary = player.bag[i]
			var data := Items.info(slot["id"])
			button.icon = data.get("icon")
			button.tooltip_text = "%s\n%s" % [data.get("name", ""), data.get("desc", "")]
			count.text = "x%d" % slot["count"]
		else:
			button.icon = null
			button.tooltip_text = ""
			count.text = ""
	bag_gold.text = "Vàng: %d" % player.gold


func _on_bag_slot_pressed(index: int) -> void:
	if player != null and is_instance_valid(player) and not get_tree().paused:
		player.use_bag_slot(index)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory") and not get_tree().paused:
		bag_panel.visible = not bag_panel.visible
		_refresh_bag()


# ---------------------------------------------------------------- Bảng chế tạo

## Bảng chế tạo: tự mở khi đứng gần nồi luyện thuốc / bàn chế tạo (công thức ở scripts/recipes.gd).
func _build_craft_panel() -> void:
	craft_panel = Panel.new()
	craft_panel.position = Vector2(6, 64)
	craft_panel.size = Vector2(250, 100)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.09, 0.07, 0.92)
	sb.border_color = Color(0.75, 0.6, 0.4)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	craft_panel.add_theme_stylebox_override("panel", sb)
	craft_panel.visible = false
	add_child(craft_panel)
	Game.station_changed.connect(_on_station_changed)


func _on_station_changed(station: String) -> void:
	craft_station = station
	if station == "" or not Recipes.STATIONS.has(station):
		craft_panel.visible = false
		craft_rows.clear()
		return
	_fill_craft_panel(station)
	craft_panel.visible = true


func _fill_craft_panel(station: String) -> void:
	for child in craft_panel.get_children():
		craft_panel.remove_child(child)
		child.queue_free()
	craft_rows.clear()
	var info: Dictionary = Recipes.STATIONS[station]
	var title := _make_label(info["name"], 11, Color(1.0, 0.85, 0.5))
	title.position = Vector2(8, 3)
	craft_panel.add_child(title)
	var hint := _make_label("%s  (đi ra xa để đóng)" % info["hint"], 7, Color(0.85, 0.8, 0.75))
	hint.position = Vector2(8, 19)
	craft_panel.add_child(hint)
	var recipes := Recipes.for_station(station)
	for i in recipes.size():
		var recipe: Dictionary = recipes[i]
		var row := Panel.new()
		row.position = Vector2(6, 32 + i * 34)
		row.size = Vector2(238, 31)
		var row_style := StyleBoxFlat.new()
		row_style.bg_color = Color(0.2, 0.15, 0.11)
		row_style.border_color = Color(0.4, 0.31, 0.22)
		row_style.set_border_width_all(1)
		row.add_theme_stylebox_override("panel", row_style)
		row.tooltip_text = Recipes.result_desc(recipe)
		craft_panel.add_child(row)
		row.add_child(_make_icon(Recipes.result_icon(recipe), Vector2(4, 4), 22.0))
		var label := _make_label(Recipes.result_name(recipe), 9, Color(1.0, 0.95, 0.8))
		label.position = Vector2(30, 0)
		row.add_child(label)
		# Nguyên liệu: hình + "đang có / cần" (xanh = đủ, đỏ = thiếu)
		var needs: Dictionary = recipe["needs"]
		var need_labels := []
		var x := 30.0
		for id in needs:
			row.add_child(_make_icon(Items.info(id).get("icon"), Vector2(x, 16), 12.0))
			var count := _make_label("", 8)
			count.position = Vector2(x + 13, 15)
			row.add_child(count)
			need_labels.append([id, int(needs[id]), count])
			x += 44.0
		var button := Button.new()
		button.text = "Chế"
		button.position = Vector2(194, 5)
		button.size = Vector2(40, 21)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 9)
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.35, 0.5, 0.25)
		normal.border_color = Color(0.7, 0.9, 0.5)
		normal.set_border_width_all(1)
		normal.set_corner_radius_all(3)
		var hover := normal.duplicate() as StyleBoxFlat
		hover.bg_color = Color(0.45, 0.62, 0.32)
		var off := normal.duplicate() as StyleBoxFlat
		off.bg_color = Color(0.25, 0.22, 0.2)
		off.border_color = Color(0.4, 0.36, 0.32)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", hover)
		button.add_theme_stylebox_override("disabled", off)
		button.pressed.connect(_on_craft_pressed.bind(recipe))
		row.add_child(button)
		craft_rows.append({ "recipe": recipe, "button": button, "needs": need_labels })
	craft_panel.size = Vector2(250, 36 + recipes.size() * 34)
	_refresh_craft()


func _make_icon(tex: Texture2D, pos: Vector2, icon_size: float) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = tex
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = pos
	icon.size = Vector2(icon_size, icon_size)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


## Cập nhật số nguyên liệu đang có, nút "Chế" sáng lên khi đủ đồ.
func _refresh_craft() -> void:
	if craft_rows.is_empty() or player == null or not is_instance_valid(player):
		return
	for row in craft_rows:
		for need in row["needs"]:
			var have := player.count_item(need[0])
			var label: Label = need[2]
			label.text = "%d/%d" % [have, need[1]]
			label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6) if have >= int(need[1]) else Color(1.0, 0.55, 0.5))
		var button: Button = row["button"]
		var maxed := Recipes.is_maxed(player, row["recipe"])
		button.text = "Xong" if maxed else "Chế"
		button.disabled = not Recipes.can_craft(player, row["recipe"])


func _on_craft_pressed(recipe: Dictionary) -> void:
	if player == null or not is_instance_valid(player) or get_tree().paused:
		return
	var result := Recipes.craft(player, recipe)
	if result == "":
		Game.popup_text(player.global_position + Vector2(0, -24), "+ " + Recipes.result_name(recipe), Color(1.0, 0.9, 0.5), 10)
		Game.burst(player.global_position + Vector2(0, -8), Color(1.0, 0.85, 0.4), 10, 50.0, 60.0, 0.45, 1.5)
	else:
		Game.popup_text(player.global_position + Vector2(0, -24), result, Color(1.0, 0.6, 0.5), 9)
	_refresh_bag()


## Mọi thứ trên HUD (trừ túi đồ) để chuột "xuyên qua", để bấm chuột phải đi lại vẫn được.
func _ignore_mouse(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_mouse(child)


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


## Chữ trong bảng tạm dừng (Esc). skill_ids: các kỹ năng đang đặt ở ô Q W E R
## (để trống thì lấy bộ mặc định của vũ khí đã chọn).
func _controls_text(skill_ids: Array = []) -> String:
	var lines := [
		"Chuột phải: đi tới chỗ bấm / bấm vào quái để tự chạy tới đánh",
		"Chuột trái: đánh về phía con trỏ (Cung: giữ để gồng)   A + chuột trái: vừa đi vừa đánh   S: đứng lại",
		"F: lướt né   D: uống bình máu   B: túi đồ   N: tạo nhân vật mới",
		"Đi tới cây chín để hái. Đi tới nồi luyện thuốc / bàn chế tạo (cạnh giếng Làng Khởi Nguyên) để chế đồ",
		"",
	]
	var weapon_index := int(Game.appearance.get("weapon", 0)) % Weapons.ORDER.size()
	var w := Weapons.info(Weapons.ORDER[weapon_index])
	lines.append("Kỹ năng %s (%s):" % [w["class_name"], w["name"]])
	var ids: Array = skill_ids if not skill_ids.is_empty() else w["skills"]
	for i in ids.size():
		var info := Skills.info(ids[i])
		if not info.is_empty():
			lines.append("%s - %s: %s" % [Skills.SLOT_KEYS[i], info["name"], info["desc"]])
	return "\n".join(lines)


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

	# Túi đồ: cập nhật khi đồ trong túi thay đổi
	if bound_player != player:
		bound_player = player
		player.bag_changed.connect(_refresh_bag)
	if bag_panel.visible:
		bag_gold.text = "Vàng: %d" % player.gold

	# Ô đánh thường: che tối theo thời gian hồi chiêu, viền sáng khi đang gồng cung
	var style: StyleBoxFlat = skill_slots["weapon"]["style"]
	style.border_color = Color(1.0, 0.85, 0.3)
	style.set_border_width_all(2 if player.charging else 1)
	_set_cooldown("weapon", player.attack_cd / maxf(player.last_attack_cooldown, 0.01), true)
	# Ô kỹ năng Q W E R (đổi tên ô khi người chơi đổi kỹ năng)
	var key := ",".join(PackedStringArray(player.skill_slots))
	if key != shown_skills:
		shown_skills = key
		_refresh_skill_names()
	for i in player.skill_slots.size():
		if not skill_slots.has("skill_%d" % i):
			continue
		var info := player.slot_skill(i)
		var cd: float = info.get("cooldown", 1.0)
		_set_cooldown("skill_%d" % i, player.skill_cd[i] / maxf(cd, 0.01), not info.is_empty(),
			false, player.skill_cd[i])
	# Ô bình máu
	var potions := player.count_item("potion_hp")
	skill_slots["item"]["count"].text = "x%d" % potions
	_set_cooldown("item", player.item_cd / Player.ITEM_COOLDOWN, true, potions == 0)
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


## Cập nhật tên trên ô Q W E R và bảng Esc theo kỹ năng nhân vật đang đặt.
func _refresh_skill_names() -> void:
	for i in player.skill_slots.size():
		if skill_slots.has("skill_%d" % i):
			var label: Label = skill_slots["skill_%d" % i]["name"]
			label.text = player.slot_skill(i).get("short", "")
	var body := pause_overlay.get_child(1) as Label
	body.text = _controls_text(player.skill_slots) + "\n\nNhấn Esc để chơi tiếp"


func _set_cooldown(skill: String, ratio: float, unlocked: bool, no_mana: bool = false,
		seconds_left: float = 0.0) -> void:
	var slot: Dictionary = skill_slots[skill]
	var cover: ColorRect = slot["cover"]
	var lock: Label = slot["lock"]
	var h: float = slot["height"]
	var cd_label: Label = slot["cd_label"]
	cd_label.text = str(ceili(seconds_left)) if seconds_left > 0.0 else ""
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
