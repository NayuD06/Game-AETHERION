class_name Equipment
extends RefCounted
## Trang bị: Mũ, Giáp, Quần, Giày. Bấm B mở túi đồ, bảng "Trang bị" nằm bên trái túi.
## Bấm vào món trang bị trong túi để mặc (món cũ quay về túi), bấm vào ô đang mặc để tháo ra.
## Nhặt được món mới mà chỗ đó còn trống thì tự mặc luôn.
## Trang bị rơi ra từ rương báu trong Hầm Ngục Cổ (scripts/chest.gd): tầng càng sâu, đồ càng xịn.
## Áo giáp da còn làm được ở bàn chế tạo (scripts/recipes.gd).
##
## Chỉ số trang bị ("stats"):
##   defense: phòng thủ, giảm sát thương nhận vào (phòng thủ 50 = chỉ còn nhận một nửa sát thương)
##   hp: máu tối đa      attack: tấn công      speed: chạy nhanh hơn bao nhiêu phần trăm
##
## Độ bền: mỗi lần bị đánh trúng, mọi món đang mặc mất WEAR_PER_HIT độ bền.
## Hết độ bền thì món đó "Hỏng": vẫn mặc trên người nhưng không còn cộng chỉ số.
## Mang tới Thợ rèn ở quảng trường làng để sửa (tốn vàng, món càng xịn sửa càng đắt).
##
## Muốn thêm trang bị mới: thêm một mục vào DATA và vẽ hình 16x16 đặt ở assets/gear/<tên>.png
##   slot: helmet (mũ), armor (giáp), pants (quần), boots (giày)
##   tier: bậc 1 đến 5 (rương ở tầng hầm ngục sâu hơn ra bậc cao hơn)
##
## Mỗi món trang bị trong túi / trên người là một Dictionary:
##   { "id": "helmet_2", "rarity": "common", "dur": 64 }   (dur = độ bền còn lại)
##
## Hai thứ khác nhau quyết định món đồ mạnh cỡ nào:
##   Bậc (Da, Sắt, Thép, Dung Nham, Bóng Đêm): theo tầng hầm ngục, tầng càng sâu bậc càng cao.
##   Độ hiếm (Thường, Bạc, Vàng, Kim cương): theo may rủi khi mở rương, rương xịn thì dễ ra độ hiếm cao.
##   Ví dụ "Mũ sắt [Vàng]" = mũ bậc 2, độ hiếm Vàng: chỉ số và độ bền gấp 1.45 lần Mũ sắt thường.

const SLOTS := ["helmet", "armor", "pants", "boots"]
const SLOT_NAMES := { "helmet": "Mũ", "armor": "Giáp", "pants": "Quần", "boots": "Giày" }
const STAT_NAMES := { "defense": "Phòng thủ", "hp": "Máu", "attack": "Tấn công", "speed": "Tốc độ" }
const TIER_NAMES := ["", "Da", "Sắt", "Thép", "Dung Nham", "Bóng Đêm"]
const MAX_TIER := 5
## Phòng thủ bằng số này thì chỉ nhận một nửa sát thương (số càng lớn thì phòng thủ càng yếu đi).
const DEFENSE_SCALE := 50.0
## Độ bền tối đa theo bậc (bậc 1 đến 5). Bị đánh trúng một lần: mỗi món đang mặc mất WEAR_PER_HIT.
const TIER_DURABILITY := [0, 60, 80, 100, 130, 160]
const WEAR_PER_HIT := 1
## Còn dưới bao nhiêu phần độ bền thì báo "sắp hỏng".
const LOW_DURABILITY := 0.2
## Sửa đồ: mỗi điểm độ bền tốn (bậc x REPAIR_GOLD) vàng.
const REPAIR_GOLD := 0.4
## Giá mua ở Thợ rèn theo bậc (bán lại được SELL_RATIO giá, đồ đã mòn thì rẻ hơn).
const TIER_PRICE := [0, 40, 90, 180, 350, 650]

