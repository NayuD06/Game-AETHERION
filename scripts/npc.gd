extends Node2D
## Dân làng (NPC): đứng một chỗ hoặc đi dạo quanh chỗ của mình.
## Khi người chơi đi tới gần, dân làng quay sang và nói một câu (hiện bong bóng chữ trên đầu).
## Mỗi lần tới gần sẽ nói câu tiếp theo trong danh sách.
## Tên, lời thoại và ngoại hình của từng người nằm trong NPC_DATA ở scripts/level.gd.

const SHADOW_TEXTURE := preload("res://assets/sprites/shadow.png")
const TALK_DISTANCE := 28.0     # đứng gần bao nhiêu pixel thì nói chuyện
const WALK_SPEED := 18.0
const BUBBLE_TIME := 5.0        # bong bóng chữ hiện bao lâu (giây)

var npc_name := "Dân làng"
var lines: Array = []           # các câu nói
var look: Dictionary = {}       # ngoại hình (giống màn hình tạo nhân vật)
var wander_radius := 0.0        # 0 = đứng yên, lớn hơn 0 = đi dạo trong bán kính này (pixel)
var level_ref: Node             # màn chơi (dùng để biết chỗ nào đi được)

var sprite: Sprite2D
var name_label: Label
var bubble: Label
var player: Node2D
var home := Vector2.ZERO
var target := Vector2.ZERO
var wait_time := 0.0
var walk_time := 0.0
var bubble_timer := 0.0
var facing := Vector2.DOWN
var player_near := false
var line_index := 0


## Nhận dữ liệu từ NPC_DATA: { "name", "lines", "look", "wander" }.
func setup(data: Dictionary) -> void:
	npc_name = data.get("name", npc_name)
	lines = data.get("lines", lines)
	look = data.get("look", look)
	wander_radius = float(data.get("wander", 0.0))


func _ready() -> void:
	home = position
	target = position
	wait_time = randf_range(0.5, 3.0)
	var shadow := Sprite2D.new()
	shadow.texture = SHADOW_TEXTURE
	shadow.position = Vector2(0, 7)
	add_child(shadow)
	sprite = Sprite2D.new()
	add_child(sprite)
	CharacterParts.apply_to_sprite(sprite, look)
	name_label = _make_name_label()
	bubble = _make_bubble()
	_update_frame(Vector2.ZERO, 0.0)


func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	var near := player != null and global_position.distance_to(player.global_position) < TALK_DISTANCE
	if near and not player_near:
		_say_next()
	player_near = near

	var move := Vector2.ZERO
	if near:
		facing = (player.global_position - global_position).normalized()  # quay sang người chơi
	elif wander_radius > 0.0:
		move = _wander(delta)
	_update_frame(move, delta)

	if bubble.visible:
		bubble_timer -= delta
		if bubble_timer <= 0.0 or (not near and bubble_timer < BUBBLE_TIME - 1.5):
			bubble.visible = false


## Đi dạo: chọn một điểm ngẫu nhiên quanh nhà, đi tới đó, đứng nghỉ một lúc rồi đi tiếp.
func _wander(delta: float) -> Vector2:
	if position.distance_to(target) < 1.5:
		wait_time -= delta
		if wait_time <= 0.0:
			wait_time = randf_range(1.5, 4.0)
			target = home + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * wander_radius
		return Vector2.ZERO
	var dir := (target - position).normalized()
	var next := position + dir * WALK_SPEED * delta
	if level_ref and level_ref.has_method("is_open") and not level_ref.is_open(get_parent().to_global(next), 5.0):
		target = position  # vướng cây / nhà thì đứng lại, lát nữa chọn chỗ khác
		return Vector2.ZERO
	position = next
	facing = dir
	return dir


func _say_next() -> void:
	if lines.is_empty():
		return
	bubble.text = str(lines[line_index % lines.size()])
	line_index += 1
	bubble.visible = true
	bubble_timer = BUBBLE_TIME


## Chọn khung hình giống người chơi: hàng 0 = đi xuống, 1 = đi lên, 2 = đi ngang.
func _update_frame(move: Vector2, delta: float) -> void:
	var row := 0
	if absf(facing.x) > absf(facing.y) * 0.9:
		row = 2
		sprite.flip_h = facing.x < 0.0
	elif facing.y < 0.0:
		row = 1
	var col := 0
	if move != Vector2.ZERO:
		walk_time += delta * 8.0
		col = int(walk_time) % 4
	else:
		walk_time = 0.0
	sprite.frame = row * 4 + col
	CharacterParts.sync_frames(sprite)


func _make_name_label() -> Label:
	var label := Label.new()
	label.text = npc_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 7)
	label.add_theme_color_override("font_color", Color(1.0, 0.93, 0.6))
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.08))
	label.add_theme_constant_override("outline_size", 3)
	label.size = Vector2(90, 10)
	label.position = Vector2(-45, -33)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 50
	add_child(label)
	return label


func _make_bubble() -> Label:
	var label := Label.new()
	var box := StyleBoxFlat.new()
	box.bg_color = Color(1.0, 0.98, 0.9, 0.95)
	box.border_color = Color(0.25, 0.15, 0.2)
	box.set_border_width_all(1)
	box.set_corner_radius_all(3)
	box.content_margin_left = 4
	box.content_margin_right = 4
	box.content_margin_top = 2
	box.content_margin_bottom = 2
	label.add_theme_stylebox_override("normal", box)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(0.22, 0.13, 0.17))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(140, 0)
	label.size = Vector2(140, 12)
	label.position = Vector2(-70, -48)
	label.grow_vertical = Control.GROW_DIRECTION_BEGIN  # chữ dài thì bong bóng cao lên phía trên
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 60
	label.visible = false
	add_child(label)
	return label
