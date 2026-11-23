class_name Shops
extends RefCounted
## Cửa hàng của dân làng. Đi tới gần người bán (có đồng xu vàng trên đầu) là bảng cửa hàng tự mở:
##   Mua:    mua đồ người đó bán (trừ vàng).
##   Bán:    bán đồ trong túi lấy vàng (cửa hàng nào cũng mua mọi thứ, giá bằng SELL_RATIO giá gốc).
##   Sửa đồ: chỉ Thợ rèn có. Sửa lại độ bền trang bị (xem scripts/equipment.gd).
## Người bán nào mở cửa hàng nào: thêm "shop": "<tên cửa hàng>" vào người đó trong NPC_DATA (scripts/level.gd,
## dân các làng mới nằm trong NPC_DATA của scripts/world_map.gd).
##
## Muốn thêm cửa hàng mới: thêm một mục vào SHOPS.
##   name: tên cửa hàng     sells: danh sách đồ bán (tên trong scripts/items.gd hoặc scripts/equipment.gd)
##   repair: true = có sửa trang bị
## Muốn đổi giá: sửa PRICES (giá mua). Trang bị tính giá theo bậc (TIER_PRICE trong scripts/equipment.gd).

const SHOPS := {
	"fruit": {
		"name": "Sạp trái cây - Bà Lan",
		"sells": ["apple", "berry", "carrot", "pumpkin", "mushroom", "herb", "wheat", "water"],
	},
	"bakery": {
		"name": "Tiệm bánh - Chú Tư",
		"sells": ["bread", "apple_pie", "cooked_meat", "meat_skewer", "roast_pumpkin", "mushroom_soup", "pumpkin_soup", "bone_broth"],
	},
	"smith": {
		"name": "Lò rèn - Bác Sắt",
		"sells": ["helmet_1", "armor_1", "pants_1", "boots_1", "helmet_2", "armor_2", "pants_2", "boots_2",
			"axe", "sickle", "torch", "rope", "campfire_kit"],
		"repair": true,
	},
	"potion": {
		"name": "Tiệm thuốc - Bà thầy thuốc",
		"sells": ["potion_hp", "potion_hp_big", "potion_strength", "potion_speed", "herb", "water"],
	},
	# ---- Các làng mới
	"fish": {
		"name": "Sạp cá - Cô Sáu (Làng Chài)",
		"sells": ["fish", "shrimp", "big_fish", "grilled_fish", "grilled_tuna", "fish_soup", "fishing_rod", "water"],
	},
	"boat": {
		"name": "Xưởng thuyền - Bác Thuyền (Làng Chài)",
		"sells": ["boat", "fishing_rod", "rope", "wood"],
	},
	"smith2": {
		"name": "Lò rèn - Bà Tuyết (Làng Tuyết)",
		"sells": ["helmet_2", "armor_2", "pants_2", "boots_2", "helmet_3", "armor_3", "pants_3", "boots_3", "torch", "rope"],
		"repair": true,
	},
	"tea": {
		"name": "Quán trà - Cô Đào (Làng Hoa Đào)",
		"sells": ["cherry_tea", "apple_pie", "bread", "mushroom_soup", "potion_speed"],
	},
	"herbal": {
		"name": "Nhà thuốc - Thầy lang Trúc (Làng Tre)",
		"sells": ["potion_hp", "potion_hp_big", "potion_strength", "herb", "mushroom_soup", "bone_broth", "fish_soup"],
	},
	"oasis": {
		"name": "Quầy hàng - Ông Sa (Ốc Đảo)",
		"sells": ["water", "date", "potion_hp", "potion_hp_big", "bread", "grilled_fish"],
	},
}

## Giá mua (vàng). Đồ không có trong danh sách: giá DEFAULT_PRICE.
const PRICES := {
	"potion_hp": 25, "potion_hp_big": 60, "potion_strength": 45, "potion_speed": 40, "potion_mp": 20,
	"berry": 3, "herb": 6, "mushroom": 4, "apple": 5, "carrot": 4, "pumpkin": 10, "wheat": 3,
	"water": 2, "hide": 8, "bone": 6, "rope": 6, "wood": 5, "meat": 6,
	"axe": 40, "sickle": 35, "torch": 30, "campfire_kit": 30,
	"cooked_meat": 14, "mushroom_skewer": 12, "roast_pumpkin": 20, "meat_skewer": 26,
	"pumpkin_soup": 30, "apple_pie": 22, "bread": 10, "mushroom_soup": 22, "bone_broth": 28,
	"fish": 6, "shrimp": 5, "big_fish": 14, "pearl": 60, "crab_meat": 8, "date": 4, "scorpion_tail": 10,
	"fishing_rod": 30, "boat": 150, "grilled_fish": 14, "grilled_tuna": 30, "grilled_crab": 22,
	"fish_soup": 34, "cherry_tea": 28,
}
const DEFAULT_PRICE := 4
## Bán lại được bao nhiêu phần giá mua (0.4 = 40%). Trang bị đã mòn thì còn rẻ hơn nữa.
const SELL_RATIO := 0.4


static func info(shop: String) -> Dictionary:
	return SHOPS.get(shop, {})


## Giá mua một món (trang bị mới thì độ bền đầy).
static func buy_price(id: String) -> int:
	if Equipment.is_gear(id):
		return Equipment.price(id)
	return int(PRICES.get(id, DEFAULT_PRICE))


## Giá bán một cái ở ô túi entry (trang bị tính theo độ hiếm và độ bền còn lại).
static func sell_price(entry: Dictionary) -> int:
	var id: String = entry["id"]
	if Equipment.is_gear(id):
		var rarity: String = entry.get("rarity", Equipment.DEFAULT_RARITY)
		var dur_ratio := float(entry.get("dur", 0)) / float(maxi(Equipment.max_durability(id, rarity), 1))
		return maxi(1, roundi(float(Equipment.price(id, rarity)) * SELL_RATIO * (0.3 + 0.7 * dur_ratio)))
	return maxi(1, roundi(float(buy_price(id)) * SELL_RATIO))


## Mua một món. Trả về chữ báo lỗi, "" = mua được.
static func buy(player: Player, id: String) -> String:
	var price := buy_price(id)
	if Items.info(id).get("tool", false) and player.count_item(id) > 0:
		return "Đã có rồi"
	if player.gold < price:
		return "Không đủ vàng (cần %d)" % price
	if not player.add_item(id):
		return "Túi đầy!"
	player.gold -= price
	return ""


## Bán một cái ở ô thứ index trong túi. Trả về số vàng nhận được (0 = không bán được).
static func sell(player: Player, index: int) -> int:
	if index < 0 or index >= player.bag.size():
		return 0
	var price := sell_price(player.bag[index])
	player.remove_bag_slot(index, 1)
	player.gold += price
	return price
