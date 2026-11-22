class_name Chest
extends Node2D
## Rương báu trong Hầm Ngục Cổ (ký tự ' trong bản đồ tầng ở scripts/dungeon.gd).
## Rương bị KHOÁ tới khi hạ hết quái của tầng đó (tầng 5 phải hạ cả Boss Malakar).
## Mở khoá rồi thì đi tới sát rương là rương tự mở, đồ văng ra đất, đi qua là nhặt.
## Hạ Malakar còn rơi thêm một Rương kim cương ngay chỗ hắn ngã xuống.
##
## 4 loại rương: thường, bạc, vàng, kim cương. Tầng càng sâu càng hay gặp rương xịn
## (tỉ lệ "chest_odds" của từng tầng nằm trong scripts/dungeon.gd).
## Đồ trong mỗi loại rương (TIERS bên dưới):
##   Trang bị: mỗi rương chỉ ra 1 hoặc 2 món.
##     gear_two: phần trăm cơ hội ra thêm món thứ 2 (0 = luôn 1 món, 100 = luôn 2 món)
##     gear_tier: bậc trang bị = số tầng + [cộng ít nhất, cộng nhiều nhất] (bậc 1 đến 5, xem scripts/equipment.gd)
##     rarity: tỉ lệ PHẦN TRĂM ra từng độ hiếm cho mỗi món (Thường, Bạc, Vàng, Kim cương).
##             Số lẻ cũng được: 0.001 = cứ 100.000 món mới ra 1 món. Cộng lại nên bằng 100.
##     guaranteed: món đầu tiên chắc chắn có độ hiếm này (Rương kim cương luôn ra 1 món Kim cương)
##   Đồ lặt vặt thì rương nào cũng luôn có, rương càng xịn càng nhiều:
##     materials: số loại nguyên liệu chế tạo, amount: mỗi loại bao nhiêu cái [ít nhất, nhiều nhất]
##     gold: vàng (nhân với số tầng)
##     potions: bình máu, big_potions: bình máu lớn, crystals: pha lê sức mạnh (+2 tấn công mỗi viên)

const TIERS := {
	"normal": {
		"name": "Rương thường", "texture": preload("res://assets/dungeon/chest_normal.png"),
		"color": Color(1.0, 0.7, 0.4),
		"gear_two": 15, "gear_tier": [-1, 0],
		"rarity": { "common": 89.999, "silver": 9.0, "gold": 1.0, "diamond": 0.001 },
		"materials": 2, "amount": [1, 3], "gold": 12, "potions": 0, "big_potions": 0, "crystals": 0,
	},
	"silver": {
		"name": "Rương bạc", "texture": preload("res://assets/dungeon/chest_silver.png"),
		"color": Color(0.82, 0.88, 1.0),
		"gear_two": 30, "gear_tier": [0, 0],
		"rarity": { "common": 55.0, "silver": 38.0, "gold": 6.9, "diamond": 0.1 },
		"materials": 3, "amount": [2, 3], "gold": 25, "potions": 1, "big_potions": 0, "crystals": 0,
	},
	"gold": {
		"name": "Rương vàng", "texture": preload("res://assets/dungeon/chest_gold.png"),
		"color": Color(1.0, 0.85, 0.3),
		"gear_two": 45, "gear_tier": [0, 1],
		"rarity": { "common": 20.0, "silver": 45.0, "gold": 33.0, "diamond": 2.0 },
		"materials": 3, "amount": [2, 4], "gold": 50, "potions": 1, "big_potions": 1, "crystals": 0,
	},
	"diamond": {
		"name": "Rương kim cương", "texture": preload("res://assets/dungeon/chest_diamond.png"),
		"color": Color(0.5, 0.95, 1.0),
		"gear_two": 60, "gear_tier": [1, 1], "guaranteed": "diamond",
		"rarity": { "silver": 20.0, "gold": 50.0, "diamond": 30.0 },
		"materials": 4, "amount": [3, 5], "gold": 100, "potions": 0, "big_potions": 2, "crystals": 1,
	},
}

## Nguyên liệu chế tạo có thể nằm trong rương. Số càng lớn càng hay gặp.
const MATERIALS := {
	"hide": 4, "bone": 4, "rope": 3, "wood": 3, "herb": 3, "water": 2, "wheat": 2,
	"mushroom": 2, "berry": 1, "apple": 1, "carrot": 1, "pumpkin": 1, "meat": 1,
}

const LOCK_TEX := preload("res://assets/dungeon/chest_lock.png")
const OPEN_RANGE := 18.0

var tier := "normal"
var floor_index := 1
var locked := true
var opened := false
var level: Level
var light_texture: Texture2D

var sprite: Sprite2D
var lock_sprite: Sprite2D
var light: PointLight2D
var player: Player
var msg_cd := 0.0
var sparkle_cd := 0.0