## Độ hiếm: 4 bậc giống tên 4 loại rương (Thường, Bạc, Vàng, Kim cương).
## Tỉ lệ ra từng độ hiếm khi mở rương nằm ở "rarity" của từng loại rương trong scripts/chest.gd.
##   name: tên hiện lên      color: màu tên đồ và viền ô
##   mult: chỉ số, độ bền và giá gấp bao nhiêu lần đồ Thường
## Muốn thêm độ hiếm mới: thêm một dòng vào RARITIES và thêm tên đó vào RARITY_ORDER,
## rồi ghi tỉ lệ cho nó trong "rarity" của các loại rương (scripts/chest.gd).
const DEFAULT_RARITY := "common"
const RARITIES := {
	"common": { "name": "Thường", "color": Color(0.88, 0.88, 0.86), "mult": 1.0 },
	"silver": { "name": "Bạc", "color": Color(0.72, 0.84, 1.0), "mult": 1.2 },
	"gold": { "name": "Vàng", "color": Color(1.0, 0.84, 0.3), "mult": 1.45 },
	"diamond": { "name": "Kim cương", "color": Color(0.45, 0.95, 1.0), "mult": 1.8 },
}
## Thứ tự từ thấp tới cao.
const RARITY_ORDER := ["common", "silver", "gold", "diamond"]

const DATA := {
	# ---- Bậc 1: Da (bàn chế tạo, rương tầng 1)
	"helmet_1": { "slot": "helmet", "tier": 1, "name": "Mũ da", "stats": { "defense": 2, "hp": 5 } },
	"armor_1": { "slot": "armor", "tier": 1, "name": "Áo giáp da", "stats": { "defense": 3, "hp": 10 } },
	"pants_1": { "slot": "pants", "tier": 1, "name": "Quần da", "stats": { "defense": 2, "hp": 5 } },
	"boots_1": { "slot": "boots", "tier": 1, "name": "Giày da", "stats": { "defense": 1, "speed": 3 } },
	# ---- Bậc 2: Sắt
	"helmet_2": { "slot": "helmet", "tier": 2, "name": "Mũ sắt", "stats": { "defense": 4, "hp": 10 } },
	"armor_2": { "slot": "armor", "tier": 2, "name": "Giáp sắt", "stats": { "defense": 6, "hp": 20 } },
	"pants_2": { "slot": "pants", "tier": 2, "name": "Quần giáp sắt", "stats": { "defense": 4, "hp": 10 } },
	"boots_2": { "slot": "boots", "tier": 2, "name": "Giày sắt", "stats": { "defense": 2, "speed": 4 } },
	# ---- Bậc 3: Thép xanh
	"helmet_3": { "slot": "helmet", "tier": 3, "name": "Mũ thép xanh", "stats": { "defense": 6, "hp": 16, "attack": 1 } },
	"armor_3": { "slot": "armor", "tier": 3, "name": "Giáp thép xanh", "stats": { "defense": 9, "hp": 32 } },
	"pants_3": { "slot": "pants", "tier": 3, "name": "Quần giáp thép", "stats": { "defense": 6, "hp": 16 } },
	"boots_3": { "slot": "boots", "tier": 3, "name": "Giày thép", "stats": { "defense": 4, "speed": 6 } },
	# ---- Bậc 4: Dung Nham
	"helmet_4": { "slot": "helmet", "tier": 4, "name": "Mũ sừng dung nham", "stats": { "defense": 9, "hp": 24, "attack": 2 } },
	"armor_4": { "slot": "armor", "tier": 4, "name": "Giáp dung nham", "stats": { "defense": 13, "hp": 46, "attack": 2 } },
	"pants_4": { "slot": "pants", "tier": 4, "name": "Quần giáp dung nham", "stats": { "defense": 9, "hp": 24 } },
	"boots_4": { "slot": "boots", "tier": 4, "name": "Giày dung nham", "stats": { "defense": 6, "speed": 8, "attack": 1 } },
	# ---- Bậc 5: Bóng Đêm
	"helmet_5": { "slot": "helmet", "tier": 5, "name": "Vương miện bóng đêm", "stats": { "defense": 12, "hp": 34, "attack": 3 } },
	"armor_5": { "slot": "armor", "tier": 5, "name": "Giáp bóng đêm", "stats": { "defense": 18, "hp": 64, "attack": 3 } },
	"pants_5": { "slot": "pants", "tier": 5, "name": "Quần giáp bóng đêm", "stats": { "defense": 12, "hp": 34, "attack": 2 } },
	"boots_5": { "slot": "boots", "tier": 5, "name": "Giày cánh bóng đêm", "stats": { "defense": 8, "speed": 10, "attack": 2 } },
}

