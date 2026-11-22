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
var xp_text: Label

var boss_box: Control
var boss_name: Label
var boss_bar: ProgressBar

var message_label: Label
var area_label: Label
var message_queue: Array[String] = []
var message_timer := 0.0

var skill_slots := {}  # tên -> { "cover": ColorRect, "lock": Label, "style": StyleBoxFlat, ... }
var bag_panel: Panel
var bag_buttons: Array = []  # mỗi ô: [Button, Label số lượng, Label dấu "+" (đồ tốt hơn đang mặc)]
var bag_gold: Label
var bag_hint: Label
var shown_bag_slots := -1
var equip_panel: Panel       # bảng Trang bị (mũ, giáp, quần, giày) bên trái túi đồ
var equip_slots := {}        # "helmet" -> { "button", "style", "bar", "fill" }
var equip_stats: Label
var shop_panel: Panel        # bảng cửa hàng khi đứng gần người bán (scripts/shops.gd)
var shop_id := ""
var shop_tab := "buy"        # "buy" mua, "sell" bán, "repair" sửa đồ
var shop_page := 0
var shop_shown_gold := -1
var shop_refresh_queued := false
const SHOP_W := 206.0
const SHOP_ROW_W := 190.0
const SHOP_PAGE := 7         # số dòng mỗi trang
var craft_panel: Panel
var craft_rows: Array = []   # mỗi dòng: { "recipe": Dictionary, "button": Button, "needs": [[id, cần, Label], ...] }
var craft_station := ""
var buff_label: Label        # thuốc / món ăn đang có tác dụng (góc trên, cạnh thanh máu)
const CRAFT_ROW_W := 226.0
var bound_player: Player = null
var weapon_desc: Label
var shown_weapon := -1
var shown_skills := ""   # id các kỹ năng đang hiện trên ô Q W E R (để biết khi nào đổi)

# Bảng kỹ năng (phím K): xem cấp mở khóa, đổi thứ tự kỹ năng Q W E R
var skill_panel: Panel
var skill_cards: Array = []   # mỗi ô: { "button", "style", "name", "desc", "info" }
var skill_hint: Label
var skill_reset_button: Button
var skill_pick := -1          # ô đang chọn để đổi chỗ (-1 = chưa chọn)
var shown_panel := ""         # cấp + thứ tự kỹ năng lúc vẽ bảng (để biết khi nào vẽ lại)
const CARD_SIZE := Vector2(118, 132)

var minimap: Minimap          # bản đồ nhỏ hình tròn góc trên bên trái (scripts/minimap.gd)

