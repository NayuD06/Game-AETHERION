class_name Level
extends Node2D
## Màn chơi được vẽ từ bản đồ chữ (MAP) bên dưới.
## Hình ảnh: bộ Kenney Tiny Town (làng, cỏ) và Kenney Roguelike RPG (rừng, đấu trường, tàn tích).
## Bạn có thể tự sửa bản đồ: mỗi ký tự là một ô 16x16 pixel.
##
##   T  cây (chặn đường)          #  tường đá (chặn đường)
##   ~  nước (chặn đường)         G  cổng phong ấn (mở khi hạ Boss)
##   o  bụi cây (chặn đường)      r  tảng đá (chặn đường)
##   .  cỏ      ,  cỏ có hoa      :  sàn đá đấu trường     ;  sàn tàn tích
##   _  đường lát đá    f  hàng rào    w  giếng    q  biển báo (đọc khi đi tới gần)
##   y  tổ ong    t  cây trong làng    n  nấm (trang trí)
##   d  bù nhìn tập đánh    D  bù nhìn có giáp (thử Thương phá giáp)
##   R U W M  nhà (góc trên bên trái), các ô 'x' là phần còn lại của ngôi nhà
##            R, U, W rộng 4 ô, M rộng 3 ô, tất cả cao 3 ô
##   P  vị trí bắt đầu của người chơi
##   s  slime    b  dơi    a  cung thủ xương    B  Boss
##   h  bình máu    m  bình năng lượng    c  pha lê sức mạnh
##   A  bệ thờ cổ (đích đến của bản demo)
##
## VILLAGE_END_COLUMN cột đầu là làng, tiếp theo là rừng (cỏ) tới cột ':' đầu tiên,
## giữa là đấu trường (đá),
## bên phải cổng G là tàn tích. Quái bên phải cổng tự động mạnh hơn (elite).

const TILE := 16
const VILLAGE_END_COLUMN := 30  # các cột bên trái cột này là Làng Khởi Nguyên

## Chữ trên các biển báo 'q', theo thứ tự xuất hiện (đọc từ trên xuống, trái sang phải).
const SIGN_TEXTS := [
	"Làng Khởi Nguyên. Dùng WASD để đi, Space để lướt né.",
	"Bãi tập: thử vũ khí của bạn. Bù nhìn có khiên rất cứng, Thương phá giáp dễ nhất.",
	"Phía đông là Rừng Hoang. Quái vật đang tràn tới, hãy cẩn thận!",
]