const SLOT_ICONS := {
	"helmet": preload("res://assets/gear/slot_helmet.png"),
	"armor": preload("res://assets/gear/slot_armor.png"),
	"pants": preload("res://assets/gear/slot_pants.png"),
	"boots": preload("res://assets/gear/slot_boots.png"),
}


static func is_gear(id: String) -> bool:
	return DATA.has(id)


static func slot_of(id: String) -> String:
	return DATA.get(id, {}).get("slot", "")


static func rarity_info(rarity: String) -> Dictionary:
	return RARITIES.get(rarity, RARITIES[DEFAULT_RARITY])


static func icon(id: String) -> Texture2D:
	return load("res://assets/gear/%s.png" % id)


## Tạo một món trang bị mới (độ bền đầy).
static func make(id: String, rarity: String = DEFAULT_RARITY) -> Dictionary:
	return { "id": id, "rarity": rarity, "dur": max_durability(id, rarity) }


static func tier_of(id: String) -> int:
	return int(DATA.get(id, {}).get("tier", 1))


static func max_durability(id: String, rarity: String = DEFAULT_RARITY) -> int:
	var tier := clampi(tier_of(id), 1, TIER_DURABILITY.size() - 1)
	return roundi(float(TIER_DURABILITY[tier]) * float(rarity_info(rarity)["mult"]))


## Món đồ (Dictionary) đã hỏng chưa.
static func is_broken(item: Dictionary) -> bool:
	return int(item.get("dur", 1)) <= 0


## Vàng để sửa đầy một món.
static func repair_cost(item: Dictionary) -> int:
	var missing := max_durability(item["id"], item.get("rarity", DEFAULT_RARITY)) - int(item.get("dur", 0))
	if missing <= 0:
		return 0
	return maxi(1, ceili(float(missing) * float(tier_of(item["id"])) * REPAIR_GOLD))


## Giá mua một món mới ở Thợ rèn.
static func price(id: String, rarity: String = DEFAULT_RARITY) -> int:
	var tier := clampi(tier_of(id), 1, TIER_PRICE.size() - 1)
	return roundi(float(TIER_PRICE[tier]) * float(rarity_info(rarity)["mult"]))


## Chỉ số thật của một món (đã nhân theo độ hiếm).
static func stats(id: String, rarity: String = DEFAULT_RARITY) -> Dictionary:
	var base: Dictionary = DATA.get(id, {}).get("stats", {})
	var mult: float = rarity_info(rarity)["mult"]
	var out := {}
	for key in base:
		out[key] = roundi(float(base[key]) * mult)
	return out


## Cộng chỉ số của mọi món đang mặc (món hỏng không tính). gear = { "helmet": món hoặc {}, ... }
static func total_stats(gear: Dictionary) -> Dictionary:
	var total := { "defense": 0, "hp": 0, "attack": 0, "speed": 0 }
	for slot in gear:
		var item: Dictionary = gear[slot]
		if item.is_empty() or is_broken(item):
			continue
		var s := stats(item["id"], item.get("rarity", DEFAULT_RARITY))
		for key in s:
			total[key] = int(total.get(key, 0)) + int(s[key])
	return total


## "Phòng thủ +4, Máu +10"
static func stats_text(s: Dictionary, sep: String = ", ") -> String:
	var parts := PackedStringArray()
	for key in ["defense", "hp", "attack", "speed"]:
		if int(s.get(key, 0)) != 0:
			parts.append("%s +%d%s" % [STAT_NAMES[key], int(s[key]), "%" if key == "speed" else ""])
	return sep.join(parts)