var pause_overlay: Control
var death_overlay: Control
var win_overlay: Control


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_stats_panel()
	buff_label = _make_label("", 8, Color(1.0, 0.95, 0.8))
	buff_label.position = Vector2(314, 8)
	add_child(buff_label)
	_build_skill_bar()
	_build_boss_bar()
	_build_messages()
	pause_overlay = _build_overlay("TẠM DỪNG", _controls_text() + "\n\nNhấn Esc để chơi tiếp")
	death_overlay = _build_overlay("BẠN ĐÃ GỤC NGÃ", "Nhấn R để chơi lại, N để tạo nhân vật mới")
	win_overlay = _build_overlay("HOÀN THÀNH BẢN DEMO!",
		"Bạn đã hạ Malakar, vượt qua 5 tầng Hầm Ngục Cổ và bước vào Cổng Xoáy.\nVùng đất mới và sức mạnh nguyên tố sẽ có ở phần sau.\nCảm ơn bạn đã chơi thử!\n\nNhấn R để chơi lại, N để tạo nhân vật mới")
	_ignore_mouse(self)
	_build_bag()
	_build_equip_panel()
	_build_craft_panel()
	_build_shop_panel()
	_build_skill_panel()
	minimap = Minimap.new()
	add_child(minimap)

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
	panel.position = Vector2(108, 6)  # bên phải bản đồ nhỏ hình tròn
	panel.size = Vector2(200, 52)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.04, 0.1, 0.6)
	sb.set_corner_radius_all(3)
	panel.add_theme_stylebox_override("panel", sb)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	level_label = _make_label("Cấp 1", 10, Color(1.0, 0.85, 0.3))
	level_label.position = Vector2(112, 6)
	add_child(level_label)
	gold_label = _make_label("Vàng: 0", 9, Color(1.0, 0.9, 0.5))
	gold_label.position = Vector2(258, 22)
	add_child(gold_label)

	hp_bar = _make_bar(Vector2(112, 22), Vector2(140, 10), Color(0.85, 0.2, 0.25))
	hp_text = _bar_text(hp_bar)
	mp_bar = _make_bar(Vector2(112, 35), Vector2(140, 9), Color(0.25, 0.45, 0.95))
	mp_text = _bar_text(mp_bar)
	xp_bar = _make_bar(Vector2(112, 47), Vector2(140, 5), Color(1.0, 0.8, 0.25))
	xp_text = _make_label("", 7, Color(1.0, 0.9, 0.6))
	add_child(xp_text)
	if not Player.ELEMENTS_ENABLED:
		# Chưa dùng năng lượng: ẩn thanh MP, kéo thanh XP lên
		mp_bar.visible = false
		xp_bar.position.y = 36
		panel.size.y = 42
	xp_text.position = Vector2(256, xp_bar.position.y - 3)


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

		var lock := _make_label("Khóa", 9, Color(0.9, 0.9, 0.95))
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock.size = Vector2(slot_size.x, 12)
		lock.position = Vector2(0, 14)
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
	(skill_slots["item"]["lock"] as Label).text = "Cấp %d" % Player.QUICK_ITEM_LEVEL

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
		var mark := _make_label("", 10, Color(0.45, 1.0, 0.45))
		mark.position = Vector2(2, -3)
		button.add_child(mark)
		bag_buttons.append([button, count, mark])
	bag_gold = _make_label("", 9, Color(1.0, 0.9, 0.5))
	bag_panel.add_child(bag_gold)
	bag_hint = _make_label("Bấm để dùng / ăn / mặc đồ", 8, Color(0.85, 0.8, 0.75))
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
		var mark: Label = bag_buttons[i][2]
		var style := button.get_theme_stylebox("normal") as StyleBoxFlat
		style.border_color = Color(0.45, 0.35, 0.25)
		button.modulate = Color.WHITE
		mark.text = ""
		if i < player.bag.size():
			var slot: Dictionary = player.bag[i]
			var data := Items.info(slot["id"])
			button.icon = data.get("icon")
			if Equipment.is_gear(slot["id"]):
				# Trang bị: viền theo độ hiếm, đỏ lên khi hỏng, dấu "+" khi tốt hơn món đang mặc
				button.tooltip_text = Equipment.tooltip(slot) + ("\nBấm để cầm" if Equipment.slot_of(slot["id"]) == "weapon" else "\nBấm để mặc")
				style.border_color = Equipment.rarity_info(slot.get("rarity", ""))["color"]
				count.text = ""
				if Equipment.is_broken(slot):
					button.modulate = Color(1.0, 0.5, 0.5)
				elif _gear_is_better(slot):
					mark.text = "+"
			else:
				button.tooltip_text = "%s\n%s" % [data.get("name", ""), data.get("desc", "")]
				count.text = "x%d" % slot["count"]
		else:
			button.icon = null
			button.tooltip_text = ""
			count.text = ""
	bag_gold.text = "Vàng: %d" % player.gold
	_refresh_equip()
	if shop_panel != null and shop_panel.visible:
		_refresh_shop_later()


## Món trong túi có tốt hơn món đang mặc ở cùng chỗ không (chỗ trống hoặc món đang mặc đã hỏng = có).
func _gear_is_better(item: Dictionary) -> bool:
	if not player.can_use_gear(item["id"]):
		return false   # vũ khí khác loại: chưa dùng được
	var worn: Dictionary = player.gear.get(Equipment.slot_of(item["id"]), {})
	if worn.is_empty() or Equipment.is_broken(worn):
		return true
	return Equipment.score(item["id"], item.get("rarity", "")) > Equipment.score(worn["id"], worn.get("rarity", ""))


# ---------------------------------------------------------------- Bảng Trang bị (mở cùng túi đồ)

## 5 ô trang bị: Mũ, Giáp, Quần, Giày, Vũ khí. Dưới mỗi ô có thanh độ bền. Bên dưới là tổng chỉ số trang bị.
func _build_equip_panel() -> void:
	equip_panel = Panel.new()
	equip_panel.size = Vector2(104, 226)
	equip_panel.position = Vector2(SCREEN.x - 160 - equip_panel.size.x - 4, 64)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.09, 0.07, 0.92)
	sb.border_color = Color(0.75, 0.6, 0.4)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	equip_panel.add_theme_stylebox_override("panel", sb)
	equip_panel.visible = false
	add_child(equip_panel)
	var title := _make_label("Trang bị", 10, Color(1.0, 0.85, 0.5))
	title.position = Vector2(8, 4)
	equip_panel.add_child(title)
	for i in Equipment.SLOTS.size():
		var slot: String = Equipment.SLOTS[i]
		var pos := Vector2(12 + (i % 2) * 48, 22 + floori(i / 2.0) * 40)
		var button := Button.new()
		button.position = pos
		button.size = Vector2(32, 32)
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.focus_mode = Control.FOCUS_NONE
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.18, 0.14, 0.1)
		normal.border_color = Color(0.45, 0.35, 0.25)
		normal.set_border_width_all(1)
		var hover := normal.duplicate() as StyleBoxFlat
		hover.border_color = Color(1.0, 0.85, 0.4)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", hover)
		button.pressed.connect(_on_equip_slot_pressed.bind(slot))
		equip_panel.add_child(button)
		var slot_name := _make_label(Equipment.SLOT_NAMES[slot], 7, Color(0.8, 0.75, 0.65))
		slot_name.position = Vector2(pos.x + 34, pos.y + 1)
		equip_panel.add_child(slot_name)
		# Thanh độ bền
		var bar := ColorRect.new()
		bar.color = Color(0.05, 0.04, 0.04)
		bar.position = pos + Vector2(0, 34)
		bar.size = Vector2(32, 3)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		equip_panel.add_child(bar)
		var fill := ColorRect.new()
		fill.size = Vector2(32, 3)
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_child(fill)
		equip_slots[slot] = { "button": button, "style": normal, "bar": bar, "fill": fill }
	equip_stats = _make_label("", 8, Color(1.0, 0.95, 0.85))
	equip_stats.position = Vector2(8, 142)
	equip_panel.add_child(equip_stats)


