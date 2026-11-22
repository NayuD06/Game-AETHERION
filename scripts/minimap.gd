class_name Minimap
extends Control
## Bản đồ nhỏ hình tròn ở góc trên bên trái màn hình, luôn lấy nhân vật làm tâm.
## - Bấm chuột phải (hoặc chuột trái) lên bản đồ: nhân vật tự tìm đường đi tới chỗ đó (giống LMHT).
##   Giữ chuột rồi kéo trên bản đồ để đổi chỗ đến.
## - Phím M: mở / đóng bản đồ lớn ở giữa màn hình (có tên các khu).
## Chấm trắng: bạn. Chấm đỏ: quái. Chấm cam: trạm chế tạo / lửa trại. Khung trắng: phần đang thấy trên màn hình.
## Bản đồ chỉ hiện khu bạn đang đứng: ở ngoài thì là thế giới bên ngoài (không có hầm ngục),
## xuống hầm ngục thì chỉ hiện tầng đang đứng (hố đen có viền trắng: lối xuống, ô vàng: cầu thang lên).

const SCREEN := Vector2(640, 360)
const SMALL_SCALE := 1.5      # mỗi ô bản đồ (16x16) = bao nhiêu pixel trên bản đồ nhỏ (to hơn = nhìn gần hơn)
const SMALL_SIZE := 100.0     # đường kính bản đồ nhỏ hình tròn (pixel)
const SMALL_POS := Vector2(4, 4)   # góc trên bên trái
const BIG_SCALE := 3.0        # mỗi ô = bao nhiêu pixel trên bản đồ lớn (phím M); tầng hầm ngục nhỏ thì tự phóng to hơn
const CIRCLE_MASK := preload("res://scripts/effects/circle_mask.gdshader")
const DRAG_REPEAT := 0.15     # giữ chuột và kéo: bao lâu đổi chỗ đến một lần

## Màu từng loại ô trên bản đồ (ký tự giống MAP trong scripts/level.gd)
const COLOR_GRASS := Color8(96, 160, 72)
const COLOR_FOREST := Color8(38, 92, 50)
const COLOR_VILLAGE_TREE := Color8(62, 124, 56)
const COLOR_WATER := Color8(62, 132, 205)
const COLOR_BRIDGE := Color8(150, 110, 70)
const COLOR_ROAD := Color8(196, 182, 146)
const COLOR_DIRT := Color8(186, 138, 88)
const COLOR_ROCKY := Color8(138, 122, 104)
const COLOR_CROPS := Color8(206, 176, 84)
const COLOR_FENCE := Color8(128, 92, 58)
const COLOR_PLAZA := Color8(178, 178, 190)
const COLOR_BUILDING := Color8(176, 82, 62)
const COLOR_ROCK := Color8(112, 112, 104)
const COLOR_WALL := Color8(84, 84, 96)
const COLOR_ARENA := Color8(168, 168, 162)
const COLOR_DUNGEON := Color8(88, 82, 104)
const COLOR_DUNGEON_WALL := Color8(36, 32, 46)
const COLOR_VOID := Color8(24, 22, 32)          # khối đá đặc (không đi tới được)
const COLOR_MUSHROOM := Color8(200, 92, 92)
const COLOR_POISON := Color8(96, 176, 70)       # đầm độc
const COLOR_LAVA := Color8(244, 126, 40)        # dung nham
const COLOR_DUNGEON_PROP := Color8(64, 60, 78)  # khối đá, bia, bình gốm trong hầm ngục

var player: Player
var level: Level
var map_texture: ImageTexture
var big := false
var region := -1                        # khu đang vẽ: 0 = thế giới bên ngoài, 1..5 = tầng hầm ngục
var region_rect := Rect2i()             # khung của khu đó (theo ô)
var big_scale := BIG_SCALE
var dragging := false
var drag_timer := 0.0
var hint: Label
var arena_center := Vector2(-1, -1)     # giữa đấu trường (theo ô), để ghi tên trên bản đồ lớn


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	visible = false
	var mask := ShaderMaterial.new()   # cắt hình vẽ thành hình tròn
	mask.shader = CIRCLE_MASK
	material = mask
	hint = Label.new()
	hint.add_theme_font_size_override("font_size", 7)
	hint.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8))
	hint.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	hint.add_theme_constant_override("outline_size", 3)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.text = "M: bản đồ lớn"
	get_parent().add_child.call_deferred(hint)