func setup(chest_tier: String, fl: int, start_locked: bool, lvl: Level) -> void:
	tier = chest_tier if TIERS.has(chest_tier) else "normal"
	floor_index = fl
	locked = start_locked
	level = lvl
	if lvl != null:
		light_texture = lvl.light_texture


func _ready() -> void:
	add_to_group("chests")
	var data: Dictionary = TIERS[tier]
	sprite = Sprite2D.new()
	sprite.texture = data["texture"]
	sprite.hframes = 2
	sprite.offset = Vector2(0, -6)
	add_child(sprite)
	lock_sprite = Sprite2D.new()
	lock_sprite.texture = LOCK_TEX
	lock_sprite.position = Vector2(0, -5)
	lock_sprite.visible = locked
	add_child(lock_sprite)
	if light_texture != null:
		light = PointLight2D.new()
		light.texture = light_texture
		light.texture_scale = 34.0 * 2.0 / light_texture.get_width()
		light.position = Vector2(0, -6)
		add_child(light)
	_update_look()


## Rương phát sáng nhẹ để thấy được trong bóng tối: khoá = ánh sáng mờ, mở khoá = sáng theo màu rương.
func _update_look() -> void:
	var color: Color = TIERS[tier]["color"]
	sprite.modulate = Color(0.72, 0.72, 0.78) if locked else Color.WHITE
	if light:
		light.color = Color(0.8, 0.8, 0.9) if locked else color
		light.energy = 0.35 if locked else (0.3 if opened else 0.9)


func _draw() -> void:
	# bóng dưới rương
	draw_set_transform(Vector2(0, 1), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 7.0, Color(0, 0, 0, 0.35))


## Hạ hết quái trên tầng: rương mở khoá (level.gd gọi).
func unlock() -> void:
	if not locked:
		return
	locked = false
	var color: Color = TIERS[tier]["color"]
	var tw := create_tween()
	tw.tween_property(lock_sprite, "scale", Vector2(1.8, 1.8), 0.35)
	tw.parallel().tween_property(lock_sprite, "modulate:a", 0.0, 0.35)
	tw.tween_callback(lock_sprite.hide)
	Game.burst(global_position + Vector2(0, -6), color, 12, 55.0, 30.0, 0.5, 1.8)
	_update_look()


func _process(delta: float) -> void:
	if opened:
		set_process(false)
		return
	msg_cd -= delta
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead:
		return
	var dist := player.global_position.distance_to(global_position + Vector2(0, -4))
	# Rương xịn đã mở khoá thì lấp lánh khi người chơi ở gần
	if not locked and tier != "normal" and dist < 200.0:
		sparkle_cd -= delta
		if sparkle_cd <= 0.0:
			sparkle_cd = 0.9
			Game.burst(global_position + Vector2(randf_range(-5, 5), -9), TIERS[tier]["color"], 2, 15.0, -10.0, 0.6, 1.2)
	if dist > OPEN_RANGE:
		return
	if locked:
		if msg_cd <= 0.0:
			msg_cd = 4.0
			var left: int = level.floor_enemies_left(floor_index) if level != null else 0
			Game.popup_text(global_position + Vector2(0, -22), "Khoá! Còn %d quái" % left, Color(1.0, 0.75, 0.5), 9)
			Game.message.emit("%s bị khoá: hạ hết quái trên tầng này để mở (còn %d con)." % [TIERS[tier]["name"], left])
		return
	open()


func open() -> void:
	if opened:
		return
	opened = true
	var data: Dictionary = TIERS[tier]
	var color: Color = data["color"]
	sprite.frame = 1
	Game.shake(2.0)
	Game.burst(global_position + Vector2(0, -8), color, 18, 75.0, 60.0, 0.55, 2.0)
	Game.popup_text(global_position + Vector2(0, -24), data["name"] + "!", color, 11)
	_update_look()
	_drop_loot()