func _refresh_equip() -> void:
	if equip_panel == null or player == null or not is_instance_valid(player):
		return
	for slot in Equipment.SLOTS:
		var ui: Dictionary = equip_slots[slot]
		var button: Button = ui["button"]
		var style: StyleBoxFlat = ui["style"]
		var bar: ColorRect = ui["bar"]
		var fill: ColorRect = ui["fill"]
		var item: Dictionary = player.gear[slot]
		button.modulate = Color.WHITE
		if item.is_empty():
			button.icon = Equipment.SLOT_ICONS[slot]
			button.tooltip_text = "%s: chưa mặc gì.\nNhặt trang bị trong rương hầm ngục, bấm vào món trong túi để mặc." % Equipment.SLOT_NAMES[slot]
			if slot == "weapon":
				button.tooltip_text = "Vũ khí: chưa cầm món nào (vẫn đánh được nhưng không được cộng Tấn công).\nRương hầm ngục rơi đúng loại vũ khí của bạn, bấm vào món trong túi để cầm."
			style.border_color = Color(0.45, 0.35, 0.25)
			bar.visible = false
			continue
		button.icon = Equipment.icon(item["id"])
		button.tooltip_text = Equipment.tooltip(item) + "\nBấm để tháo ra"
		style.border_color = Equipment.rarity_info(item.get("rarity", ""))["color"]
		var ratio := float(item["dur"]) / float(maxi(Equipment.max_durability(item["id"], item.get("rarity", "")), 1))
		bar.visible = true
		fill.size.x = maxf(32.0 * ratio, 0.0)
		fill.color = Color(0.4, 0.9, 0.4) if ratio > 0.5 else (Color(1.0, 0.8, 0.3) if ratio > Equipment.LOW_DURABILITY else Color(1.0, 0.35, 0.3))
		if Equipment.is_broken(item):
			button.modulate = Color(1.0, 0.45, 0.45)
	var b: Dictionary = player.gear_bonus
	var lines := PackedStringArray()
	lines.append("Phòng thủ %d" % player.defense)
	lines.append("  (chặn %d%% sát thương)" % Equipment.block_percent(player.defense))
	lines.append("Máu +%d" % int(b["hp"]))
	lines.append("Tấn công +%d" % int(b["attack"]))
	lines.append("Tốc độ +%d%%" % int(b["speed"]))
	var cost := player.repair_all_cost()
	if cost > 0:
		lines.append("Sửa đồ: %d vàng" % cost)
	equip_stats.text = "\n".join(lines)


## Trang bị thay đổi (mặc, tháo, mòn, sửa): cập nhật bảng Trang bị và tab Sửa đồ của thợ rèn.
func _on_gear_changed() -> void:
	_refresh_equip()
	if shop_panel.visible and shop_tab == "repair":
		_refresh_shop_later()


func _on_equip_slot_pressed(slot: String) -> void:
	if player != null and is_instance_valid(player) and not get_tree().paused:
		player.unequip(slot)


func _on_bag_slot_pressed(index: int) -> void:
	if player != null and is_instance_valid(player) and not get_tree().paused:
		player.use_bag_slot(index)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory") and not get_tree().paused:
		bag_panel.visible = not bag_panel.visible
		equip_panel.visible = bag_panel.visible
		_refresh_bag()
	elif event.is_action_pressed("skills_menu"):
		toggle_skill_panel()
	elif event.is_action_pressed("world_map"):
		minimap.toggle_big()


# ---------------------------------------------------------------- Bảng kỹ năng (phím K)

