extends Node
## Autoload "Game" (luôn tồn tại, gọi ở bất kỳ đâu bằng `Game.xxx`).
## - Cài đặt phím điều khiển.
## - Chứa các tín hiệu (signal) dùng chung giữa các phần của game.
## - Một vài hàm tiện ích: hiện chữ bay lên, rung màn hình.

signal message(text: String)                       # Hiện thông báo giữa màn hình
signal area_entered(area_name: String)             # Vào khu vực mới
signal boss_started(boss_name: String)             # Boss bắt đầu chiến đấu
signal boss_health_changed(current: int, maximum: int)
signal boss_armor_changed(armor: int)
signal boss_defeated
signal game_won
signal station_changed(station: String)            # Đứng gần trạm chế tạo ("pot", "bench"), "" = đi xa
signal shop_changed(shop: String)                  # Đứng gần người bán hàng (tên trong scripts/shops.gd), "" = đi xa

# Phím bàn phím cho từng hành động. Bạn có thể sửa ở đây,
# hoặc tự tạo action cùng tên trong Project > Project Settings > Input Map
# (nếu đã có trong Input Map thì phần dưới sẽ bỏ qua action đó).
## Điều khiển chính bằng chuột kiểu Liên Minh Huyền Thoại / Dota.
## Phím mũi tên và J vẫn dùng được nếu muốn chơi bằng bàn phím.
const KEY_BINDINGS := {
	"move_click": [],              # chuột phải: đi / chọn quái để đánh
	"attack_mouse": [],            # chuột trái: đánh về phía con trỏ
	"attack_move": [KEY_A],        # A rồi chuột trái: vừa đi vừa đánh
	"stop": [KEY_S],               # đứng lại
	"skill_1": [KEY_Q],
	"skill_2": [KEY_W],
	"skill_3": [KEY_E],
	"skill_ult": [KEY_R],          # tuyệt chiêu
	"dash": [KEY_F],               # lướt
	"use_item": [KEY_D],           # dùng bình máu
	"inventory": [KEY_B],          # mở / đóng túi đồ
	"world_map": [KEY_M],          # mở / đóng bản đồ lớn
	"skills_menu": [KEY_K],        # bảng kỹ năng: xem cấp mở khóa, đổi thứ tự kỹ năng Q W E R
	"test_level_up": [KEY_L],      # chỉ để chạy thử: lên cấp ngay (xem TEST_LEVEL_KEY trong player.gd)
	"move_up": [KEY_UP],
	"move_down": [KEY_DOWN],
	"move_left": [KEY_LEFT],
	"move_right": [KEY_RIGHT],
	"attack": [KEY_J],
	"new_character": [KEY_N],
	"skill_fire": [KEY_U],
	"skill_thunder": [KEY_I],
	"pause": [KEY_ESCAPE, KEY_P],
	"restart": [KEY_R],
}

const MOUSE_BINDINGS := {
	"move_click": [MOUSE_BUTTON_RIGHT],
	"attack_mouse": [MOUSE_BUTTON_LEFT],
}

const CURSOR_NORMAL := preload("res://assets/ui/cursor_normal.png")
const CURSOR_ATTACK := preload("res://assets/ui/cursor_attack.png")
var attack_cursor := false


## Ngoại hình + vũ khí của nhân vật (chọn ở màn hình tạo nhân vật, lưu vào máy).
const SAVE_PATH := "user://nhan_vat.cfg"
var appearance: Dictionary = CharacterParts.DEFAULT.duplicate()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_inputs()
	load_appearance()
	Input.set_custom_mouse_cursor(CURSOR_NORMAL, Input.CURSOR_ARROW, Vector2(2, 2))


## Đổi con trỏ chuột thành hình kiếm khi rê lên quái.
func set_attack_cursor(on: bool) -> void:
	if on == attack_cursor:
		return
	attack_cursor = on
	Input.set_custom_mouse_cursor(CURSOR_ATTACK if on else CURSOR_NORMAL, Input.CURSOR_ARROW, Vector2(2, 2))


func load_appearance() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	for key in CharacterParts.DEFAULT:
		appearance[key] = cfg.get_value("nhan_vat", key, CharacterParts.DEFAULT[key])


func save_appearance() -> void:
	var cfg := ConfigFile.new()
	for key in appearance:
		cfg.set_value("nhan_vat", key, appearance[key])
	cfg.save(SAVE_PATH)


func _setup_inputs() -> void:
	for action in KEY_BINDINGS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in KEY_BINDINGS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
		for button in MOUSE_BINDINGS.get(action, []):
			var mev := InputEventMouseButton.new()
			mev.button_index = button
			InputMap.action_add_event(action, mev)


## Hiện một dòng chữ nhỏ bay lên rồi mờ dần (số sát thương, "LÊN CẤP!"...).
func popup_text(world_pos: Vector2, text: String, color: Color = Color.WHITE, font_size: int = 10) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", font_size)
	label.size = Vector2(120, 16)
	label.position = world_pos - Vector2(60, 22) + Vector2(randf_range(-4, 4), 0)
	label.z_index = 100
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene.add_child(label)
	var tw := label.create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "position:y", label.position.y - 18.0, 0.7)
	tw.tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.3)
	tw.chain().tween_callback(label.queue_free)


## Rung màn hình (camera nằm trong Player).
func shake(strength: float) -> void:
	get_tree().call_group("player", "shake", strength)


## "Khựng hình" một chút khi đánh trúng, giúp đòn đánh có cảm giác nặng tay.
var _hit_stop_active := false

func hit_stop(duration: float = 0.05, time_scale: float = 0.05) -> void:
	if _hit_stop_active:
		return
	_hit_stop_active = true
	Engine.time_scale = time_scale
	# Tham số cuối = true: đếm giờ theo thời gian thật, không bị chậm theo time_scale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	_hit_stop_active = false


## Bắn ra một chùm hạt nhỏ (bụi, máu quái, mảnh vỡ...).
func burst(world_pos: Vector2, color: Color, amount: int = 10, speed: float = 60.0,
		gravity: float = 120.0, life: float = 0.45, size: float = 2.0) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = maxi(amount, 1)
	p.lifetime = life
	p.explosiveness = 1.0
	p.direction = Vector2.UP
	p.spread = 180.0
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	p.gravity = Vector2(0, gravity)
	p.damping_min = 20.0
	p.damping_max = 40.0
	p.scale_amount_min = size * 0.6
	p.scale_amount_max = size
	var ramp := Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color.r, color.g, color.b, 0.0))
	p.color_ramp = ramp
	p.position = world_pos
	p.z_index = 20
	scene.add_child(p)
	p.emitting = true
	get_tree().create_timer(life + 0.2, false).timeout.connect(p.queue_free)


## Bụi dưới chân khi chạy / lướt.
func dust(world_pos: Vector2, amount: int = 4) -> void:
	burst(world_pos, Color(0.93, 0.9, 0.8, 0.8), amount, 25.0, -10.0, 0.35, 2.5)
