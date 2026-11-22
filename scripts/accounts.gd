class_name Accounts
extends RefCounted
## Tài khoản: mỗi nhân vật là một tài khoản, lưu thành một file riêng trong thư mục user://tai_khoan/.
## Mỗi file lưu: ngoại hình + vũ khí (chọn lúc tạo nhân vật), cấp, kinh nghiệm, vàng, túi đồ, trang bị,
## thứ tự kỹ năng, chỗ đang đứng và tiến độ thế giới (đã phá phong ấn cửa hang chưa, bếp lửa đã đặt...).
## Game tự lưu (xem AUTOSAVE_SECONDS trong scripts/main.gd), người chơi không cần bấm gì.
## Muốn xem file lưu: trong Godot chọn Project > Open User Data Folder, mở thư mục tai_khoan.
##
## Lần đầu mở game có hệ thống tài khoản, game tạo sẵn "Tài Khoản Full" (cấp tối đa, đồ xịn, nhiều vàng)
## để thử mọi tính năng. Xóa đi rồi thì bấm "Thêm tài khoản Full" ở màn hình chọn tài khoản để có lại.

const DIR := "user://tai_khoan"
const SETTINGS_PATH := "user://tai_khoan/cai_dat.ini"   # ghi nhớ đã tạo tài khoản Full / đã chuyển nhân vật cũ chưa
const OLD_SAVE_PATH := "user://nhan_vat.cfg"            # file nhân vật kiểu cũ (trước khi có tài khoản)
const VERSION := 1

# --- Tài khoản Full (tạo sẵn để thử mọi tính năng) ---
const FULL_NAME := "Tài Khoản Full"
const FULL_WEAPON := 0            # chỉ số trong Weapons.ORDER: 0 Kiếm, 1 Thương, 2 Cung, 3 Sách phép
const FULL_GOLD := 999999
const FULL_RARITY := "mythic"     # trang bị Thần thánh
## Đồ trong túi của tài khoản Full: [tên vật phẩm, số lượng]. Chừa vài ô trống để nhặt đồ từ rương.
const FULL_BAG := [
	["potion_hp", 99], ["potion_hp_big", 99], ["potion_strength", 99], ["potion_speed", 99],
	["axe", 1], ["sickle", 1], ["torch", 1], ["campfire_kit", 20],
	["bone_broth", 99], ["apple_pie", 99], ["wood", 99], ["rope", 99],
	["hide", 99], ["bone", 99], ["wheat", 99], ["water", 99],
]


static func path(id: String) -> String:
	return "%s/%s.cfg" % [DIR, id]


## Gọi một lần khi mở màn hình chọn tài khoản: tạo thư mục, lần đầu thì tạo tài khoản Full
## và chuyển nhân vật kiểu cũ (nếu có) thành một tài khoản.
static func setup() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var settings := ConfigFile.new()
	settings.load(SETTINGS_PATH)   # chưa có file thì thôi, coi như lần đầu
	var changed := false
	if not bool(settings.get_value("cai_dat", "da_tao_tai_khoan_full", false)):
		settings.set_value("cai_dat", "da_tao_tai_khoan_full", true)
		changed = true
		create_full()
	if not bool(settings.get_value("cai_dat", "da_chuyen_nhan_vat_cu", false)):
		settings.set_value("cai_dat", "da_chuyen_nhan_vat_cu", true)
		changed = true
		var old := ConfigFile.new()
		if old.load(OLD_SAVE_PATH) == OK:
			var look := CharacterParts.DEFAULT.duplicate()
			for key in look:
				look[key] = old.get_value("nhan_vat", key, look[key])
			create(look)
	if changed:
		settings.save(SETTINGS_PATH)


## Danh sách tài khoản, chơi gần nhất xếp trên cùng.
## Mỗi mục: { "id", "name", "weapon", "level", "last_played", "full", "look" }
static func list() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var dir := DirAccess.open(DIR)
	if dir == null:
		return out
	for file in dir.get_files():
		if file.get_extension() != "cfg":
			continue
		var id := file.get_basename()
		var cfg := ConfigFile.new()
		if cfg.load(path(id)) != OK:
			continue
		var look := _read_look(cfg)
		var progress: Dictionary = cfg.get_value("tien_do", "data", {})
		out.append({
			"id": id,
			"name": str(look.get("name", "")),
			"weapon": int(look.get("weapon", 0)) % Weapons.ORDER.size(),
			"level": int(progress.get("level", 1)),
			"last_played": int(cfg.get_value("tai_khoan", "choi_luc", 0)),
			"full": bool(cfg.get_value("tai_khoan", "full", false)),
			"look": look,
		})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["last_played"]) > int(b["last_played"]))
	return out


