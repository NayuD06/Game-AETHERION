class_name Recipes
extends RefCounted
## Công thức chế tạo. Mỗi trạm chế tạo có công thức riêng. Đi tới gần trạm là bảng chế tạo tự mở ra,
## bấm "Chế" để làm. Các trạm đặt quanh quảng trường Làng Khởi Nguyên (chỗ bắt đầu game):
##   "pot"   Nồi luyện thuốc ('C')       : thuốc hồi máu, thuốc tăng sức mạnh / tốc độ
##   "fire"  Bếp lửa ('8', lửa trại 'j') : nướng thịt, nướng xiên (Bộ lửa trại tự đặt cũng dùng được)
##   "stove" Lò nấu ăn ('0')             : nấu súp, nướng bánh
##   "bench" Bàn chế tạo ('@')           : công cụ, trang bị, nâng cấp túi
##
## Muốn thêm công thức mới: thêm một mục vào LIST.
##   station: trạm nào làm được (pot, fire, stove, bench)
##   needs:   nguyên liệu cần { tên vật phẩm: số lượng } (tên lấy trong scripts/items.gd)
##   gives:   vật phẩm làm ra (tên trong scripts/items.gd), count: làm ra bao nhiêu cái
##   unique:  true = chỉ cần có 1 cái (công cụ), có rồi thì không làm thêm
## Đồ nâng cấp nhân vật (không vào túi) dùng "upgrade" thay cho "gives":
##   upgrade: "bag" (túi thêm ô), "armor" (thêm máu tối đa), "charm" (thêm tấn công)
##   max: làm được tối đa mấy lần. name / icon / desc: chữ và hình hiện trong bảng chế tạo.

const STATIONS := {
	"pot": { "name": "Nồi luyện thuốc", "hint": "Thuốc hồi máu, thuốc tăng sức" },
	"fire": { "name": "Bếp lửa", "hint": "Nướng thịt, nướng xiên" },
	"stove": { "name": "Lò nấu ăn", "hint": "Nấu súp, nướng bánh" },
	"bench": { "name": "Bàn chế tạo", "hint": "Công cụ, trang bị, nâng cấp túi" },
}

const LIST := [
	# ---- Nồi luyện thuốc
	{ "station": "pot", "gives": "potion_hp", "count": 1, "needs": { "herb": 2, "water": 1 } },
	{ "station": "pot", "gives": "potion_hp_big", "count": 1, "needs": { "herb": 3, "apple": 1, "water": 1 } },
	{ "station": "pot", "gives": "potion_strength", "count": 1, "needs": { "herb": 1, "bone": 2, "water": 1 } },
	{ "station": "pot", "gives": "potion_speed", "count": 1, "needs": { "berry": 2, "herb": 1, "water": 1 } },
	# ---- Bếp lửa (nướng)
	{ "station": "fire", "gives": "cooked_meat", "count": 1, "needs": { "meat": 1 } },
	{ "station": "fire", "gives": "mushroom_skewer", "count": 1, "needs": { "mushroom": 3 } },
	{ "station": "fire", "gives": "roast_pumpkin", "count": 1, "needs": { "pumpkin": 1 } },
	{ "station": "fire", "gives": "meat_skewer", "count": 1, "needs": { "meat": 1, "carrot": 1, "mushroom": 1 } },
	# ---- Lò nấu ăn (nấu, nướng bánh)
	{ "station": "stove", "gives": "bread", "count": 1, "needs": { "wheat": 2, "water": 1 } },
	{ "station": "stove", "gives": "apple_pie", "count": 1, "needs": { "apple": 2, "wheat": 2 } },
	{ "station": "stove", "gives": "mushroom_soup", "count": 1, "needs": { "mushroom": 2, "berry": 2 } },
	{ "station": "stove", "gives": "pumpkin_soup", "count": 1, "needs": { "pumpkin": 1, "carrot": 1, "water": 1 } },
	{ "station": "stove", "gives": "bone_broth", "count": 1, "needs": { "bone": 2, "carrot": 1, "water": 1 } },
	# ---- Bàn chế tạo (công cụ, trang bị)
	{ "station": "bench", "gives": "rope", "count": 1, "needs": { "wheat": 3 } },
	{ "station": "bench", "gives": "axe", "count": 1, "unique": true, "needs": { "bone": 2, "rope": 1 } },
	{ "station": "bench", "gives": "sickle", "count": 1, "unique": true, "needs": { "bone": 1, "wood": 1, "rope": 1 } },
	{ "station": "bench", "gives": "torch", "count": 1, "unique": true, "needs": { "wood": 1, "rope": 1 } },
	{ "station": "bench", "gives": "campfire_kit", "count": 1, "needs": { "wood": 3, "rope": 1 } },
	{
		"station": "bench", "upgrade": "bag", "amount": 4, "max": 2,
		"name": "Ba lô lớn hơn", "icon": preload("res://assets/items/backpack.png"),
		"desc": "Túi đồ thêm 4 ô (làm được 2 lần, tối đa 20 ô).",
		"needs": { "hide": 3, "rope": 2 },
	},
	{
		"station": "bench", "upgrade": "armor", "amount": 25, "max": 1,
		"name": "Áo giáp da", "icon": preload("res://assets/items/leather_armor.png"),
		"desc": "Mặc vào: máu tối đa +25.",
		"needs": { "hide": 4, "rope": 1 },
	},
	{
		"station": "bench", "upgrade": "charm", "amount": 4, "max": 1,
		"name": "Bùa răng sói", "icon": preload("res://assets/items/bone_charm.png"),
		"desc": "Đeo vào: tấn công +4.",
		"needs": { "bone": 4, "hide": 1, "rope": 1 },
	},
]