const MAP := """
TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT###############################
T.............................T.........,.........,..................,.###############################
T........t.............,......T.......,...o...,.....................,..###############################
T...........Uxxx..........t...T..o..............TTT..........,.....o,..##################;;;;;;;;;;;;#
T...Rxxx....xxxx..............T....,............TTT...b........TTT.....##################;;r;;;;;;;;;#
T...xxxx....xxxx....Wxxx......T..,....TTT......,......,..o.....TTT.....##################;;;;;;;c;;;;#
T...xxxx......_.....xxxx......T....,..TTT.....s................TTT.a...#::::::::::::::::#;;a;;;;;;a;;#
T....._......._..n..xxxx....t.T..,....TTT...........s.........,........#::::::::::::::::#;;;;;;;;;;;;#
T....._..t...._......._.......T.........,..............TTT........,.,..#::::::::::::::::#;;;##;;;;;;;#
T.t..._......._...t..._.......T...........s............TTT...b.....,...#:::#::::::::#:::#;;;##;;;;;;;#
T.....,......._......._fffff..T....h.............r.......,..........o..#::::::::::::::::#;;;;;;;;;;;r#
T....._......._......._.y.y...T.....................,...............,..#::::::::::::::::#;;;;;;a;;;;;#
T....._....,.._w......_.......T.............TTT..................s.....#::::::::::::::::#;;;;;;;;;;;;#
T....._,......___..t..,..........,.....r....TTT....~~~~~~~s.....,......#::::::::::::::::#;;;;;;;;;;;;#
T..q.._.......___....._.....q......,........TTT..,,~~~~~~~..........,..:::::::::::::::::G;;;;##;;;;;;#
T_____________________________.....................~~~~~~~...r.....,m..:::::::::B:::::::G;;;;;;;;;;;;#
T....P........_........_...........,............,..~~~~~~~........,..,.:::::::::::::::::G;;;;;;;;;s;;#
T...._..t....._.....,.._.t.....................b,......................:::::::::::::::::G;;;;;;;;;;;;#
T..,._.......q_........_......T.....TTT............,.,......s,.......,.#::::::::::::::::#;;;s;;;;;;;r#
T...._....ffff_ffff...._...n..T.....TTT.......,.......o,...........,...#::::::::::::::::#;;;;;;;;;;;;#
T...._................._......T.....TTT...s.....,.TTTT............a..,.#::::::::::::::::#;;;;;;;##;;;#
T...Mxx..............Rxxx.....T.............,.....TTTT..,..............#::::::::::::::::#;;;;;;;##;;;#
Tn..xxx..............xxxx.....T,............r..,....,.......TTT........#:::#::::::::#:::#;r;;;;;;;;b;#
T...xxx.....d...d....xxxx.....T......,...,.,...........,....TTT........#::::::::::::::::#;;;;;;;;;;;;#
T.............................T....o............s...........TTT......,.#::::::::::::::::#;;;;;;;;;;;;#
T.............D............t..T..........TTT......,.......r............#::::::::::::::::#;;s;;;;b;;;;#
T.t...........................T..........TTT.........,..........b......##################;;;;;;;;;;;;#
T.........fffffffff......,....T.,........TTT............s......,.......##################;;;;;;;;;;A;#
T.............................T.,,.....b,.....o..........,.h......o....##################;;;;;;;;;;;;#
T........,.......t........t...T........,..........................,....###############################
T.............................T.......................,................###############################
TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT###############################
"""

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const ENEMY_SCENES := {
	"s": preload("res://scenes/enemies/slime.tscn"),
	"d": preload("res://scenes/enemies/dummy.tscn"),
	"D": preload("res://scenes/enemies/dummy.tscn"),
	"b": preload("res://scenes/enemies/bat.tscn"),
	"a": preload("res://scenes/enemies/archer.tscn"),
	"B": preload("res://scenes/enemies/boss.tscn"),
}
const ITEM_KINDS := {
	"h": Pickup.Kind.POTION_HP,
	"m": Pickup.Kind.POTION_MP,
	"c": Pickup.Kind.POWER_CRYSTAL,
}
const ITEM_VALUES := { "h": 25, "m": 15, "c": 3 }