func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player) or player.level_ref == null:
		visible = false
		hint.visible = false
		return
	if level != player.level_ref:
		level = player.level_ref
		region = -1
		visible = true
	# Sang khu khác (vào / ra hầm ngục, đổi tầng): vẽ lại bản đồ của khu mới
	var fl := level.floor_of(player.global_position)
	if fl != -1 and fl != region:
		region = fl
		region_rect = level.region_rect(region)
		_build_texture()
		_layout()
	hint.visible = visible
	# Giữ chuột và kéo trên bản đồ: liên tục đổi chỗ đến
	if dragging:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			drag_timer -= delta
			var mouse := get_local_mouse_position()
			if drag_timer <= 0.0 and _has_point(mouse):
				drag_timer = DRAG_REPEAT
				player.command_move(world_at(mouse), false)
		else:
			dragging = false
	queue_redraw()


## Con trỏ chuột có đang nằm trên bản đồ không (để nhân vật không đi theo chuột dưới bản đồ).
func is_mouse_over() -> bool:
	return visible and _has_point(get_local_mouse_position())


## Vùng bấm được: bản đồ nhỏ chỉ tính phần trong hình tròn (4 góc vuông bên ngoài bấm xuyên qua được).
func _has_point(point: Vector2) -> bool:
	if big:
		return Rect2(Vector2.ZERO, size).has_point(point)
	return point.distance_to(size / 2.0) <= size.x / 2.0


func toggle_big() -> void:
	if level == null:
		return
	big = not big
	_layout()


func _map_scale() -> float:
	return big_scale if big else SMALL_SCALE


func _layout() -> void:
	if big:
		# phóng to cho vừa màn hình (thế giới bên ngoài: BIG_SCALE, tầng hầm ngục nhỏ hơn nên to hơn)
		var fit := minf(560.0 / region_rect.size.x, 290.0 / region_rect.size.y)
		big_scale = clampf(floorf(fit * 2.0) / 2.0, 1.0, maxf(BIG_SCALE, 6.0))
		size = Vector2(region_rect.size) * big_scale
		position = ((SCREEN - size) / 2.0).floor()
		hint.text = "Bấm chuột phải lên bản đồ để đi tới đó.   M: đóng bản đồ lớn"
		hint.position = Vector2(position.x, position.y + size.y + 2)
	else:
		size = Vector2(SMALL_SIZE, SMALL_SIZE)
		position = SMALL_POS
		hint.text = "M: bản đồ lớn"
		hint.position = Vector2(position.x + size.x - 12, position.y + size.y - 8)
	var mask := material as ShaderMaterial
	mask.set_shader_parameter("center", size / 2.0)
	mask.set_shader_parameter("radius", size.x / 2.0 - 0.5)
	mask.set_shader_parameter("enabled", not big)
	# bản đồ nhỏ trượt theo nhân vật nên làm mịn, bản đồ lớn phóng to nên giữ ô vuông sắc nét
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if big else CanvasItem.TEXTURE_FILTER_LINEAR


## Vị trí (trong khung) của ô (0, 0) của màn chơi. Bản đồ lớn: góc trên bên trái khung là góc của khu đang đứng.
## Bản đồ nhỏ: nhân vật luôn ở giữa vòng tròn.
func _origin() -> Vector2:
	if big:
		return -Vector2(region_rect.position) * big_scale
	return size / 2.0 - level.to_local(player.global_position) / Level.TILE * SMALL_SCALE