## Đọc toàn bộ một tài khoản: { "look", "tien_do", "the_gioi" } ({} nếu không đọc được).
static func read(id: String) -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(path(id)) != OK:
		return {}
	return {
		"look": _read_look(cfg),
		"tien_do": cfg.get_value("tien_do", "data", {}),
		"the_gioi": cfg.get_value("the_gioi", "data", {}),
	}


## Ghi tài khoản id: ngoại hình look và tiến độ progress { "tien_do", "the_gioi" }.
static func write(id: String, look: Dictionary, progress: Dictionary) -> Error:
	var cfg := ConfigFile.new()
	cfg.load(path(id))   # giữ lại ngày tạo, dấu tài khoản Full
	var now := int(Time.get_unix_time_from_system())
	cfg.set_value("tai_khoan", "phien_ban", VERSION)
	if not cfg.has_section_key("tai_khoan", "tao_luc"):
		cfg.set_value("tai_khoan", "tao_luc", now)
	cfg.set_value("tai_khoan", "choi_luc", now)
	for key in look:
		cfg.set_value("nhan_vat", key, look[key])
	cfg.set_value("tien_do", "data", progress.get("tien_do", {}))
	cfg.set_value("the_gioi", "data", progress.get("the_gioi", {}))
	return cfg.save(path(id))


## Tạo tài khoản mới (nhân vật vừa tạo, cấp 1). Trả về id của tài khoản.
static func create(look: Dictionary, progress: Dictionary = {}, full: bool = false) -> String:
	DirAccess.make_dir_recursive_absolute(DIR)
	var id := ""
	while id == "" or FileAccess.file_exists(path(id)):
		id = "tk_%d_%04d" % [int(Time.get_unix_time_from_system()), randi() % 10000]
	if full:
		var cfg := ConfigFile.new()
		cfg.set_value("tai_khoan", "full", true)
		cfg.save(path(id))
	write(id, look, progress)
	return id


static func delete(id: String) -> void:
	if FileAccess.file_exists(path(id)):
		DirAccess.remove_absolute(path(id))


static func has_full() -> bool:
	for acc in list():
		if acc["full"]:
			return true
	return false


## Tài khoản Full: cấp tối đa, mở hết kỹ năng (và phím D), trang bị Thần thánh bậc cao nhất,
## túi đồ tối đa đầy thuốc, đồ ăn, công cụ, nguyên liệu, rất nhiều vàng, cửa hang đã mở sẵn.
static func create_full() -> String:
	var look := CharacterParts.DEFAULT.duplicate()
	look["name"] = FULL_NAME
	look["weapon"] = FULL_WEAPON
	look["hair"] = 1
	look["hair_color"] = 3
	look["outfit"] = 2
	look["outfit_color"] = 5
	look["hat"] = 2
	var weapon_type: int = Weapons.ORDER[FULL_WEAPON]
	var gear := {}
	for slot in ["helmet", "armor", "pants", "boots"]:
		gear[slot] = Equipment.make("%s_%d" % [slot, Equipment.MAX_TIER], FULL_RARITY)
	gear["weapon"] = Equipment.make(Equipment.weapon_id(weapon_type, Equipment.MAX_TIER), FULL_RARITY)
	var bag := []
	for entry in FULL_BAG:
		bag.append({ "id": entry[0], "count": entry[1] })
	var skills: Array = (Weapons.info(weapon_type)["skills"] as Array).duplicate()
	var progress := {
		"tien_do": {
			"level": Player.MAX_LEVEL,
			"xp": 0,
			"gold": FULL_GOLD,
			"bonus_attack": 4,                      # Bùa răng sói
			"bag_slots": Player.BAG_SLOTS_MAX,
			"upgrades": { "bag": 2, "charm": 1 },  # đã làm Ba lô lớn hơn (2 lần) và Bùa răng sói
			"bag": bag,
			"gear": gear,
			"skill_slots": skills,
			"weapon_uses": 0,
		},
		"the_gioi": { "gate_open": true },          # đã phá phong ấn cửa hang: vào thẳng Hầm Ngục Cổ
	}
	return create(look, progress, true)


## "22/11/2026 15:40" theo giờ máy tính.
static func time_text(unix: int) -> String:
	if unix <= 0:
		return "chưa chơi"
	var bias := int(Time.get_time_zone_from_system().get("bias", 0))
	var t := Time.get_datetime_dict_from_unix_time(unix + bias * 60)
	return "%02d/%02d/%d %02d:%02d" % [t["day"], t["month"], t["year"], t["hour"], t["minute"]]


static func _read_look(cfg: ConfigFile) -> Dictionary:
	var look := CharacterParts.DEFAULT.duplicate()
	for key in look:
		look[key] = cfg.get_value("nhan_vat", key, look[key])
	return look
