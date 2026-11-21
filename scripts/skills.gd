class_name Skills
extends RefCounted
## Danh sách TẤT CẢ kỹ năng trong game. Muốn cân bằng game thì sửa số ở đây.
##
## Ô Q W E R của nhân vật chỉ ghi id kỹ năng (biến skill_slots trong scripts/player.gd).
## Vì vậy sau này có thể "đội" kỹ năng khác vào ô (ví dụ kỹ năng nguyên tố) bằng
## player.equip_skill(số_ô, "id_kỹ_năng") mà không phải sửa code ô kỹ năng hay HUD.
## Bộ kỹ năng mặc định của từng vũ khí nằm ở "skills" trong scripts/weapons.gd.
##
##   name     : tên đầy đủ (hiện trong bảng Esc và khi tung tuyệt chiêu)
##   short    : tên ngắn hiện trên ô kỹ năng
##   desc     : mô tả
##   weapon   : vũ khí cần cầm để dùng (-1 = vũ khí nào cũng dùng được)
##   ult      : true = tuyệt chiêu, chỉ đặt được vào ô R
##   element  : nguyên tố ("" = chưa có). Sau này: "fire", "thunder"...
##   cooldown : thời gian hồi chiêu (giây)
##   power    : hệ số sát thương mỗi đòn (nhân với chỉ số Tấn công)
##   cast     : tên hàm trong scripts/player.gd chạy khi tung kỹ năng
##              (hàm nhận 3 thứ: hướng chuột, sát thương, bảng thông số này)
## Các số khác (hits, reach, radius...) là thông số riêng của từng kỹ năng.

const SLOT_KEYS := ["Q", "W", "E", "R"]
const ULT_SLOT := 3