## Đổi điểm trên bản đồ (toạ độ trong khung bản đồ) ra vị trí trong thế giới, và ngược lại.
func world_at(local: Vector2) -> Vector2:
	return level.to_global((local - _origin()) / _map_scale() * Level.TILE)


func map_at(world: Vector2) -> Vector2:
	return _from_level(level.to_local(world))


## Toạ độ trong màn chơi (Level) -> toạ độ trong khung bản đồ.
func _from_level(local: Vector2) -> Vector2:
	return _origin() + local / Level.TILE * _map_scale()


func _gui_input(event: InputEvent) -> void:
	if player == null or not is_instance_valid(player) or level == null:
		return
	var mb := event as InputEventMouseButton
	if mb != null and mb.pressed and (mb.button_index == MOUSE_BUTTON_RIGHT or mb.button_index == MOUSE_BUTTON_LEFT):
		player.command_move(world_at(mb.position), true)
		dragging = true
		drag_timer = DRAG_REPEAT
		accept_event()


# ---------------------------------------------------------------- Vẽ bản đồ

## Mỗi ô của khu đang đứng thành 1 pixel màu.
func _build_texture() -> void:
	var r := region_rect
	var image := Image.create_empty(r.size.x, r.size.y, false, Image.FORMAT_RGBA8)
	var arena_box := Rect2()
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			image.set_pixel(x - r.position.x, y - r.position.y, _tile_color(x, y))
			if level.cell(x, y) == ":":
				arena_box = Rect2(x, y, 1, 1) if arena_box.size == Vector2.ZERO else arena_box.expand(Vector2(x + 1, y + 1))
	map_texture = ImageTexture.create_from_image(image)
	arena_center = arena_box.get_center() if arena_box.size != Vector2.ZERO else Vector2(-1, -1)


func _tile_color(x: int, y: int) -> Color:
	var c := level.cell(x, y)
	var in_dungeon := region > 0
	var in_arena := level.arena_column != -1 and x >= level.arena_column and not in_dungeon
	if Level.WALL_CHARS.contains(c) or c == "G":
		if _solid_rock(x, y):
			return COLOR_VOID
		return COLOR_DUNGEON_WALL if in_dungeon else COLOR_WALL
	if in_dungeon:
		var tint: Color = Dungeon.FLOORS[region - 1]["tint"]
		match c:
			"]":
				return COLOR_POISON
			"|":
				return COLOR_LAVA
			"*":
				return COLOR_MUSHROOM
			"K", "?", "u", "I":
				return COLOR_DUNGEON_PROP
		return COLOR_DUNGEON * tint
	if level.plaza_cells.has(Vector2i(x, y)):
		return COLOR_WATER if c == "F" else COLOR_PLAZA
	match c:
		"T":
			return COLOR_FOREST
		"t", "7", "o":
			return COLOR_VILLAGE_TREE
		"~", "$", "V":
			return COLOR_WATER
		"[":
			return COLOR_BRIDGE
		"_":
			return COLOR_ROAD
		"-", "p":
			return COLOR_DIRT
		"%":
			return COLOR_ROCKY
		"4", "5", "6":
			return COLOR_CROPS
		"f":
			return COLOR_FENCE
		"R", "U", "W", "M", "H", "x", "!", "&":
			return COLOR_BUILDING
		"r":
			return COLOR_ROCK
		"*":
			return COLOR_MUSHROOM
	return COLOR_ARENA if in_arena else COLOR_GRASS


## Ô tường nằm giữa khối đá (8 ô xung quanh đều là tường): vẽ màu tối như khoảng trống.
func _solid_rock(x: int, y: int) -> bool:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var n := level.cell(x + dx, y + dy)
			if not (Level.WALL_CHARS.contains(n) or n == "G"):
				return false
	return true


