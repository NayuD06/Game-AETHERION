extends Control
## Màn hình tạo nhân vật: chọn tên, vũ khí (cố định cho nhân vật đó) và ngoại hình.
## Bấm "Bắt đầu phiêu lưu" là tạo một tài khoản mới cho nhân vật này (scripts/accounts.gd).
## Giao diện được tạo hoàn toàn bằng code.

const SCREEN := Vector2(640, 360)
const GRASS := preload("res://assets/town/grass.png")
const SHADOW := preload("res://assets/sprites/shadow.png")
const TURN_ROWS := [0, 2, 1, 2]  # hàng sprite sheet khi xoay: xuống, phải, lên, trái
const PREVIEW_SCALE := 6.0
const PREVIEW_CENTER := Vector2(135, 188)  # tâm nhân vật trong khung xem trước

# Mỗi dòng lựa chọn: [khóa trong look, tiêu đề, danh sách]
var rows := []
var look: Dictionary = {}
var value_labels := {}
var name_edit: LineEdit
var weapon_desc: Label
var held_weapon := 0

# Xem trước nhân vật: dùng đúng các lớp hình như trong game, phóng to PREVIEW_SCALE lần
var preview_root: Node2D
var preview_body: Sprite2D
var preview_hold: Node2D    # vũ khí trên tay
var preview_book: Sprite2D  # sách phép bay cạnh người
var anim_time := 0.0


func _ready() -> void:
	# Chế độ quay video (scripts/demo.gd): cảnh nào không quay màn hình này thì vào thẳng màn chơi
	var demo := Demo.requested()
	if demo != "" and demo != "tao_nhan_vat":
		Demo.prepare(demo)
		get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
		return
	Game.set_attack_cursor(false)
	look = Game.appearance.duplicate()
	rows = [
		["weapon", "Vũ khí", _weapon_options()],
		["skin", "Màu da", CharacterParts.SKIN_TONES],
		["hair", "Kiểu tóc", CharacterParts.HAIR_STYLES],
		["hair_color", "Màu tóc", CharacterParts.HAIR_COLORS],
		["outfit", "Trang phục", CharacterParts.OUTFITS],
		["outfit_color", "Màu áo", CharacterParts.OUTFIT_COLORS],
		["hat", "Mũ", CharacterParts.HATS],
	]
	# Đảm bảo mọi lựa chọn đã lưu vẫn nằm trong danh sách
	for row in rows:
		look[row[0]] = int(look.get(row[0], 0)) % (row[2] as Array).size()
	_build_background()
	_build_preview()
	_build_options()
	_build_buttons()
	_refresh()
	if demo != "":
		add_child(Demo.new())


func _weapon_options() -> Array:
	var list := []
	for type in Weapons.ORDER:
		var w := Weapons.info(type)
		list.append(["%s (%s)" % [w["name"], w["class_name"]], w["icon"]])
	return list


# ---------------------------------------------------------------- Dựng giao diện

func _label(text: String, size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 3)
	return l


func _button(text: String, pos: Vector2, button_size: Vector2, font_size: int = 10) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.add_theme_font_size_override("font_size", font_size)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.22, 0.18, 0.32)
	normal.border_color = Color(0.6, 0.55, 0.8)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	normal.set_content_margin_all(1)   # nút gọn, không cao hơn khoảng cách giữa các dòng
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.32, 0.26, 0.46)
	hover.border_color = Color(1.0, 0.85, 0.4)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.15, 0.12, 0.22)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("focus", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.size = button_size   # đặt kích thước sau cùng (sau cỡ chữ, viền) để nút không bị to ra
	add_child(b)
	return b


func _panel(pos: Vector2, panel_size: Vector2) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = panel_size
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.05, 0.1, 0.78)
	sb.border_color = Color(0.45, 0.4, 0.6)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	p.add_theme_stylebox_override("panel", sb)
	add_child(p)
	return p


func _build_background() -> void:
	var bg := TextureRect.new()
	bg.texture = GRASS
	bg.stretch_mode = TextureRect.STRETCH_TILE
	bg.position = Vector2.ZERO
	bg.size = SCREEN
	bg.modulate = Color(0.45, 0.5, 0.45)
	add_child(bg)
	var title := _label("FANTASY: THE AWAKENING", 20, Color(1.0, 0.85, 0.4))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(SCREEN.x, 26)
	title.position = Vector2(0, 8)
	add_child(title)
	var sub := _label("Tạo nhân vật", 11, Color(0.9, 0.9, 1.0))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.size = Vector2(SCREEN.x, 16)
	sub.position = Vector2(0, 34)
	add_child(sub)


func _build_preview() -> void:
	_panel(Vector2(30, 60), Vector2(210, 240))
	preview_root = Node2D.new()
	preview_root.position = PREVIEW_CENTER
	preview_root.scale = Vector2.ONE * PREVIEW_SCALE
	add_child(preview_root)
	var shadow := Sprite2D.new()
	shadow.texture = SHADOW
	shadow.position = Vector2(0, 7)
	preview_root.add_child(shadow)
	preview_body = Sprite2D.new()
	preview_root.add_child(preview_body)
	preview_hold = Node2D.new()
	preview_hold.add_child(Sprite2D.new())
	preview_root.add_child(preview_hold)
	preview_book = Sprite2D.new()
	preview_book.texture = Weapons.info(Weapons.Type.BOOK)["texture"]
	preview_book.scale = Vector2.ONE * 0.75
	preview_root.add_child(preview_book)
	var hint := _label("Nhân vật đang xoay để bạn xem 4 hướng", 7, Color(0.75, 0.75, 0.85))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.size = Vector2(210, 12)
	hint.position = Vector2(30, 282)
	add_child(hint)