## Đồ trong rương văng ra đất (trang bị, nguyên liệu, vàng, bình máu).
func _drop_loot() -> void:
	var data: Dictionary = TIERS[tier]
	var parent := get_parent()
	var at := position + Vector2(0, 2)
	# Trang bị: 1 hoặc 2 món. Bậc theo tầng (tầng càng sâu bậc càng cao), độ hiếm theo may rủi của loại rương
	var names := PackedStringArray()
	var tier_range: Array = data["gear_tier"]
	var count := 2 if randf() * 100.0 < float(data.get("gear_two", 0)) else 1
	var best := ""
	for i in count:
		var gear_tier := clampi(floor_index + randi_range(int(tier_range[0]), int(tier_range[1])), 1, Equipment.MAX_TIER)
		var id := Equipment.random_piece(gear_tier)
		if id == "":
			continue
		var rarity := Equipment.roll_rarity(data["rarity"])
		if i == 0 and str(data.get("guaranteed", "")) != "":
			rarity = str(data["guaranteed"])
		Pickup.spawn_item(parent, id, at, 1, rarity)
		names.append(Equipment.full_name(id, rarity))
		if best == "" or Equipment.rarity_rank(rarity) > Equipment.rarity_rank(best):
			best = rarity
	_announce_rare(best)
	# Nguyên liệu chế tạo
	var amount: Array = data["amount"]
	for id in _pick_materials(int(data["materials"])):
		Pickup.spawn_item(parent, id, at, randi_range(int(amount[0]), int(amount[1])))
	# Vàng: chia thành vài đồng xu
	var gold := int(data["gold"]) * floor_index
	var coins := clampi(int(gold / 15.0), 2, 8)
	for i in coins:
		Pickup.spawn(parent, Pickup.Kind.GOLD, at, maxi(1, int(gold / float(coins))))
	for i in int(data["potions"]):
		Pickup.spawn_item(parent, "potion_hp", at)
	for i in int(data["big_potions"]):
		Pickup.spawn_item(parent, "potion_hp_big", at)
	for i in int(data["crystals"]):
		Pickup.spawn(parent, Pickup.Kind.POWER_CRYSTAL, at, 2)
	if names.is_empty():
		Game.message.emit("Mở %s: vàng và nguyên liệu chế tạo." % data["name"])
	else:
		Game.message.emit("Mở %s: %s!" % [data["name"], ", ".join(names)])


## Ra được đồ hiếm: hiện chữ to theo màu độ hiếm. Rương thường mà ra đồ Kim cương thì báo "CỰC HIẾM".
func _announce_rare(rarity: String) -> void:
	var rank := Equipment.rarity_rank(rarity)
	if rank < 2:   # Thường, Bạc: không cần báo
		return
	var info := Equipment.rarity_info(rarity)
	var color: Color = info["color"]
	var lucky := rank > Equipment.rarity_rank(_usual_best())   # ra đồ hiếm hơn hẳn loại rương này hay ra
	var text: String = ("CỰC HIẾM! Trang bị %s!" if lucky else "Trang bị %s!") % info["name"]
	Game.popup_text(global_position + Vector2(0, -36), text, color, 12 if lucky else 10)
	Game.burst(global_position + Vector2(0, -8), color, 26 if lucky else 14, 90.0, 70.0, 0.7, 2.2)
	if lucky:
		Game.shake(4.0)
		Game.message.emit("Quá may mắn! %s mà ra được đồ %s!" % [TIERS[tier]["name"], info["name"]])


## Độ hiếm cao nhất mà loại rương này hay ra (độ hiếm có tỉ lệ từ 1% trở lên).
func _usual_best() -> String:
	var weights: Dictionary = TIERS[tier]["rarity"]
	var best := Equipment.DEFAULT_RARITY
	for key in weights:
		if float(weights[key]) >= 1.0 and Equipment.rarity_rank(key) > Equipment.rarity_rank(best):
			best = key
	var sure := str(TIERS[tier].get("guaranteed", ""))
	if sure != "" and Equipment.rarity_rank(sure) > Equipment.rarity_rank(best):
		best = sure
	return best


## Chọn n loại nguyên liệu khác nhau theo độ hay gặp.
func _pick_materials(n: int) -> Array[String]:
	var pool := MATERIALS.duplicate()
	var out: Array[String] = []
	for i in n:
		if pool.is_empty():
			break
		var total := 0
		for id in pool:
			total += int(pool[id])
		var roll := randi() % total
		for id in pool:
			roll -= int(pool[id])
			if roll < 0:
				out.append(id)
				pool.erase(id)
				break
	return out


## Chọn loại rương theo tỉ lệ, ví dụ { "normal": 60, "silver": 30, "gold": 10 }.
static func roll_tier(odds: Dictionary) -> String:
	var total := 0
	for key in odds:
		if TIERS.has(key):
			total += int(odds[key])
	if total <= 0:
		return "normal"
	var roll := randi() % total
	for key in odds:
		if not TIERS.has(key):
			continue
		roll -= int(odds[key])
		if roll < 0:
			return key
	return "normal"


## Tạo một rương (đã mở khoá) tại vị trí pos, ví dụ rương rơi ra khi hạ Boss.
static func spawn_reward(parent: Node, pos: Vector2, chest_tier: String, fl: int, lvl: Level) -> Chest:
	var chest := Chest.new()
	chest.setup(chest_tier, fl, false, lvl)
	chest.position = pos
	parent.add_child.call_deferred(chest)
	if lvl != null:
		lvl.chests.append(chest)
	return chest