## Bảng 4 ô kỹ năng Q W E R: tên, mô tả, hồi chiêu, cấp mở khóa.
## Mở hết kỹ năng (cấp 20) thì bấm một ô rồi bấm ô khác để đổi chỗ hai kỹ năng.
func _build_skill_panel() -> void:
	var w := 4 * CARD_SIZE.x + 5 * 6.0
	var h := CARD_SIZE.y + 76.0
	skill_panel = Panel.new()
	skill_panel.size = Vector2(w, h)
	skill_panel.position = Vector2(floorf((SCREEN.x - w) / 2.0), 60)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.05, 0.12, 0.95)
	sb.border_color = Color(0.6, 0.55, 0.75)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	skill_panel.add_theme_stylebox_override("panel", sb)
	skill_panel.visible = false
	add_child(skill_panel)
	var title := _make_label("Bộ kỹ năng  (K để đóng)", 12, Color(1.0, 0.85, 0.4))
	title.position = Vector2(8, 4)
	skill_panel.add_child(title)
	skill_hint = _make_label("", 8, Color(0.85, 0.85, 0.95))
	skill_hint.position = Vector2(8, 22)
	skill_hint.size = Vector2(w - 16, 12)
	skill_panel.add_child(skill_hint)
	for i in Skills.SLOT_KEYS.size():
		var button := Button.new()
		button.position = Vector2(6 + i * (CARD_SIZE.x + 6), 38)
		button.size = CARD_SIZE
		button.focus_mode = Control.FOCUS_NONE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.13, 0.11, 0.22, 0.95)
		style.border_color = Color(0.6, 0.55, 0.75)
		style.set_border_width_all(1)
		style.set_corner_radius_all(3)
		var hover := style.duplicate() as StyleBoxFlat
		hover.bg_color = Color(0.2, 0.17, 0.32, 0.95)
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("disabled", style)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", hover)
		button.pressed.connect(_on_skill_card_pressed.bind(i))
		skill_panel.add_child(button)
		var key := _make_label(Skills.SLOT_KEYS[i], 14, Color(1.0, 0.9, 0.5))
		key.position = Vector2(6, 1)
		button.add_child(key)
		var name_label := _make_label("", 9)
		name_label.position = Vector2(24, 5)
		name_label.size = Vector2(CARD_SIZE.x - 28, 12)
		name_label.clip_text = true
		button.add_child(name_label)
		var desc := _make_label("", 8, Color(0.85, 0.85, 0.92))
		desc.position = Vector2(6, 24)
		desc.size = Vector2(CARD_SIZE.x - 12, 76)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_child(desc)
		var info := _make_label("", 8, Color(0.6, 0.9, 1.0))
		info.position = Vector2(6, CARD_SIZE.y - 26)
		info.size = Vector2(CARD_SIZE.x - 12, 24)
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_child(info)
		skill_cards.append({"button": button, "style": style, "hover": hover, "name": name_label,
			"desc": desc, "info": info})
	skill_reset_button = Button.new()
	skill_reset_button.text = "Về thứ tự ban đầu"
	skill_reset_button.position = Vector2(6, h - 30)
	skill_reset_button.size = Vector2(120, 22)
	skill_reset_button.focus_mode = Control.FOCUS_NONE
	skill_reset_button.add_theme_font_size_override("font_size", 9)
	skill_reset_button.pressed.connect(_on_skill_reset_pressed)
	skill_panel.add_child(skill_reset_button)
	var close := Button.new()
	close.text = "Đóng (K)"
	close.position = Vector2(w - 86, h - 30)
	close.size = Vector2(80, 22)
	close.focus_mode = Control.FOCUS_NONE
	close.add_theme_font_size_override("font_size", 9)
	close.pressed.connect(toggle_skill_panel)
	skill_panel.add_child(close)


func _mouse_on_panel(panel: Control) -> bool:
	return panel.visible and Rect2(Vector2.ZERO, panel.size).has_point(panel.get_local_mouse_position())


func toggle_skill_panel() -> void:
	skill_panel.visible = not skill_panel.visible
	skill_pick = -1
	_refresh_skill_panel()