const TEX := {
	"grass": preload("res://assets/town/grass.png"),
	"grass_tuft": preload("res://assets/town/grass_tuft.png"),
	"grass_flower": preload("res://assets/town/grass_flower.png"),
	"path": preload("res://assets/town/path_stone.png"),
	"fence_l": preload("res://assets/town/fence_l.png"),
	"fence_m": preload("res://assets/town/fence_m.png"),
	"fence_r": preload("res://assets/town/fence_r.png"),
	"well": preload("res://assets/town/well.png"),
	"sign": preload("res://assets/town/sign.png"),
	"beehive": preload("res://assets/town/beehive.png"),
	"mushroom": preload("res://assets/town/mushroom.png"),
	"house_R": preload("res://assets/town/house_red.png"),
	"house_U": preload("res://assets/town/house_blue.png"),
	"house_W": preload("res://assets/town/house_blue_wood.png"),
	"house_M": preload("res://assets/town/house_small.png"),
	"stone": preload("res://assets/tiles/stone_floor.png"),
	"stone2": preload("res://assets/tiles/stone_floor2.png"),
	"ruin": preload("res://assets/tiles/ruin_floor.png"),
	"ruin2": preload("res://assets/tiles/ruin_floor2.png"),
	"wall_top": preload("res://assets/tiles/wall_top.png"),
	"wall_face": preload("res://assets/tiles/wall_face.png"),
	"gate": preload("res://assets/tiles/gate.png"),
	"altar": preload("res://assets/tiles/altar.png"),
	"bush": preload("res://assets/decor/bush.png"),
	"rock": preload("res://assets/decor/rock.png"),
	"water_tl": preload("res://assets/tiles/water_tl.png"),
	"water_t": preload("res://assets/tiles/water_t.png"),
	"water_tr": preload("res://assets/tiles/water_tr.png"),
	"water_l": preload("res://assets/tiles/water_l.png"),
	"water_c": preload("res://assets/tiles/water_c.png"),
	"water_r": preload("res://assets/tiles/water_r.png"),
	"water_bl": preload("res://assets/tiles/water_bl.png"),
	"water_b": preload("res://assets/tiles/water_b.png"),
	"water_br": preload("res://assets/tiles/water_br.png"),
}
const TREES := [
	preload("res://assets/tiles/tree_pine.png"),
	preload("res://assets/tiles/tree_round.png"),
	preload("res://assets/tiles/tree_pine.png"),
	preload("res://assets/tiles/tree_dark.png"),
]
const VILLAGE_TREES := [
	preload("res://assets/town/tree_green.png"),
	preload("res://assets/town/tree_orange.png"),
	preload("res://assets/town/bush.png"),
]

const SOLID := "T#~orxRUWMfwqyt"
const HOUSE_WIDTH := { "R": 4, "U": 4, "W": 4, "M": 3 }

var rows: PackedStringArray
var map_size := Vector2i.ZERO
var gate_column := -1
var arena_column := -1      # cột đầu tiên của đấu trường (ô ':' đầu tiên)
var altar_position := Vector2.INF
var rng := RandomNumberGenerator.new()

var player: Player
var entities: Node2D
var gate_body: StaticBody2D
var gate_sprites: Array[Sprite2D] = []
var gate_open := false
var signs: Array[Dictionary] = []  # { "pos": Vector2, "text": String, "near": bool }
var entered_forest := false
var entered_area2 := false
var entered_arena := false
var won := false


func _ready() -> void:
	rng.seed = 2026  # cùng một "hạt giống" => hoa / cây luôn mọc ở cùng chỗ
	_parse_map()
	entities = Node2D.new()
	entities.name = "Entities"
	entities.y_sort_enabled = true
	_build_ground()
	_build_walls()
	add_child(entities)  # thêm sau cùng để vẽ đè lên mặt đất
	_spawn_everything()
	Game.boss_defeated.connect(_on_boss_defeated)
	call_deferred("_announce_start")


func _announce_start() -> void:
	Game.area_entered.emit("Làng Khởi Nguyên")
	Game.message.emit("Hãy luyện tập ở bãi tập, rồi lên đường về phía đông!")


func _parse_map() -> void:
	rows = MAP.strip_edges().split("\n")
	for i in rows.size():
		rows[i] = rows[i].strip_edges()
	var width := 0
	for r in rows:
		width = maxi(width, r.length())
	map_size = Vector2i(width, rows.size())
	for y in rows.size():
		var gx := rows[y].find("G")
		if gx != -1:
			gate_column = gx
			break
	for y in rows.size():
		var ax := rows[y].find(":")
		if ax != -1:
			arena_column = ax if arena_column == -1 else mini(arena_column, ax)


func cell(x: int, y: int) -> String:
	if y < 0 or y >= rows.size() or x < 0 or x >= rows[y].length():
		return "#"
	return rows[y][x]