func _draw() -> void:
	if level == null or map_texture == null:
		return
	var s := _map_scale()
	var mid := size / 2.0
	if not big:
		draw_circle(mid, size.x / 2.0, COLOR_VOID)   # nền ngoài mép bản đồ
	draw_texture_rect(map_texture, Rect2(_from_level(Vector2(region_rect.position) * Level.TILE),
		Vector2(region_rect.size) * s), false)
	# Trạm chế tạo, lửa trại
	for st in level.stations:
		var p := _from_level(Vector2(st["pos"]))
		if not _in_region(Vector2(st["pos"])) or _off(p):
			continue
		draw_rect(Rect2(p - Vector2(1.5, 1.5), Vector2(3, 3)), Color(1.0, 0.6, 0.2))
	# Cửa hang (tím khi còn phong ấn)
	if region == 0 and level.cave_entrance != Vector2.INF:
		var cave := _from_level(level.cave_entrance)
		draw_circle(cave, 2.5, Color(0.1, 0.05, 0.1))
		draw_circle(cave, 1.6, Color(0.7, 0.35, 1.0) if not level.gate_open else Color(0.25, 0.2, 0.25))
	# Hầm ngục: cầu thang, bia cổ ngữ, cổng xoáy
	if region > 0:
		var r := 2.0 if not big else 3.5
		for st in level.stairs:
			if st["floor"] != region:
				continue
			var p := _from_level(st["pos"])
			if st["kind"] == "down":
				draw_circle(p, r + 1.2, Color(1, 1, 1) if not st["sealed"] else Color(0.75, 0.4, 1.0))
				draw_circle(p, r, Color(0.05, 0.03, 0.08))
			else:
				draw_rect(Rect2(p - Vector2(r, r), Vector2(r, r) * 2.0), Color(1.0, 0.92, 0.6))
		for rune in level.runes:
			if rune["floor"] == region:
				draw_circle(_from_level(rune["pos"]), r * 0.8, Color(0.5, 1.0, 0.95) if rune["lit"] else Color(0.45, 0.47, 0.55))
		# Rương báu: màu theo loại rương (tối = còn khoá, mờ hẳn = đã mở)
		for chest in level.chests:
			if not is_instance_valid(chest) or chest.floor_index != region:
				continue
			var cp := _from_level(chest.position)
			if _off(cp):
				continue
			var col: Color = Chest.TIERS[chest.tier]["color"]
			if chest.opened:
				col = col.darkened(0.65)
			elif chest.locked:
				col = col.darkened(0.3)
			draw_rect(Rect2(cp - Vector2(r, r * 0.8), Vector2(r * 2.0, r * 1.6)), Color(0.05, 0.03, 0.05))
			draw_rect(Rect2(cp - Vector2(r - 0.7, r * 0.8 - 0.7), Vector2(r * 2.0 - 1.4, r * 1.6 - 1.4)), col)
		if level.altar_position != Vector2.INF and _in_region(level.altar_position):
			draw_circle(_from_level(level.altar_position), r + 1.0,
				Color(0.8, 0.45, 1.0) if level.portal_open else Color(0.4, 0.3, 0.45))
	# Quái
	var dot := 1.3 if not big else 2.2
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or not is_instance_valid(enemy) or enemy.is_dead:
			continue
		var p := map_at(enemy.global_position)
		if _off(p) or not _in_region(level.to_local(enemy.global_position)):
			continue
		if enemy.is_in_group("boss"):
			draw_circle(p, dot * 2.4, Color(0.1, 0.0, 0.0))
			draw_circle(p, dot * 1.8, Color(1.0, 0.15, 0.1))
		else:
			draw_circle(p, dot, Color(0.85, 0.45, 1.0) if enemy.is_elite else Color(1.0, 0.2, 0.15))
	# Đường đang đi tới
	if player.path_index < player.path.size():
		var points := PackedVector2Array([map_at(player.global_position)])
		for i in range(player.path_index, player.path.size()):
			points.append(map_at(player.path[i]))
		draw_polyline(points, Color(0.55, 1.0, 0.6, 0.85), 1.0 if not big else 1.5)
		var goal := points[points.size() - 1]
		draw_circle(goal, 1.5 if not big else 2.5, Color(0.55, 1.0, 0.6))
	# Khung phần đang thấy trên màn hình
	var view_size := player.get_viewport_rect().size / player.camera.zoom
	var center := player.camera.get_screen_center_position()
	var view := Rect2(map_at(center - view_size / 2.0), view_size / Level.TILE * s)
	draw_rect(view, Color(1, 1, 1, 0.75), false, 1.0)
	# Người chơi
	var me := map_at(player.global_position)
	var r := 2.4 if not big else 3.6
	draw_circle(me, r + 1.0, Color(0.05, 0.15, 0.4))
	draw_circle(me, r, Color(1.0, 1.0, 1.0))
	draw_line(me, me + player.facing.normalized() * (r + 2.5), Color(0.3, 0.75, 1.0), 1.0)
	if big:
		_draw_area_names()
	elif region > 0:
		_draw_floor_label()
	# Viền khung: vòng tròn (bản đồ nhỏ) hoặc khung chữ nhật (bản đồ lớn)
	if big:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.04, 0.1), false, 2.0)
		draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), Color(0.75, 0.68, 0.5), false, 1.0)
	else:
		draw_arc(mid, size.x / 2.0 - 1.0, 0.0, TAU, 72, Color(0.05, 0.04, 0.1), 2.0, true)
		draw_arc(mid, size.x / 2.0 - 2.5, 0.0, TAU, 72, Color(0.85, 0.75, 0.5), 1.5, true)