func _refresh_skill_panel() -> void:
	if player == null or not is_instance_valid(player):
		return
	shown_panel = "%d|%s" % [player.level, ",".join(PackedStringArray(player.skill_slots))]
	var can_reorder := player.can_reorder_skills()
	if not can_reorder:
		skill_pick = -1
		skill_hint.text = "Kỹ năng mở dần ở cấp 5, 10, 15, 20. Mở hết thì đổi được thứ tự. Bạn đang cấp %d." % player.level
	elif skill_pick == -1:
		skill_hint.text = "Bấm vào một kỹ năng, rồi bấm ô khác để đổi chỗ hai kỹ năng với nhau."
	else:
		skill_hint.text = "Đã chọn %s. Bấm ô muốn đổi tới (bấm lại ô đó để bỏ chọn)." % player.slot_skill(skill_pick).get("name", "")
	for i in skill_cards.size():
		var card: Dictionary = skill_cards[i]
		var info := player.slot_skill(i)
		var unlocked := player.is_slot_unlocked(i)
		(card["name"] as Label).text = info.get("name", "")
		(card["desc"] as Label).text = info.get("desc", "")
		var line := "Tuyệt chiêu. " if info.get("ult", false) else ""
		if unlocked:
			line += "Hồi chiêu %d giây" % int(info.get("cooldown", 0.0))
		else:
			line += "Mở ở cấp %d" % player.skill_unlock_level(player.skill_slots[i])
		(card["info"] as Label).text = line
		var border := Color(0.6, 0.55, 0.75)
		if info.get("ult", false):
			border = Color(1.0, 0.6, 0.3)
		if i == skill_pick:
			border = Color(1.0, 0.95, 0.4)
		for key in ["style", "hover"]:
			var style: StyleBoxFlat = card[key]
			style.border_color = border
			style.set_border_width_all(2 if i == skill_pick else 1)
		(card["button"] as Button).modulate = Color.WHITE if unlocked else Color(0.6, 0.6, 0.65)
	skill_reset_button.disabled = not can_reorder


func _on_skill_card_pressed(index: int) -> void:
	if player == null or not is_instance_valid(player) or not player.can_reorder_skills():
		return
	if skill_pick == -1:
		skill_pick = index
	elif skill_pick == index:
		skill_pick = -1
	else:
		player.swap_skills(skill_pick, index)
		skill_pick = -1
	_refresh_skill_panel()


func _on_skill_reset_pressed() -> void:
	if player == null or not is_instance_valid(player) or not player.can_reorder_skills():
		return
	player.reset_skill_order()
	skill_pick = -1
	_refresh_skill_panel()


# ---------------------------------------------------------------- Bảng chế tạo

## Bảng chế tạo: tự mở khi đứng gần nồi luyện thuốc / bàn chế tạo (công thức ở scripts/recipes.gd).
func _build_craft_panel() -> void:
	craft_panel = Panel.new()
	craft_panel.position = Vector2(6, 110)  # dưới bản đồ nhỏ
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
	craft_panel.visible = shop_id == ""   # đang mở cửa hàng thì bảng chế tạo đợi


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
	# Nhiều công thức thì chia 2 cột cho bảng khỏi dài quá màn hình
	var cols := 1 if recipes.size() <= 5 else 2
	var per_col := ceili(recipes.size() / float(cols))
	for i in recipes.size():
		var recipe: Dictionary = recipes[i]
		var col := floori(i / float(per_col))
		var row := Panel.new()
		row.position = Vector2(6 + col * (CRAFT_ROW_W + 6.0), 32 + (i % per_col) * 34)
		row.size = Vector2(CRAFT_ROW_W, 31)
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
		button.position = Vector2(CRAFT_ROW_W - 44.0, 5)
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
	craft_panel.size = Vector2(6 + cols * (CRAFT_ROW_W + 6.0), 36 + per_col * 34)
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


# ---------------------------------------------------------------- Cửa hàng (scripts/shops.gd)

## Bảng cửa hàng: tự mở khi đứng gần người bán hàng (có đồng xu trên đầu), đi ra xa thì đóng.
## Tab Mua / Bán (Thợ rèn có thêm Sửa đồ). Mỗi trang SHOP_PAGE dòng, bấm < > để lật trang.
func _build_shop_panel() -> void:
	shop_panel = Panel.new()
	shop_panel.position = Vector2(108, 52)   # bên phải bản đồ nhỏ, dưới thanh máu
	shop_panel.size = Vector2(SHOP_W, 120)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.09, 0.07, 0.94)
	sb.border_color = Color(0.85, 0.7, 0.35)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	shop_panel.add_theme_stylebox_override("panel", sb)
	shop_panel.visible = false
	add_child(shop_panel)
	Game.shop_changed.connect(_on_shop_changed)


func _on_shop_changed(shop: String) -> void:
	if shop == "" or not Shops.SHOPS.has(shop):
		shop_id = ""
		shop_panel.visible = false
		# Bảng chế tạo đang đợi (đứng gần cả trạm chế tạo) thì hiện lại
		craft_panel.visible = craft_station != "" and Recipes.STATIONS.has(craft_station) and not craft_rows.is_empty()
		return
	shop_id = shop
	shop_tab = "buy"
	shop_page = 0
	craft_panel.visible = false
	_fill_shop()
	shop_panel.visible = true