func _floor_texture(x: int, y: int) -> Texture2D:
	var c := cell(x, y)
	if c == "~":
		return _water_texture(x, y)
	if c == "#":
		# Ô tường có ô trống ở dưới thì vẽ mặt tường, còn lại vẽ nóc tường
		return TEX["wall_face"] if cell(x, y + 1) != "#" else TEX["wall_top"]
	if c == "_":
		return TEX["path"]
	if c == ",":
		return TEX["grass_flower"]
	if arena_column == -1 or x < arena_column:
		var roll := rng.randf()
		if roll < 0.025:
			return TEX["grass_flower"]
		return TEX["grass_tuft"] if roll < 0.14 else TEX["grass"]
	if gate_column == -1 or x <= gate_column:
		return TEX["stone2"] if rng.randf() < 0.08 else TEX["stone"]
	return TEX["ruin2"] if rng.randf() < 0.12 else TEX["ruin"]


## Chọn ô nước có bờ phù hợp dựa vào 4 ô xung quanh.
func _water_texture(x: int, y: int) -> Texture2D:
	var row := ""
	if cell(x, y - 1) != "~":
		row = "t"
	elif cell(x, y + 1) != "~":
		row = "b"
	var col := ""
	if cell(x - 1, y) != "~":
		col = "l"
	elif cell(x + 1, y) != "~":
		col = "r"
	var key := row + col
	if key == "":
		key = "c"
	return TEX["water_" + key]


func _build_ground() -> void:
	var ground := Node2D.new()
	ground.name = "Ground"
	ground.z_index = -10
	add_child(ground)
	for y in map_size.y:
		for x in map_size.x:
			var c := cell(x, y)
			_add_tile_sprite(ground, _floor_texture(x, y), x, y)
			if c == "n":
				_add_tile_sprite(ground, TEX["mushroom"], x, y)
			elif c == "f":
				_add_tile_sprite(ground, _fence_texture(x, y), x, y)


func _add_tile_sprite(parent: Node, tex: Texture2D, x: int, y: int) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.position = Vector2(x * TILE, y * TILE)
	parent.add_child(s)
	return s


func _fence_texture(x: int, y: int) -> Texture2D:
	var left := cell(x - 1, y) == "f"
	var right := cell(x + 1, y) == "f"
	if left and not right:
		return TEX["fence_r"]
	if right and not left:
		return TEX["fence_l"]
	return TEX["fence_m"]


## Vật trang trí đứng (cây, bụi, đá, nhà...) được sắp xếp theo chiều dọc
## để nhân vật có thể đi "sau" tán cây / mái nhà.
## (x, y) là ô trên cùng bên trái; width_tiles / height_tiles là kích thước chân đế.
func _add_prop(tex: Texture2D, x: int, y: int, width_tiles: int = 1, height_tiles: int = 1) -> void:
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.position = Vector2((x + width_tiles / 2.0) * TILE, (y + height_tiles) * TILE)  # gốc ở đáy
	s.offset = Vector2(-tex.get_width() / 2.0, -tex.get_height())
	entities.add_child(s)


func _build_walls() -> void:
	# Gộp các ô chặn liền nhau theo hàng ngang thành một khối va chạm
	var walls := StaticBody2D.new()
	walls.name = "Walls"
	walls.collision_layer = 1
	walls.collision_mask = 0
	add_child(walls)
	for y in map_size.y:
		var x := 0
		while x < map_size.x:
			if SOLID.contains(cell(x, y)):
				var start := x
				while x < map_size.x and SOLID.contains(cell(x, y)):
					x += 1
				_add_rect_shape(walls, start, y, x - start)
			else:
				x += 1

	# Cổng phong ấn: thân va chạm riêng để có thể mở ra
	gate_body = StaticBody2D.new()
	gate_body.name = "Gate"
	gate_body.collision_layer = 1
	gate_body.collision_mask = 0
	add_child(gate_body)
	for y in map_size.y:
		for x in map_size.x:
			if cell(x, y) == "G":
				_add_rect_shape(gate_body, x, y, 1)
				gate_sprites.append(_add_tile_sprite(gate_body, TEX["gate"], x, y))


func _add_rect_shape(body: StaticBody2D, x: int, y: int, width_tiles: int) -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width_tiles * TILE, TILE)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2((x + width_tiles / 2.0) * TILE, (y + 0.5) * TILE)
	body.add_child(col)