## Các công thức của một trạm chế tạo.
static func for_station(station: String) -> Array:
	var out := []
	for r in LIST:
		if r["station"] == station:
			out.append(r)
	return out


static func result_name(recipe: Dictionary) -> String:
	if recipe.has("upgrade"):
		return recipe["name"]
	var count: int = recipe.get("count", 1)
	var item_name: String = Items.info(recipe["gives"]).get("name", recipe["gives"])
	return item_name if count <= 1 else "%s x%d" % [item_name, count]


static func result_icon(recipe: Dictionary) -> Texture2D:
	if recipe.has("upgrade"):
		return recipe["icon"]
	return Items.info(recipe["gives"]).get("icon")


static func result_desc(recipe: Dictionary) -> String:
	if recipe.has("upgrade"):
		return recipe["desc"]
	return Items.info(recipe["gives"]).get("desc", "")


## Đã làm hết số lần cho phép (đồ nâng cấp), hoặc đã có công cụ này rồi?
static func is_maxed(player: Player, recipe: Dictionary) -> bool:
	if recipe.get("unique", false):
		return player.count_item(recipe["gives"]) > 0
	if not recipe.has("upgrade"):
		return false
	return int(player.upgrades.get(recipe["upgrade"], 0)) >= int(recipe.get("max", 1))


static func has_needs(player: Player, recipe: Dictionary) -> bool:
	var needs: Dictionary = recipe["needs"]
	for id in needs:
		if player.count_item(id) < int(needs[id]):
			return false
	return true


static func can_craft(player: Player, recipe: Dictionary) -> bool:
	return not is_maxed(player, recipe) and has_needs(player, recipe)


## Chế tạo: trừ nguyên liệu, thêm thành phẩm. Trả về chữ báo kết quả ("" = thành công).
static func craft(player: Player, recipe: Dictionary) -> String:
	if is_maxed(player, recipe):
		return "Đã có rồi" if recipe.get("unique", false) else "Đã làm tối đa rồi"
	if not has_needs(player, recipe):
		return "Thiếu nguyên liệu"
	var needs: Dictionary = recipe["needs"]
	for id in needs:
		player.remove_item(id, int(needs[id]))
	if recipe.has("upgrade"):
		player.apply_upgrade(recipe["upgrade"], int(recipe.get("amount", 1)))
		return ""
	if not player.add_item(recipe["gives"], int(recipe.get("count", 1))):
		# Túi đầy: trả lại nguyên liệu
		for id in needs:
			player.add_item(id, int(needs[id]))
		return "Túi đầy!"
	return ""
