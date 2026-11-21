class_name Weapons
extends RefCounted
## Bảng thông số các loại vũ khí. Muốn cân bằng game thì sửa số ở đây.
##
##   damage        : nhân với chỉ số Tấn công của nhân vật
##   cooldown      : thời gian nghỉ giữa 2 đòn (giây) - càng nhỏ đánh càng nhanh
##   range / arc   : tầm với (pixel) và độ rộng góc chém (độ)
##   armor_pierce  : bỏ qua bao nhiêu phần giáp của quái (0 = không, 1 = toàn bộ)
##   armor_break   : mỗi đòn trúng làm giáp quái giảm đi bao nhiêu
##
## Vũ khí được chọn khi tạo nhân vật và KHÔNG đổi được khi đang chơi.
## "skills" là chỗ để sau này thêm cây kỹ năng riêng cho từng loại vũ khí
## (ví dụ: Cung gồng bắn tên nguyên tố, Sách dùng toàn bộ sức mạnh nguyên tố).

enum Type { SWORD, SPEAR, BOW, BOOK }

const ORDER := [Type.SWORD, Type.SPEAR, Type.BOW, Type.BOOK]

const DATA := {
	Type.SWORD: {
		"name": "Kiếm",
		"class_name": "Kiếm Sĩ",
		"skills": [],
		"desc": "Kiếm: đánh rất nhanh, bấm liên tục ra combo 3 đòn. Bị giáp chặn bớt sát thương.",
		"icon": preload("res://assets/weapons/sword_icon.png"),
		"texture": preload("res://assets/weapons/sword.png"),
		"held": preload("res://assets/weapons/sword_held.png"),
		"damage": 1.0,
		"finisher_damage": 1.5,
		"cooldown": 0.2,
		"finisher_cooldown": 0.34,
		"range": 24.0,
		"arc": 150.0,
		"knockback": 130.0,
		"armor_pierce": 0.0,
		"armor_break": 0,
	},
	Type.SPEAR: {
		"name": "Thương",
		"class_name": "Thương Thủ",
		"skills": [],
		"desc": "Thương: đâm xa và mạnh nhưng chậm hơn. Xuyên giáp và phá giáp quái.",
		"icon": preload("res://assets/weapons/spear_icon.png"),
		"texture": preload("res://assets/weapons/spear.png"),
		"held": preload("res://assets/weapons/spear_held.png"),
		"damage": 1.3,
		"cooldown": 0.42,
		"range": 40.0,
		"arc": 44.0,
		"knockback": 170.0,
		"armor_pierce": 0.7,
		"armor_break": 2,
	},
	Type.BOW: {
		"name": "Cung",
		"class_name": "Xạ Thủ",
		"skills": [],  # sau này: tên Lửa, tên Băng... khi gồng
		"desc": "Cung: bắn xa. Giữ nút chém để gồng, thả ra bắn mũi tên đau hơn và xuyên quái.",
		"icon": preload("res://assets/weapons/bow.png"),
		"texture": preload("res://assets/weapons/bow.png"),
		"held": preload("res://assets/weapons/bow_held.png"),
		"arrow": preload("res://assets/weapons/arrow.png"),
		"damage": 0.8,            # bắn nhanh (không gồng)
		"charged_damage": 2.6,    # gồng đầy
		"charge_time": 0.9,       # thời gian gồng đầy (giây)
		"cooldown": 0.3,
		"arrow_speed": 240.0,
		"charged_speed": 380.0,
		"charged_pierce": 2,      # mũi tên gồng đầy xuyên qua thêm 2 con
		"armor_pierce": 0.0,
		"armor_break": 0,
	},
	Type.BOOK: {
		"name": "Sách Phép",
		"class_name": "Pháp Sư",
		"skills": [],  # sau này: phép nguyên tố
		"desc": "Sách Phép: nơi cất giữ sức mạnh nguyên tố. Sẽ được thức tỉnh trong bản sau.",
		"icon": preload("res://assets/weapons/spellbook.png"),
		"texture": preload("res://assets/weapons/spellbook.png"),
		"cooldown": 0.5,
	},
}


## Tư thế cầm vũ khí trong tay lúc không đánh (Sách Phép thì bay cạnh người nên không cần).
## Mỗi hướng: [vị trí so với tâm nhân vật, vẽ sau lưng nhân vật?, lật ngang?]
const HOLD_POSES := {
	"down": [Vector2(5, 2), false, false],
	"up": [Vector2(-5, 2), true, true],
	"right": [Vector2(4, 2), true, false],
	"left": [Vector2(-4, 2), true, true],
}


static func info(type: int) -> Dictionary:
	return DATA[type]


## Hướng nhìn ("down" / "up" / "right" / "left") theo hàng sprite sheet nhân vật.
static func direction_name(row: int, face_left: bool) -> String:
	if row == 1:
		return "up"
	if row == 2:
		return "left" if face_left else "right"
	return "down"
