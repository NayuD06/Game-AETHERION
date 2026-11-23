class_name Items
extends RefCounted
## Danh sách vật phẩm cất được trong túi đồ (phím B).
## Muốn thêm vật phẩm mới: thêm một mục vào DATA rồi viết cách dùng trong Player.use_item().
## Đồ ăn có "heal": bấm vào trong túi để ăn, hồi bấy nhiêu máu.
## Đồ ăn có "regen": [máu mỗi giây, số giây]: hồi máu từ từ.
## Thuốc có "buff": ["attack", cộng thêm, số giây] hoặc ["speed", tỉ lệ chạy nhanh hơn, số giây].
## Công cụ có "tool": để trong túi là có tác dụng (Rìu chặt gỗ, Liềm hái thêm, Đuốc soi sáng hầm ngục).
## "place": bấm vào trong túi để đặt xuống đất (Bộ lửa trại).
## Đồ không có "heal" / "regen" là nguyên liệu để chế tạo (công thức ở scripts/recipes.gd).
## Trang bị (mũ, giáp, quần, giày) nằm riêng trong scripts/equipment.gd.

const DATA := {
	"potion_hp": {
		"name": "Bình máu",
		"icon": preload("res://assets/items/potion_hp.png"),
		"desc": "Hồi 40% máu tối đa. Phím D để dùng nhanh.",
		"heal_ratio": 0.4,
	},
	"potion_hp_big": {
		"name": "Bình máu lớn",
		"icon": preload("res://assets/items/potion_hp_big.png"),
		"desc": "Hồi 80% máu tối đa.",
		"heal_ratio": 0.8,
	},
	"potion_strength": {
		"name": "Thuốc sức mạnh",
		"icon": preload("res://assets/items/potion_strength.png"),
		"desc": "Tấn công +6 trong 60 giây.",
		"buff": ["attack", 6, 60.0],
	},
	"potion_speed": {
		"name": "Thuốc nhanh nhẹn",
		"icon": preload("res://assets/items/potion_speed.png"),
		"desc": "Chạy nhanh hơn 30% trong 60 giây.",
		"buff": ["speed", 0.3, 60.0],
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
	"wood": {
		"name": "Gỗ",
		"icon": preload("res://assets/items/wood.png"),
		"desc": "Chặt ở gốc cây trong rừng (cần Rìu). Làm liềm, đuốc, bộ lửa trại.",
	},
	# --- Công cụ (làm ở bàn chế tạo, để trong túi là dùng được)
	"axe": {
		"name": "Rìu",
		"icon": preload("res://assets/items/axe.png"),
		"desc": "Công cụ: có rìu trong túi thì đi tới gốc cây là chặt được gỗ.",
		"tool": true,
	},
	"sickle": {
		"name": "Liềm",
		"icon": preload("res://assets/items/sickle.png"),
		"desc": "Công cụ: hái cây, rau, quả được thêm 1 mỗi lần.",
		"tool": true,
	},
	"torch": {
		"name": "Đuốc",
		"icon": preload("res://assets/items/torch.png"),
		"desc": "Công cụ: vòng sáng quanh người to hơn khi ở trong hầm ngục.",
		"tool": true,
	},
	"campfire_kit": {
		"name": "Bộ lửa trại",
		"icon": preload("res://assets/items/campfire_kit.png"),
		"desc": "Bấm vào để đặt bếp lửa ngay chỗ đứng. Ở đâu cũng nướng đồ ăn được.",
		"place": "fire",
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
	"mushroom_skewer": {
		"name": "Xiên nấm nướng",
		"icon": preload("res://assets/items/mushroom_skewer.png"),
		"desc": "Nấm nướng thơm lừng. Hồi 25 máu.",
		"heal": 25,
	},
	"roast_pumpkin": {
		"name": "Bí ngô nướng",
		"icon": preload("res://assets/items/roast_pumpkin.png"),
		"desc": "Bí ngô nướng ngọt bùi. Hồi 50 máu.",
		"heal": 50,
	},
	"meat_skewer": {
		"name": "Xiên thịt rau",
		"icon": preload("res://assets/items/meat_skewer.png"),
		"desc": "Thịt nướng xiên với cà rốt, nấm. Hồi 60 máu.",
		"heal": 60,
	},
	"pumpkin_soup": {
		"name": "Súp bí ngô",
		"icon": preload("res://assets/items/pumpkin_soup.png"),
		"desc": "Hồi máu từ từ: 8 máu mỗi giây trong 12 giây.",
		"regen": [8, 12],
	},
	"apple_pie": {
		"name": "Bánh táo",
		"icon": preload("res://assets/items/apple_pie.png"),
		"desc": "Bánh táo nướng lò. Hồi 45 máu.",
		"heal": 45,
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
	# --- Biển, sông hồ (câu ở chỗ nước gợn sóng, cần Cần câu)
	"fish": {
		"name": "Cá",
		"icon": preload("res://assets/items/fish.png"),
		"desc": "Câu ở chỗ nước gợn sóng. Ăn sống hồi 6 máu, nướng ở bếp lửa ngon hơn.",
		"heal": 6,
	},
	"shrimp": {
		"name": "Tôm",
		"icon": preload("res://assets/items/shrimp.png"),
		"desc": "Câu được ở biển và hồ. Ăn hồi 5 máu.",
		"heal": 5,
	},
	"big_fish": {
		"name": "Cá ngừ",
		"icon": preload("res://assets/items/big_fish.png"),
		"desc": "Cá to, hiếm khi câu được. Nướng thành Cá ngừ nướng hồi rất nhiều máu.",
		"heal": 12,
	},
	"pearl": {
		"name": "Ngọc trai",
		"icon": preload("res://assets/items/pearl.png"),
		"desc": "Rất hiếm, câu được ở biển hoặc rơi ra từ cua. Bán được nhiều vàng.",
	},
	"crab_meat": {
		"name": "Thịt cua",
		"icon": preload("res://assets/items/crab_meat.png"),
		"desc": "Rơi ra khi hạ cua ở bờ biển. Ăn sống hồi 8 máu.",
		"heal": 8,
	},
	"date": {
		"name": "Quả chà là",
		"icon": preload("res://assets/items/date.png"),
		"desc": "Quả ngọt ở Ốc Đảo giữa sa mạc. Hồi 12 máu.",
		"heal": 12,
	},
	"scorpion_tail": {
		"name": "Đuôi bọ cạp",
		"icon": preload("res://assets/items/scorpion_tail.png"),
		"desc": "Rơi ra khi hạ bọ cạp sa mạc. Nấu ở nồi luyện thuốc thành Thuốc sức mạnh.",
	},
	"fishing_rod": {
		"name": "Cần câu",
		"icon": preload("res://assets/items/fishing_rod.png"),
		"desc": "Công cụ: có cần câu trong túi thì đứng gần chỗ nước gợn sóng là câu được cá.",
		"tool": true,
	},
	"boat": {
		"name": "Thuyền",
		"icon": preload("res://assets/items/boat.png"),
		"desc": "Công cụ: có thuyền trong túi thì đi được trên sông, hồ, biển (chuột phải xuống nước).",
		"tool": true,
	},
	"grilled_fish": {
		"name": "Cá nướng",
		"icon": preload("res://assets/items/grilled_fish.png"),
		"desc": "Cá nướng thơm lừng. Hồi 30 máu.",
		"heal": 30,
	},
	"grilled_tuna": {
		"name": "Cá ngừ nướng",
		"icon": preload("res://assets/items/grilled_tuna.png"),
		"desc": "Miếng cá ngừ to nướng vàng. Hồi 70 máu.",
		"heal": 70,
	},
	"grilled_crab": {
		"name": "Cua nướng",
		"icon": preload("res://assets/items/grilled_crab.png"),
		"desc": "Cua nướng chắc thịt. Hồi 45 máu.",
		"heal": 45,
	},
	"fish_soup": {
		"name": "Canh cá",
		"icon": preload("res://assets/items/fish_soup.png"),
		"desc": "Hồi máu từ từ: 9 máu mỗi giây trong 12 giây.",
		"regen": [9, 12],
	},
	"cherry_tea": {
		"name": "Trà hoa đào",
		"icon": preload("res://assets/items/cherry_tea.png"),
		"desc": "Trà thơm của Làng Hoa Đào. Hồi 15 máu, chạy nhanh hơn 20% trong 90 giây.",
		"heal": 15,
		"buff": ["speed", 0.2, 90.0],
	},
}


## Thông tin vật phẩm (trang bị mũ, giáp, quần, giày lấy từ scripts/equipment.gd).
static func info(id: String) -> Dictionary:
	if DATA.has(id):
		return DATA[id]
	return Equipment.item_info(id)
