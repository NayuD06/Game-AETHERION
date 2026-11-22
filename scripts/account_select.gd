extends Control
## Màn hình chọn tài khoản (màn hình đầu tiên khi mở game).
## Mỗi tài khoản là một nhân vật đã lưu (scripts/accounts.gd): bấm "Chơi" để chơi tiếp đúng chỗ lần trước.
## "Tạo tài khoản mới" mở màn hình tạo nhân vật. "Xóa" phải bấm 2 lần mới xóa (xóa rồi không lấy lại được).
## Giao diện được tạo hoàn toàn bằng code.

const SCREEN := Vector2(640, 360)
const GRASS := preload("res://assets/town/grass.png")
const CREATOR_SCENE := "res://scenes/character_creator.tscn"
const MAIN_SCENE := "res://scenes/main.tscn"
const LIST_POS := Vector2(110, 58)
const LIST_SIZE := Vector2(420, 236)
const ROW_HEIGHT := 54.0
const DELETE_CONFIRM_TIME := 3.0   # bấm "Xóa" rồi thì có bấy nhiêu giây để bấm "Chắc chắn?"

var list_box: VBoxContainer
var delete_armed := ""             # id tài khoản đang chờ bấm xóa lần 2
var delete_timer := 0.0
var delete_buttons := {}           # id -> nút Xóa
var full_button: Button


func _ready() -> void:
	# Chế độ quay video (scripts/demo.gd): đi thẳng qua màn hình tạo nhân vật, không dùng tài khoản
	if Demo.requested() != "":
		get_tree().change_scene_to_file.call_deferred(CREATOR_SCENE)
		return
	Game.set_attack_cursor(false)
	Accounts.setup()
	_build_background()
	_build_list()
	_build_buttons()
	_refresh()


func _process(delta: float) -> void:
	if delete_armed == "":
		return
	delete_timer -= delta
	if delete_timer <= 0.0:
		_disarm_delete()


# ---------------------------------------------------------------- Dựng giao diện

func _label(text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 3)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _button(text: String, pos: Vector2, button_size: Vector2, font_size: int, parent: Node,
		color: Color = Color(0.22, 0.18, 0.32)) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = button_size
	b.add_theme_font_size_override("font_size", font_size)
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.border_color = Color(0.6, 0.55, 0.8)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = color.lightened(0.15)
	hover.border_color = Color(1.0, 0.85, 0.4)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = color.darkened(0.3)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("focus", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	parent.add_child(b)
	return b


func _panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	return sb


func _build_background() -> void:
	var bg := TextureRect.new()
	bg.texture = GRASS
	bg.stretch_mode = TextureRect.STRETCH_TILE
	bg.size = SCREEN
	bg.modulate = Color(0.45, 0.5, 0.45)
	add_child(bg)
	var title := _label("FANTASY: THE AWAKENING", 20, Color(1.0, 0.85, 0.4))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(SCREEN.x, 26)
	title.position = Vector2(0, 8)
	add_child(title)
	var sub := _label("Chọn tài khoản", 11, Color(0.9, 0.9, 1.0))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.size = Vector2(SCREEN.x, 16)
	sub.position = Vector2(0, 34)
	add_child(sub)


func _build_list() -> void:
	var frame := Panel.new()
	frame.position = LIST_POS
	frame.size = LIST_SIZE
	frame.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.05, 0.1, 0.78), Color(0.45, 0.4, 0.6)))
	add_child(frame)
	var scroll := ScrollContainer.new()
	scroll.position = LIST_POS + Vector2(6, 6)
	scroll.size = LIST_SIZE - Vector2(12, 12)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	list_box = VBoxContainer.new()
	list_box.custom_minimum_size = Vector2(LIST_SIZE.x - 24, 0)
	list_box.add_theme_constant_override("separation", 4)
	scroll.add_child(list_box)


func _build_buttons() -> void:
	var create := _button("Tạo tài khoản mới", Vector2(LIST_POS.x, 302), Vector2(200, 26), 12, self)
	create.pressed.connect(_create_new)
	full_button = _button("Thêm tài khoản Full", Vector2(LIST_POS.x + LIST_SIZE.x - 200, 302), Vector2(200, 26), 11, self,
		Color(0.32, 0.24, 0.1))
	full_button.pressed.connect(_add_full)
	var note := _label("Game tự lưu mỗi 30 giây, khi lên cấp, khi bấm Esc và khi tắt game.", 8, Color(0.8, 0.8, 0.85))
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.size = Vector2(SCREEN.x, 12)
	note.position = Vector2(0, 336)
	add_child(note)