## Một nút có màu (Mua, Bán, Sửa, các tab).
func _shop_button(text: String, pos: Vector2, button_size: Vector2, base: Color, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = button_size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 8)
	var normal := StyleBoxFlat.new()
	normal.bg_color = base
	normal.border_color = base.lightened(0.4)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = base.lightened(0.15)
	var off := normal.duplicate() as StyleBoxFlat
	off.bg_color = Color(0.25, 0.22, 0.2)
	off.border_color = Color(0.4, 0.36, 0.32)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("disabled", off)
	button.pressed.connect(action)
	return button


## Vẽ lại bảng cửa hàng sau khung hình này (không xoá nút ngay lúc nút đang được bấm).
func _refresh_shop_later() -> void:
	if shop_refresh_queued:
		return
	shop_refresh_queued = true
	_fill_shop_now.call_deferred()


func _fill_shop_now() -> void:
	shop_refresh_queued = false
	if shop_panel.visible:
		_fill_shop()


## Vẽ lại bảng cửa hàng theo tab đang chọn.
func _fill_shop() -> void:
	if shop_id == "" or player == null or not is_instance_valid(player):
		return
	for child in shop_panel.get_children():
		shop_panel.remove_child(child)
		child.queue_free()
	shop_shown_gold = player.gold
	var info := Shops.info(shop_id)
	var title := _make_label(info["name"], 10, Color(1.0, 0.85, 0.5))
	title.position = Vector2(8, 3)
	shop_panel.add_child(title)
	var gold := _make_label("Vàng: %d" % player.gold, 8, Color(1.0, 0.9, 0.5))
	gold.position = Vector2(8, 17)
	shop_panel.add_child(gold)
	# Các tab
	var tabs := [["buy", "Mua"], ["sell", "Bán"]]
	if info.get("repair", false):
		tabs.append(["repair", "Sửa đồ"])
	for i in tabs.size():
		var key: String = tabs[i][0]
		var on := key == shop_tab
		shop_panel.add_child(_shop_button(tabs[i][1], Vector2(8 + i * 52, 30), Vector2(48, 15),
			Color(0.55, 0.42, 0.2) if on else Color(0.28, 0.22, 0.16), _on_shop_tab.bind(key)))
	# Danh sách các dòng của tab
	var rows: Array = []   # mỗi dòng: [hình, tên, dòng phụ, màu dòng phụ, chữ nút, nút sáng?, Callable, chữ khi rê chuột, màu viền]
	var plain := Color(0.4, 0.31, 0.22)
	match shop_tab:
		"buy":
			for id in info["sells"]:
				var data := Items.info(id)
				var price := Shops.buy_price(id)
				var tip: String = Equipment.tooltip(Equipment.make(id)) if Equipment.is_gear(id) else "%s\n%s" % [data.get("name", id), data.get("desc", "")]
				rows.append([data.get("icon"), data.get("name", id), "%d vàng" % price,
					Color(1.0, 0.85, 0.4) if player.gold >= price else Color(1.0, 0.5, 0.45),
					"Mua", player.gold >= price, _on_shop_buy.bind(id), tip, plain])
		"sell":
			for i in player.bag.size():
				var entry: Dictionary = player.bag[i]
				var data := Items.info(entry["id"])
				var item_name: String = data.get("name", entry["id"])
				var border := plain
				var tip := "%s\n%s" % [item_name, data.get("desc", "")]
				if Equipment.is_gear(entry["id"]):
					item_name = Equipment.short_name(entry)
					border = Equipment.rarity_info(entry.get("rarity", ""))["color"]
					tip = Equipment.tooltip(entry)
				elif int(entry["count"]) > 1:
					item_name += " x%d" % int(entry["count"])
				rows.append([data.get("icon"), item_name, "Bán được %d vàng" % Shops.sell_price(entry),
					Color(0.6, 1.0, 0.6), "Bán", true, _on_shop_sell.bind(i), tip, border])
		"repair":
			for item in player.all_gear_items():
				var cost := Equipment.repair_cost(item)
				var worn := not item.has("count")   # món trong túi có "count", món đang mặc thì không
				var sub: String = "Còn tốt" if cost == 0 else "Sửa: %d vàng" % cost
				if Equipment.is_broken(item):
					sub = "HỎNG - sửa: %d vàng" % cost
				rows.append([Equipment.icon(item["id"]), Equipment.short_name(item) + (" (đang mặc)" if worn else ""), sub,
					Color(1.0, 0.45, 0.4) if Equipment.is_broken(item) else Color(1.0, 0.85, 0.4),
					"Sửa", cost > 0 and player.gold >= cost, _on_shop_repair.bind(item), Equipment.tooltip(item),
					Equipment.rarity_info(item.get("rarity", ""))["color"]])
	var pages := maxi(1, ceili(rows.size() / float(SHOP_PAGE)))
	shop_page = clampi(shop_page, 0, pages - 1)
	var first := shop_page * SHOP_PAGE
	var shown := mini(SHOP_PAGE, rows.size() - first)
	for i in shown:
		_shop_row(rows[first + i], Vector2(8, 50 + i * 26))
	var bottom := 50.0 + maxi(shown, 1) * 26.0
	if rows.is_empty():
		var empty_text := "Túi đang trống" if shop_tab == "sell" else "Chưa có trang bị nào"
		var empty := _make_label(empty_text, 8, Color(0.8, 0.75, 0.7))
		empty.position = Vector2(10, 54)
		shop_panel.add_child(empty)
	# Dòng cuối: lật trang, sửa tất cả, lời nhắc
	if pages > 1:
		var prev := _shop_button("<", Vector2(SHOP_W - 72, bottom + 1), Vector2(18, 15), Color(0.3, 0.24, 0.18), _on_shop_page.bind(-1))
		prev.disabled = shop_page == 0
		shop_panel.add_child(prev)
		var page_label := _make_label("%d/%d" % [shop_page + 1, pages], 8, Color(0.9, 0.85, 0.75))
		page_label.position = Vector2(SHOP_W - 52, bottom + 2)
		shop_panel.add_child(page_label)
		var next := _shop_button(">", Vector2(SHOP_W - 26, bottom + 1), Vector2(18, 15), Color(0.3, 0.24, 0.18), _on_shop_page.bind(1))
		next.disabled = shop_page >= pages - 1
		shop_panel.add_child(next)
	if shop_tab == "repair":
		var cost := player.repair_all_cost()
		var repair_button := _shop_button("Sửa hết: %d vàng" % cost, Vector2(8, bottom + 1), Vector2(96, 15),
			Color(0.35, 0.5, 0.25), _on_shop_repair_all)
		repair_button.disabled = cost <= 0 or player.gold < cost
		shop_panel.add_child(repair_button)
	else:
		var hint := _make_label("Đi ra xa để đóng", 7, Color(0.8, 0.75, 0.7))
		hint.position = Vector2(8, bottom + 3)
		shop_panel.add_child(hint)
	shop_panel.size = Vector2(SHOP_W, bottom + 20)


