class_name Items
extends RefCounted
## Danh sách vật phẩm cất được trong túi đồ (phím B).
## Muốn thêm vật phẩm mới: thêm một mục vào DATA rồi viết cách dùng trong Player.use_item().
## Đồ ăn có "heal": bấm vào trong túi để ăn, hồi bấy nhiêu máu.
## Đồ ăn có "regen": [máu mỗi giây, số giây]: hồi máu từ từ.
## Đồ không có "heal" / "regen" là nguyên liệu để chế tạo (công thức ở scripts/recipes.gd).

const DATA := {
	"potion_hp": {
		"name": "Bình máu",
		"icon": preload("res://assets/items/potion_hp.png"),
		"desc": "Hồi 40% máu tối đa. Phím D để dùng nhanh.",
		"heal_ratio": 0.4,
	},
	"potion_mp": {
		"name": "Bình năng lượng",
		"icon": preload("res://assets/items/potion_mp.png"),
		"desc": "Hồi 15 năng lượng.",
		"mana": 15,
	},
	# --- Thu hoạch từ cây (Rừng Thông, Đầm Lầy Nấm, các làng)
	"berry": {
		"name": "Quả mọng",
		"icon": preload("res://assets/items/berry.png"),
		"desc": "Hái từ bụi cây trong rừng. Ăn hồi 8 máu.",
		"heal": 8,
	},
	"herb": {
		"name": "Thảo dược",
		"icon": preload("res://assets/items/herb.png"),
		"desc": "Lá thuốc mọc trong rừng và đầm lầy. Hồi 20 máu.",
		"heal": 20,
	},
	"mushroom": {
		"name": "Nấm rừng",
		"icon": preload("res://assets/items/mushroom.png"),
		"desc": "Nấm ăn được, nhiều nhất ở Đầm Lầy Nấm. Hồi 10 máu.",
		"heal": 10,
	},
	"apple": {
		"name": "Táo",
		"icon": preload("res://assets/items/apple.png"),
		"desc": "Táo chín từ vườn táo. Hồi 15 máu.",
		"heal": 15,
	},
	"carrot": {
		"name": "Cà rốt",
		"icon": preload("res://assets/items/carrot.png"),
		"desc": "Cà rốt tươi. Hồi 12 máu.",
		"heal": 12,
	},
	"pumpkin": {
		"name": "Bí ngô",
		"icon": preload("res://assets/items/pumpkin.png"),
		"desc": "Bí ngô to, ăn no lâu. Hồi 30 máu.",
		"heal": 30,
	},
	"wheat": {
		"name": "Lúa mì",
		"icon": preload("res://assets/items/wheat.png"),
		"desc": "Nguyên liệu: làm dây thừng, nướng bánh mì.",
	},
	# --- Nguyên liệu khác
	"water": {
		"name": "Bình nước",
		"icon": preload("res://assets/items/water.png"),
		"desc": "Lấy ở xô nước cạnh giếng làng. Nguyên liệu nấu thuốc, nấu ăn.",
	},
	"hide": {
		"name": "Da thú",
		"icon": preload("res://assets/items/hide.png"),
		"desc": "Rơi ra khi hạ sói, heo rừng. Làm ba lô, áo giáp da.",
	},
	"bone": {
		"name": "Xương",
		"icon": preload("res://assets/items/bone.png"),
		"desc": "Rơi ra khi hạ sói, heo rừng. Nấu canh, làm bùa.",
	},
	"rope": {
		"name": "Dây thừng",
		"icon": preload("res://assets/items/rope.png"),
		"desc": "Bện từ lúa mì ở bàn chế tạo.",
	},
	# --- Đồ ăn (thịt sống ăn được, nấu chín thì hồi nhiều hơn)
	"meat": {
		"name": "Thịt sống",
		"icon": preload("res://assets/items/meat.png"),
		"desc": "Ăn sống hồi 6 máu. Nấu ở nồi thành thịt nướng ngon hơn.",
		"heal": 6,
	},
	# --- Đồ chế tạo được (xem scripts/recipes.gd)
	"cooked_meat": {
		"name": "Thịt nướng",
		"icon": preload("res://assets/items/cooked_meat.png"),
		"desc": "Thơm phức! Hồi 35 máu.",
		"heal": 35,
	},
	"bread": {
		"name": "Bánh mì",
		"icon": preload("res://assets/items/bread.png"),
		"desc": "Bánh mì nóng giòn. Hồi 25 máu.",
		"heal": 25,
	},
	"mushroom_soup": {
		"name": "Súp nấm",
		"icon": preload("res://assets/items/mushroom_soup.png"),
		"desc": "Hồi máu từ từ: 5 máu mỗi giây trong 10 giây.",
		"regen": [5, 10],
	},
	"bone_broth": {
		"name": "Canh xương",
		"icon": preload("res://assets/items/bone_broth.png"),
		"desc": "Hồi máu từ từ: 6 máu mỗi giây trong 15 giây.",
		"regen": [6, 15],
	},
}


static func info(id: String) -> Dictionary:
	return DATA.get(id, {})