## Vẽ lại danh sách tài khoản.
func _refresh() -> void:
	for child in list_box.get_children():
		child.queue_free()
	delete_buttons.clear()
	delete_armed = ""
	var accounts := Accounts.list()
	full_button.visible = not Accounts.has_full()
	if accounts.is_empty():
		var empty := _label("Chưa có tài khoản nào.\nBấm \"Tạo tài khoản mới\" để tạo nhân vật và bắt đầu chơi.", 10,
			Color(0.85, 0.85, 0.95))
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.custom_minimum_size = Vector2(LIST_SIZE.x - 24, 120)
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		list_box.add_child(empty)
		return
	for acc in accounts:
		list_box.add_child(_make_row(acc))


func _make_row(acc: Dictionary) -> Panel:
	var row := Panel.new()
	row.custom_minimum_size = Vector2(LIST_SIZE.x - 24, ROW_HEIGHT)
	row.mouse_filter = Control.MOUSE_FILTER_PASS   # để lăn chuột vẫn cuộn được danh sách
	var border := Color(1.0, 0.8, 0.35) if acc["full"] else Color(0.4, 0.36, 0.55)
	row.add_theme_stylebox_override("panel", _panel_style(Color(0.13, 0.11, 0.2, 0.95), border))
	# Hình nhân vật (đứng quay mặt xuống)
	var body := Sprite2D.new()
	CharacterParts.apply_to_sprite(body, acc["look"])
	body.frame = 0
	CharacterParts.sync_frames(body)
	body.scale = Vector2.ONE * 1.5
	body.position = Vector2(26, 33)
	row.add_child(body)
	var w := Weapons.info(Weapons.ORDER[int(acc["weapon"])])
	var icon := Sprite2D.new()
	icon.texture = w["icon"]
	icon.position = Vector2(56, 34)
	row.add_child(icon)
	var name_label := _label(str(acc["name"]), 11, Color(1.0, 0.9, 0.55))
	name_label.position = Vector2(70, 5)
	row.add_child(name_label)
	if acc["full"]:
		var badge := _label("FULL", 8, Color(1.0, 0.75, 0.3))
		var name_width := ThemeDB.fallback_font.get_string_size(str(acc["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
		badge.position = Vector2(70 + name_width + 8, 8)
		row.add_child(badge)
	var info := _label("%s  -  Cấp %d" % [w["class_name"], int(acc["level"])], 9, Color(0.9, 0.92, 1.0))
	info.position = Vector2(70, 21)
	row.add_child(info)
	var time := _label("Chơi lần cuối: %s" % Accounts.time_text(int(acc["last_played"])), 7, Color(0.7, 0.7, 0.8))
	time.position = Vector2(70, 36)
	row.add_child(time)
	var play := _button("Chơi", Vector2(row.custom_minimum_size.x - 138, 13), Vector2(62, 28), 11, row,
		Color(0.16, 0.34, 0.2))
	play.pressed.connect(_play.bind(str(acc["id"])))
	var del := _button("Xóa", Vector2(row.custom_minimum_size.x - 70, 13), Vector2(62, 28), 9, row,
		Color(0.34, 0.14, 0.14))
	del.pressed.connect(_on_delete_pressed.bind(str(acc["id"])))
	delete_buttons[str(acc["id"])] = del
	return row


# ---------------------------------------------------------------- Bấm nút

func _play(id: String) -> void:
	if not Game.use_account(id):
		return
	get_tree().change_scene_to_file(MAIN_SCENE)


func _create_new() -> void:
	# Màn hình tạo nhân vật điền sẵn nhân vật tạo gần nhất (không lấy của tài khoản khác)
	Game.account_id = ""
	Game.progress = {}
	Game.appearance = CharacterParts.DEFAULT.duplicate()
	Game.load_appearance()
	get_tree().change_scene_to_file(CREATOR_SCENE)


func _add_full() -> void:
	Accounts.create_full()
	_refresh()


func _on_delete_pressed(id: String) -> void:
	if delete_armed == id:
		Accounts.delete(id)
		_refresh()
		return
	_disarm_delete()
	delete_armed = id
	delete_timer = DELETE_CONFIRM_TIME
	var b: Button = delete_buttons.get(id)
	if b != null:
		b.text = "Chắc chắn?"
		b.add_theme_color_override("font_color", Color(1.0, 0.6, 0.5))


func _disarm_delete() -> void:
	var b: Button = delete_buttons.get(delete_armed)
	if b != null and is_instance_valid(b):
		b.text = "Xóa"
		b.remove_theme_color_override("font_color")
	delete_armed = ""