func _shop_row(row: Array, pos: Vector2) -> void:
	var panel := Panel.new()
	panel.position = pos
	panel.size = Vector2(SHOP_ROW_W, 24)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.2, 0.15, 0.11)
	st.border_color = row[8]
	st.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", st)
	panel.tooltip_text = row[7]
	shop_panel.add_child(panel)
	if row[0] != null:
		panel.add_child(_make_icon(row[0], Vector2(3, 3), 18.0))
	var label := _make_label(row[1], 8, Color(1.0, 0.95, 0.8))
	label.position = Vector2(25, 0)
	label.size = Vector2(SHOP_ROW_W - 72, 12)
	label.clip_text = true
	panel.add_child(label)
	var sub := _make_label(row[2], 7, row[3])
	sub.position = Vector2(25, 11)
	panel.add_child(sub)
	var button := _shop_button(row[4], Vector2(SHOP_ROW_W - 43, 4), Vector2(39, 16), Color(0.35, 0.5, 0.25), row[6])
	button.disabled = not row[5]
	panel.add_child(button)


func _shop_message(text: String, good: bool) -> void:
	Game.popup_text(player.global_position + Vector2(0, -24), text,
		Color(1.0, 0.9, 0.5) if good else Color(1.0, 0.6, 0.5), 9)


func _on_shop_tab(tab: String) -> void:
	shop_tab = tab
	shop_page = 0
	_refresh_shop_later()


func _on_shop_page(step: int) -> void:
	shop_page += step
	_refresh_shop_later()


func _on_shop_buy(id: String) -> void:
	if player == null or not is_instance_valid(player) or get_tree().paused:
		return
	var err := Shops.buy(player, id)
	if err == "":
		_shop_message("+ %s" % Items.info(id).get("name", id), true)
	else:
		_shop_message(err, false)
	_refresh_shop_later()


func _on_shop_sell(index: int) -> void:
	if player == null or not is_instance_valid(player) or get_tree().paused:
		return
	var got := Shops.sell(player, index)
	if got > 0:
		_shop_message("+%d vàng" % got, true)
	_refresh_shop_later()


func _on_shop_repair(item: Dictionary) -> void:
	if player == null or not is_instance_valid(player) or get_tree().paused:
		return
	var err := player.repair_item(item)
	_shop_message("Sửa xong!" if err == "" else err, err == "")
	_refresh_shop_later()


func _on_shop_repair_all() -> void:
	if player == null or not is_instance_valid(player) or get_tree().paused:
		return
	var err := player.repair_all()
	_shop_message("Sửa xong hết!" if err == "" else err, err == "")
	_refresh_shop_later()


