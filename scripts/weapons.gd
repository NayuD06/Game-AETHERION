class_name Weapons
extends RefCounted
## Bảng thông số các loại vũ khí. Muốn cân bằng game thì sửa số ở đây.
##
##   damage        : nhân với chỉ số Tấn công của nhân vật
##   cooldown      : thời gian nghỉ giữa 2 đòn (giây) - càng nhỏ đánh càng nhanh
##   range / arc   : tầm với (pixel) và độ rộng góc chém (độ)
##   armor_pierce  : bỏ qua bao nhiêu phần giáp của quái (0 = không, 1 = toàn bộ)
##   armor_break   : mỗi đòn trúng làm giáp quái giảm đi bao nhiêu
##   auto_range    : bấm chuột phải vào quái thì chạy tới khoảng cách này rồi tự đánh
##   grip          : khoảng cách từ bàn tay tới tâm hình vũ khí (pixel)
##   hold          : góc cầm vũ khí lúc đứng / đi (độ) khi nhìn xuống, lên, ngang
##
## Vũ khí được chọn khi tạo nhân vật và KHÔNG đổi được khi đang chơi.
##
## "skills": bộ kỹ năng mặc định khi vào game, theo thứ tự phím Q, W, E và R (tuyệt chiêu).
##   Chỉ ghi id kỹ năng. Thông số và mô tả kỹ năng nằm ở scripts/skills.gd.
##   Sau này người chơi có thể đổi kỹ năng khác vào ô (kỹ năng nguyên tố...).

enum Type { SWORD, SPEAR, BOW, BOOK }

const ORDER := [Type.SWORD, Type.SPEAR, Type.BOW, Type.BOOK]

const DATA := {
	Type.SWORD: {
		"name": "Kiếm",
		"class_name": "Kiếm Sĩ",
		"skills": ["sword_triple_slash", "sword_piercing_thrust", "sword_whirlwind", "sword_swordstorm"],
		"desc": "Kiếm: đánh rất nhanh, bấm liên tục ra combo 3 đòn. Bị giáp chặn bớt sát thương.",
		"icon": preload("res://assets/weapons/sword_icon.png"),
		"texture": preload("res://assets/weapons/sword.png"),
		"grip": 6.0,
		"hold": {"down": -60.0, "up": -110.0, "side": 35.0},
		"auto_range": 18.0,
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
		"skills": ["spear_thrust", "spear_sweeping_strike", "spear_impaling_charge", "spear_heavens_spear"],
		"desc": "Thương: đâm xa và mạnh nhưng chậm hơn. Xuyên giáp và phá giáp quái.",
		"icon": preload("res://assets/weapons/spear_icon.png"),
		"texture": preload("res://assets/weapons/spear.png"),
		"grip": 8.0,
		"hold": {"down": -80.0, "up": -100.0, "side": -15.0},
		"auto_range": 34.0,
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
		"skills": ["bow_double_shot", "bow_piercing_arrow", "bow_backstep_shot", "bow_rain_of_arrows"],
		"desc": "Cung: bắn xa. Giữ nút chém để gồng, thả ra bắn mũi tên đau hơn và xuyên quái.",
		"icon": preload("res://assets/weapons/bow.png"),
		"texture": preload("res://assets/weapons/bow.png"),
		"grip": 3.0,
		"hold": {"down": 0.0, "up": 180.0, "side": 0.0},
		"auto_range": 150.0,
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
		"skills": ["book_orb", "book_nova", "book_blink", "book_meteor"],  # tạm thời, sau này: phép nguyên tố
		"desc": "Sách Phép: bắn tia phép về phía con trỏ. Sức mạnh nguyên tố sẽ được thức tỉnh sau.",
		"damage": 0.7,
		"bolt_speed": 220.0,
		"icon": preload("res://assets/weapons/spellbook.png"),
		"texture": preload("res://assets/weapons/spellbook.png"),
		"cooldown": 0.5,
		"auto_range": 40.0,
	},
}


static func info(type: int) -> Dictionary:
	return DATA[type]


## Vị trí bàn tay cầm vũ khí so với tâm nhân vật (hình 24x32), theo hàng và khung hình sprite sheet.
## Hàng 0 = nhìn xuống, 1 = nhìn lên, 2 = nhìn ngang sang phải.
static func hand_position(row: int, col: int) -> Vector2:
	var s: int = [0, 1, 0, -1][col % 4]
	var b := 1 if col % 2 == 1 else 0
	if row == 0:
		return Vector2(5, b - s)
	if row == 1:
		return Vector2(-5, b - s)
	return Vector2(1 + 2 * s, b)


## Đặt vũ khí cầm trong tay theo hướng nhìn. pivot là Node2D có 1 Sprite2D con,
## body là Sprite2D thân nhân vật nằm cùng cha (để xếp vũ khí ra sau hoặc trước người).
static func pose_held(pivot: Node2D, body: Sprite2D, type: int, row: int, col: int, face_left: bool) -> void:
	var w := info(type)
	if not w.has("hold"):
		pivot.visible = false
		return
	var held := pivot.get_child(0) as Sprite2D
	held.texture = w["texture"]
	held.offset = Vector2(w["grip"], 0)
	var hand := hand_position(row, col)
	var angle := deg_to_rad(float(w["hold"][["down", "up", "side"][row]]))
	if face_left:
		hand.x = -hand.x
		angle = -angle
	pivot.position = hand
	pivot.rotation = angle
	pivot.scale = Vector2(-1, 1) if face_left else Vector2.ONE
	# Nhìn lên thì vũ khí ở phía trước người (xa người xem) nên vẽ sau lưng
	var behind := row == 1
	var body_index := body.get_index()
	var target := body_index if behind else body_index + 1
	if pivot.get_index() < body_index:
		target -= 1
	if pivot.get_index() != target:
		pivot.get_parent().move_child(pivot, target)