func _build_options() -> void:
	_panel(Vector2(256, 60), Vector2(354, 240))
	var y := 68.0
	var name_title := _label("Tên", 10)
	name_title.position = Vector2(268, y + 3)
	add_child(name_title)
	name_edit = LineEdit.new()
	name_edit.text = str(look.get("name", "Lữ Khách"))
	name_edit.max_length = Accounts.NAME_MAX
	name_edit.position = Vector2(370, y)
	name_edit.add_theme_font_size_override("font_size", 10)
	var edit_style := StyleBoxFlat.new()
	edit_style.bg_color = Color(0.05, 0.04, 0.09)
	edit_style.border_color = Color(0.6, 0.55, 0.8)
	edit_style.set_border_width_all(1)
	edit_style.set_corner_radius_all(3)
	edit_style.set_content_margin_all(2)
	edit_style.content_margin_left = 6
	name_edit.add_theme_stylebox_override("normal", edit_style)
	var edit_focus := edit_style.duplicate() as StyleBoxFlat
	edit_focus.border_color = Color(1.0, 0.85, 0.4)
	name_edit.add_theme_stylebox_override("focus", edit_focus)
	name_edit.text_submitted.connect(func(_t): _start_game())
	name_edit.size = Vector2(228, 20)
	add_child(name_edit)
	y += 26.0
	for row in rows:
		var key: String = row[0]
		var title := _label(row[1], 10)
		title.position = Vector2(268, y + 3)
		add_child(title)
		var prev := _button("<", Vector2(370, y), Vector2(24, 20))
		prev.pressed.connect(_change.bind(key, -1))
		var next := _button(">", Vector2(574, y), Vector2(24, 20))
		next.pressed.connect(_change.bind(key, 1))
		var value := _label("", 10, Color(1.0, 0.95, 0.75))
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value.position = Vector2(398, y + 3)
		value.size = Vector2(172, 14)
		add_child(value)
		value_labels[key] = value
		y += 24.0
	weapon_desc = _label("", 8, Color(0.85, 0.88, 1.0))
	weapon_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	weapon_desc.position = Vector2(268, y + 2)
	weapon_desc.size = Vector2(332, 30)
	add_child(weapon_desc)


func _build_buttons() -> void:
	var random := _button("Ngẫu nhiên", Vector2(256, 310), Vector2(110, 26), 11)
	random.pressed.connect(_randomize)
	var start := _button("Bắt đầu phiêu lưu", Vector2(440, 310), Vector2(170, 26), 12)
	start.pressed.connect(_start_game)
	if not Accounts.list().is_empty():
		var back := _button("Quay lại", Vector2(370, 310), Vector2(66, 26), 10)
		back.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/account_select.tscn"))
	var note := _label("Vũ khí gắn liền với nhân vật, không đổi được khi đang chơi.", 8, Color(0.8, 0.8, 0.85))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # bật xuống dòng trước khi đặt kích thước
	note.position = Vector2(30, 312)
	note.size = Vector2(216, 24)
	add_child(note)


# ---------------------------------------------------------------- Thay đổi lựa chọn

func _options_for(key: String) -> Array:
	for row in rows:
		if row[0] == key:
			return row[2]
	return []


func _change(key: String, step: int) -> void:
	var count := _options_for(key).size()
	look[key] = (int(look.get(key, 0)) + step + count) % count
	_refresh()


func _randomize() -> void:
	for row in rows:
		look[row[0]] = randi() % (row[2] as Array).size()
	_refresh()


func _refresh() -> void:
	for row in rows:
		var key: String = row[0]
		var options: Array = row[2]
		var index := int(look.get(key, 0)) % options.size()
		value_labels[key].text = options[index][0]
	held_weapon = Weapons.ORDER[int(look.get("weapon", 0)) % Weapons.ORDER.size()]
	var w := Weapons.info(held_weapon)
	weapon_desc.text = w["desc"]
	CharacterParts.apply_to_sprite(preview_body, look)
	preview_book.visible = held_weapon == Weapons.Type.BOOK
	preview_hold.visible = not preview_book.visible


func _process(delta: float) -> void:
	anim_time += delta
	# Xoay vòng: xuống -> phải -> lên -> trái, mỗi hướng 1.6 giây
	var turn := int(anim_time / 1.6) % 4
	var row: int = TURN_ROWS[turn]
	var face_left := turn == 3
	var col := int(anim_time * 7.0) % 4
	preview_body.frame = row * 4 + col
	preview_body.flip_h = face_left
	CharacterParts.sync_frames(preview_body)
	if preview_hold.visible:
		Weapons.pose_held(preview_hold, preview_body, held_weapon, row, col, face_left)
	if preview_book.visible:
		var side := 1.0 if face_left else -1.0
		preview_book.position = Vector2(side * 11.0, -10.0 + sin(anim_time * 3.0) * 1.5)


func _start_game() -> void:
	var player_name := name_edit.text.strip_edges()
	look["name"] = player_name if player_name != "" else "Lữ Khách"
	Game.appearance = look
	Game.save_appearance()
	# Tạo tài khoản mới cho nhân vật này (đang quay video demo thì không tạo, không lưu)
	if Demo.requested() == "":
		Game.use_account(Accounts.create(look))
	get_tree().change_scene_to_file("res://scenes/main.tscn")