## Điểm (toạ độ trong màn chơi) có nằm trong khu đang vẽ không.
func _in_region(local: Vector2) -> bool:
	return region_rect.has_point(Vector2i(floori(local.x / Level.TILE), floori(local.y / Level.TILE)))


## Điểm p nằm ngoài vòng tròn bản đồ nhỏ (khỏi vẽ cho nhẹ máy).
func _off(p: Vector2) -> bool:
	return not big and p.distance_to(size / 2.0) > size.x / 2.0 + 4.0


## Tên các khu trên bản đồ lớn.
func _draw_area_names() -> void:
	var font := get_theme_default_font()
	var names := []
	if region == 0:
		for area in Level.AREAS:
			var rect: Rect2i = area["rect"]
			names.append([area["name"], Vector2(rect.position) + Vector2(rect.size) / 2.0])
		if arena_center.x >= 0.0:
			names.append(["Đấu Trường", arena_center])
	else:
		# tầng hầm ngục: ghi tên tầng ở mép trên
		names.append([Dungeon.floor_name(region), Vector2(region_rect.get_center().x, region_rect.position.y + 1.5)])
	for item in names:
		var text: String = item[0]
		var pos: Vector2 = _origin() + item[1] * big_scale
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		var at := pos - Vector2(w / 2.0, -4)
		at.x = clampf(at.x, 3.0, size.x - w - 3.0)   # không cho chữ tràn ra ngoài khung
		draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 4, Color(0, 0, 0, 0.85))
		draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.95, 0.8))


## Bản đồ nhỏ trong hầm ngục: ghi "Tầng N" ở mép trên vòng tròn.
func _draw_floor_label() -> void:
	var font := get_theme_default_font()
	var text := "Tầng %d" % region
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
	var at := Vector2((size.x - w) / 2.0, 15.0)
	draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, 3, Color(0, 0, 0, 0.9))
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.85, 0.55))
	# Còn bao nhiêu quái (hạ hết thì rương trên tầng mở khoá)
	var cleared: bool = level.floor_cleared.has(region)
	var sub: String = "Đã dọn sạch" if cleared else "Còn %d quái" % level.floor_enemies_left(region)
	var sw := font.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 7).x
	var sub_at := Vector2((size.x - sw) / 2.0, size.y - 8.0)
	draw_string_outline(font, sub_at, sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, 3, Color(0, 0, 0, 0.9))
	draw_string(font, sub_at, sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 7,
		Color(0.55, 1.0, 0.55) if cleared else Color(1.0, 0.7, 0.6))