## Chữ hiện khi rê chuột lên món đồ (item = { "id", "rarity", "dur" }).
static func tooltip(item: Dictionary) -> String:
	var id: String = item.get("id", "")
	if not DATA.has(id):
		return ""
	var data: Dictionary = DATA[id]
	var rarity: String = item.get("rarity", DEFAULT_RARITY)
	var tier := int(data["tier"])
	var dur_max := max_durability(id, rarity)
	var dur := int(item.get("dur", dur_max))
	var text := "%s  [%s]\n%s, bậc %d (%s)\n%s\nĐộ bền: %d/%d" % [data["name"], rarity_info(rarity)["name"],
		SLOT_NAMES[data["slot"]], tier, TIER_NAMES[tier], stats_text(stats(id, rarity)), dur, dur_max]
	if dur <= 0:
		text += "  (HỎNG: không còn tác dụng, mang tới Thợ rèn để sửa)"
	return text


## Tên kèm độ hiếm (đồ Thường thì chỉ có tên): "Mũ sắt [Vàng]".
static func full_name(id: String, rarity: String = DEFAULT_RARITY) -> String:
	var name: String = DATA.get(id, {}).get("name", id)
	if rarity == "" or rarity == DEFAULT_RARITY or not RARITIES.has(rarity):
		return name
	return "%s [%s]" % [name, RARITIES[rarity]["name"]]


## Độ hiếm cao tới đâu: 0 = Thường, 1 = Bạc, 2 = Vàng, 3 = Kim cương.
static func rarity_rank(rarity: String) -> int:
	return maxi(RARITY_ORDER.find(rarity), 0)


## Tên kèm độ bền ngắn gọn: "Mũ sắt (64/80)".
static func short_name(item: Dictionary) -> String:
	var id: String = item.get("id", "")
	var name: String = DATA.get(id, {}).get("name", id)
	return "%s (%d/%d)" % [name, int(item.get("dur", 0)), max_durability(id, item.get("rarity", DEFAULT_RARITY))]


## Thông tin giống một mục trong Items.DATA (để túi đồ, bảng chế tạo, đồ rơi dùng chung).
static func item_info(id: String) -> Dictionary:
	if not DATA.has(id):
		return {}
	var data: Dictionary = DATA[id]
	var tier := int(data["tier"])
	return {
		"name": data["name"],
		"icon": icon(id),
		"gear": data["slot"],
		"desc": "%s bậc %d (%s): %s. Bấm để mặc." % [SLOT_NAMES[data["slot"]], tier, TIER_NAMES[tier],
			stats_text(stats(id))],
	}


## Điểm để so món nào tốt hơn (càng cao càng tốt).
static func score(id: String, rarity: String) -> float:
	var s := stats(id, rarity)
	return float(s.get("defense", 0)) * 2.0 + float(s.get("hp", 0)) * 0.5 \
		+ float(s.get("attack", 0)) * 3.0 + float(s.get("speed", 0)) * 1.5


## Sát thương còn lại sau khi trừ phòng thủ (ít nhất 1).
static func reduce_damage(amount: int, defense: int) -> int:
	if defense <= 0:
		return amount
	return maxi(1, roundi(float(amount) * DEFENSE_SCALE / (DEFENSE_SCALE + float(defense))))


## Phòng thủ chặn được bao nhiêu phần trăm sát thương.
static func block_percent(defense: int) -> int:
	return roundi(100.0 - 100.0 * DEFENSE_SCALE / (DEFENSE_SCALE + float(maxi(defense, 0))))


## Một món ngẫu nhiên thuộc bậc tier ("" nếu không có món nào).
static func random_piece(tier: int) -> String:
	var pool: Array[String] = []
	for id in DATA:
		if int(DATA[id]["tier"]) == tier:
			pool.append(id)
	if pool.is_empty():
		return ""
	return pool[randi() % pool.size()]


## Chọn độ hiếm theo tỉ lệ phần trăm, số lẻ cũng được,
## ví dụ { "common": 89.999, "silver": 9, "gold": 1, "diamond": 0.001 } (0.001 = cứ 100.000 lần mới ra 1 lần).
static func roll_rarity(weights: Dictionary) -> String:
	var total := 0.0
	for key in weights:
		if RARITIES.has(key):
			total += maxf(float(weights[key]), 0.0)
	if total <= 0.0:
		return DEFAULT_RARITY
	var roll := randf() * total
	var last := DEFAULT_RARITY
	for key in weights:
		if not RARITIES.has(key) or float(weights[key]) <= 0.0:
			continue
		last = key
		roll -= float(weights[key])
		if roll < 0.0:
			return key
	return last