func _spawn_everything() -> void:
	for y in map_size.y:
		for x in map_size.x:
			var c := cell(x, y)
			var pos := Vector2(x + 0.5, y + 0.5) * TILE
			match c:
				"T":
					_add_prop(TREES[rng.randi() % TREES.size()], x, y)
				"o":
					_add_prop(TEX["bush"], x, y)
				"r":
					_add_prop(TEX["rock"], x, y)
				"t":
					_add_prop(VILLAGE_TREES[rng.randi() % VILLAGE_TREES.size()], x, y)
				"w":
					_add_prop(TEX["well"], x, y)
				"y":
					_add_prop(TEX["beehive"], x, y)
				"q":
					_add_prop(TEX["sign"], x, y)
					var text: String = SIGN_TEXTS[signs.size()] if signs.size() < SIGN_TEXTS.size() else "..."
					signs.append({"pos": pos, "text": text, "near": false})
				"R", "U", "W", "M":
					_add_prop(TEX["house_" + c], x, y, HOUSE_WIDTH[c], 3)
				"A":
					_add_prop(TEX["altar"], x, y)
					altar_position = pos
				"P":
					player = PLAYER_SCENE.instantiate() as Player
					player.position = pos
					entities.add_child(player)
			if ENEMY_SCENES.has(c):
				var enemy := (ENEMY_SCENES[c] as PackedScene).instantiate() as Enemy
				enemy.position = pos
				if gate_column != -1 and x > gate_column and c != "B":
					enemy.make_elite()
				if c == "D":
					enemy.armor = 6
					enemy.display_name = "Bù nhìn giáp"
				entities.add_child(enemy)
			elif ITEM_KINDS.has(c):
				var item := (load("res://scenes/pickup.tscn") as PackedScene).instantiate() as Pickup
				item.kind = ITEM_KINDS[c]
				item.value = ITEM_VALUES[c]
				item.position = pos
				entities.add_child(item)

	if player:
		player.set_camera_limits(Rect2(Vector2.ZERO, Vector2(map_size) * TILE))


func _process(_delta: float) -> void:
	if player == null or player.is_dead:
		return
	var tile_x := player.global_position.x / TILE
	# Biển báo: đi tới gần thì hiện chữ
	for sign_data in signs:
		var near: bool = player.global_position.distance_to(sign_data["pos"]) < 22.0
		if near and not sign_data["near"]:
			Game.message.emit(sign_data["text"])
		sign_data["near"] = near
	if not entered_forest and tile_x > VILLAGE_END_COLUMN + 1 and tile_x < arena_column:
		entered_forest = true
		Game.area_entered.emit("Rừng Hoang")
		Game.message.emit("Hãy mạnh lên và đánh bại kẻ canh giữ ở phía đông!")
	if not entered_arena and arena_column != -1 and tile_x > arena_column + 1 and tile_x < gate_column:
		entered_arena = true
		Game.area_entered.emit("Đấu Trường Đá Cổ")
	if not entered_area2 and gate_column != -1 and tile_x > gate_column + 1:
		entered_area2 = true
		Game.area_entered.emit("Tàn Tích Cổ Đại")
		Game.message.emit("Quái vật nơi đây mạnh hơn. Hãy tìm Bệ Thờ Cổ!")
	if not won and altar_position != Vector2.INF and player.global_position.distance_to(altar_position) < 14.0:
		won = true
		Game.game_won.emit()


func _on_boss_defeated() -> void:
	if gate_open:
		return
	gate_open = true
	Game.message.emit("Cổng phong ấn đã mở! Khu vực mới: Tàn Tích Cổ Đại")
	Game.shake(4.0)
	for col in gate_body.get_children():
		if col is CollisionShape2D:
			col.set_deferred("disabled", true)
	for s in gate_sprites:
		var tw := s.create_tween()
		tw.tween_property(s, "modulate:a", 0.0, 1.0)