const DATA := {
	# ------------------------------------------------------------ Kiếm
	"sword_triple_slash": {
		"name": "Triple Slash", "short": "Triple Slash",
		"desc": "Chém liên tiếp 3 nhát theo hình vòng cung phía trước.",
		"weapon": Weapons.Type.SWORD, "ult": false, "element": "",
		"cooldown": 4.0, "power": 0.9, "hits": 3, "reach": 30.0, "arc": 160.0,
		"cast": "_skill_triple_slash",
	},
	"sword_piercing_thrust": {
		"name": "Piercing Thrust", "short": "Piercing Thrust",
		"desc": "Lao nhanh về phía trước và đâm kiếm xuyên qua kẻ địch trên đường đi.",
		"weapon": Weapons.Type.SWORD, "ult": false, "element": "",
		"cooldown": 6.0, "power": 1.6, "distance": 80.0,
		"cast": "_skill_piercing_thrust",
	},
	"sword_whirlwind": {
		"name": "Whirlwind Slash", "short": "Whirlwind",
		"desc": "Xoay người chém một vòng 360°, gây sát thương xung quanh.",
		"weapon": Weapons.Type.SWORD, "ult": false, "element": "",
		"cooldown": 5.0, "power": 1.5, "radius": 32.0,
		"cast": "_skill_whirlwind",
	},
	"sword_swordstorm": {
		"name": "Swordstorm", "short": "Sword Storm",
		"desc": "Tung ra chuỗi 7 nhát chém cực nhanh, kết thúc bằng một nhát chém mạnh diện rộng.",
		"weapon": Weapons.Type.SWORD, "ult": true, "element": "",
		"cooldown": 25.0, "power": 0.7, "hits": 7, "finisher_power": 3.0, "finisher_radius": 54.0,
		"cast": "_skill_swordstorm",
	},
	# ------------------------------------------------------------ Cung
	"bow_double_shot": {
		"name": "Double Shot", "short": "Double Shot",
		"desc": "Bắn nhanh 2 mũi tên liên tiếp vào mục tiêu.",
		"weapon": Weapons.Type.BOW, "ult": false, "element": "",
		"cooldown": 3.0, "power": 1.2, "arrows": 2,
		"cast": "_skill_double_shot",
	},
	"bow_piercing_arrow": {
		"name": "Piercing Arrow", "short": "Piercing Arrow",
		"desc": "Kéo căng cung và bắn một mũi tên xuyên qua nhiều kẻ địch trên đường thẳng.",
		"weapon": Weapons.Type.BOW, "ult": false, "element": "",
		"cooldown": 6.0, "power": 2.4, "draw_time": 0.3,
		"cast": "_skill_piercing_arrow",
	},
	"bow_backstep_shot": {
		"name": "Backstep Shot", "short": "Backstep Shot",
		"desc": "Lùi nhanh về phía sau đồng thời bắn 3 mũi tên về phía trước.",
		"weapon": Weapons.Type.BOW, "ult": false, "element": "",
		"cooldown": 6.0, "power": 1.0, "arrows": 3, "distance": 64.0,
		"cast": "_skill_backstep_shot",
	},
	"bow_rain_of_arrows": {
		"name": "Rain of Arrows", "short": "Rain of Arrows",
		"desc": "Nhắm vào một khu vực và bắn liên tiếp hàng loạt mũi tên từ trên cao xuống.",
		"weapon": Weapons.Type.BOW, "ult": true, "element": "",
		"cooldown": 25.0, "power": 0.7, "radius": 46.0, "ticks": 12, "range": 180.0,
		"cast": "_skill_rain_of_arrows",
	},
	# ------------------------------------------------------------ Thương
	"spear_thrust": {
		"name": "Spear Thrust", "short": "Spear Thrust",
		"desc": "Đâm thương cực nhanh về phía trước, gây sát thương cao trên một đường thẳng.",
		"weapon": Weapons.Type.SPEAR, "ult": false, "element": "",
		"cooldown": 4.0, "power": 2.0, "reach": 68.0,
		"cast": "_skill_spear_thrust",
	},
	"spear_sweeping_strike": {
		"name": "Sweeping Strike", "short": "Sweeping Strike",
		"desc": "Quét thương theo chiều ngang, đánh trúng nhiều kẻ địch phía trước.",
		"weapon": Weapons.Type.SPEAR, "ult": false, "element": "",
		"cooldown": 5.0, "power": 1.4, "reach": 42.0, "arc": 190.0,
		"cast": "_skill_sweeping_strike",
	},
	"spear_impaling_charge": {
		"name": "Impaling Charge", "short": "Impaling Charge",
		"desc": "Lao tới và đâm mạnh vào mục tiêu, đẩy lùi kẻ địch.",
		"weapon": Weapons.Type.SPEAR, "ult": false, "element": "",
		"cooldown": 8.0, "power": 2.2, "distance": 96.0, "push": 380.0,
		"cast": "_skill_impaling_charge",
	},
	"spear_heavens_spear": {
		"name": "Heaven's Spear", "short": "Heaven's Spear",
		"desc": "Lấy đà, nhảy lên rồi giáng một cú đâm thương cực mạnh xuống mặt đất, gây sát thương diện rộng quanh điểm tiếp đất.",
		"weapon": Weapons.Type.SPEAR, "ult": true, "element": "",
		"cooldown": 25.0, "power": 3.5, "radius": 58.0, "range": 110.0,
		"cast": "_skill_heavens_spear",
	},
	# ------------------------------------------------------------ Sách phép
	# Tạm thời: sau này thay bằng phép nguyên tố.
	"book_orb": {
		"name": "Cầu Phép", "short": "Cầu Phép",
		"desc": "(Tạm thời) Bắn quả cầu phép to, xuyên qua 1 quái.",
		"weapon": Weapons.Type.BOOK, "ult": false, "element": "",
		"cooldown": 3.0, "power": 1.6,
		"cast": "_skill_book_orb",
	},
	"book_nova": {
		"name": "Vòng Phép", "short": "Vòng Phép",
		"desc": "(Tạm thời) Nổ vòng phép quanh người, đẩy lùi quái.",
		"weapon": Weapons.Type.BOOK, "ult": false, "element": "",
		"cooldown": 7.0, "power": 1.2, "radius": 48.0,
		"cast": "_skill_book_nova",
	},
	"book_blink": {
		"name": "Dịch Chuyển", "short": "Dịch Chuyển",
		"desc": "(Tạm thời) Dịch chuyển tức thời tới chỗ con trỏ (tối đa 90 pixel).",
		"weapon": Weapons.Type.BOOK, "ult": false, "element": "",
		"cooldown": 8.0, "power": 0.0, "range": 90.0,
		"cast": "_skill_book_blink",
	},
	"book_meteor": {
		"name": "Thiên Thạch", "short": "Thiên Thạch",
		"desc": "(Tạm thời) TUYỆT CHIÊU: gọi thiên thạch phép rơi xuống chỗ con trỏ.",
		"weapon": Weapons.Type.BOOK, "ult": true, "element": "",
		"cooldown": 25.0, "power": 3.5, "radius": 46.0, "range": 170.0,
		"cast": "_skill_book_meteor",
	},
}


## Thông số kỹ năng theo id ({} nếu không có).
static func info(id: String) -> Dictionary:
	return DATA.get(id, {})


## Kỹ năng id có đặt được vào ô slot (0 = Q ... 3 = R) khi cầm vũ khí weapon không?
static func can_equip(id: String, weapon: int, slot: int) -> bool:
	var s := info(id)
	if s.is_empty():
		return false
	if int(s["weapon"]) != -1 and int(s["weapon"]) != weapon:
		return false
	return bool(s["ult"]) == (slot == ULT_SLOT)


## Mọi kỹ năng mà vũ khí weapon dùng được (để làm bảng chọn kỹ năng sau này).
static func list_for_weapon(weapon: int) -> Array[String]:
	var result: Array[String] = []
	for id in DATA:
		var w := int(DATA[id]["weapon"])
		if w == -1 or w == weapon:
			result.append(id)
	return result