## Mọi thứ trên HUD (trừ túi đồ) để chuột "xuyên qua", để bấm chuột phải đi lại vẫn được.
func _ignore_mouse(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_mouse(child)


func _build_boss_bar() -> void:
	boss_box = Control.new()
	boss_box.position = Vector2((SCREEN.x - 300) / 2.0, 56)  # dưới thanh máu
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
	area_label.position = Vector2(0, 92)
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
		"Chuột phải: đi tới chỗ bấm / bấm vào quái (con trỏ hình kiếm, viền đỏ) để khóa mục tiêu và tự đánh tới khi quái chết",
		"Chuột trái: đánh về phía con trỏ (Cung: giữ để gồng)   A + chuột trái: vừa đi vừa đánh (hiện vòng tầm đánh)   S: đứng lại",
		"Q W E R: giữ phím để xem tầm kỹ năng, thả ra để tung chiêu (chuột phải để hủy). Mở ở cấp 5, 10, 15, 20",
		"F: lướt né   D: uống bình máu (mở ở cấp 30)   B: túi đồ + trang bị   K: bảng kỹ năng / đổi thứ tự   N: nhân vật mới",
		"Bản đồ nhỏ (vòng tròn góc trên bên trái): bấm chuột phải lên bản đồ để đi tới đó   M: bản đồ lớn",
		"Đi tới cây chín để hái. Đi tới 4 trạm chế tạo quanh quảng trường Làng Khởi Nguyên để chế đồ",
		"Người có đồng xu trên đầu bán đồ: tới gần để mua / bán. Bác Sắt thợ rèn sửa trang bị bị mòn",
		"Hầm Ngục Cổ (hang sau đấu trường): 5 tầng, Boss Malakar ở tầng 5. Hạ hết quái một tầng thì rương báu mở khoá",
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
	xp_text.text = "KN %d/%d" % [player.xp, player.xp_to_next]

	# Thuốc / món ăn đang có tác dụng
	var effects := PackedStringArray()
	if player.buff_attack_time > 0.0:
		effects.append("Sức mạnh +%d  (%ds)" % [player.buff_attack, ceili(player.buff_attack_time)])
	if player.buff_speed_time > 0.0:
		effects.append("Nhanh nhẹn  (%ds)" % ceili(player.buff_speed_time))
	if player.regen_left > 0.0:
		effects.append("Hồi máu +%d/giây  (%ds)" % [player.regen_rate, ceili(player.regen_left)])
	buff_label.text = "\n".join(effects)

	# Túi đồ: cập nhật khi đồ trong túi thay đổi
	if bound_player != player:
		bound_player = player
		player.bag_changed.connect(_refresh_bag)
		player.gear_changed.connect(_on_gear_changed)
	# Bản đồ nhỏ: con trỏ nằm trên bản đồ / bảng giao diện thì nhân vật không đi theo chuột dưới đó
	minimap.player = player
	player.mouse_on_ui = minimap.is_mouse_over() or _mouse_on_panel(bag_panel) or _mouse_on_panel(equip_panel) \
		or _mouse_on_panel(shop_panel) \
		or _mouse_on_panel(skill_panel) or _mouse_on_panel(craft_panel)
	if bag_panel.visible:
		bag_gold.text = "Vàng: %d" % player.gold
	if shop_panel.visible and player.gold != shop_shown_gold:
		_refresh_shop_later()   # nhặt được vàng / tiêu vàng: cập nhật nút Mua sáng / tối

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
		var open: bool = not info.is_empty() and player.is_slot_unlocked(i)
		_set_cooldown("skill_%d" % i, player.skill_cd[i] / maxf(cd, 0.01), open, false, player.skill_cd[i])
	if skill_panel.visible and shown_panel != "%d|%s" % [player.level, key]:
		_refresh_skill_panel()
	# Ô bình máu (phím D mở ở cấp 30)
	var potions := player.count_item("potion_hp")
	skill_slots["item"]["count"].text = "x%d" % potions
	_set_cooldown("item", player.item_cd / Player.ITEM_COOLDOWN, player.level >= Player.QUICK_ITEM_LEVEL,
		potions == 0)
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
			var slot: Dictionary = skill_slots["skill_%d" % i]
			var info := player.slot_skill(i)
			(slot["name"] as Label).text = info.get("short", "")
			(slot["lock"] as Label).text = "Cấp %d" % player.skill_unlock_level(player.skill_slots[i])
			# tuyệt chiêu có viền cam (đi theo kỹ năng khi đổi thứ tự)
			var style: StyleBoxFlat = slot["style"]
			style.border_color = Color(1.0, 0.6, 0.3) if info.get("ult", false) else Color(0.6, 0.55, 0.75)
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
