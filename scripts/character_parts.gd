class_name CharacterParts
extends RefCounted
## Danh sách các phần ngoại hình nhân vật (màn hình tạo nhân vật dùng file này).
## Muốn thêm kiểu tóc / trang phục / mũ mới: vẽ sprite sheet 96x96
## (4 cột x 3 hàng, mỗi khung 24x32: hàng 1 đi xuống, hàng 2 đi lên, hàng 3 đi ngang sang phải),
## bỏ vào assets/character/ rồi thêm một dòng vào danh sách bên dưới.
##
## Da, tay, tóc và trang phục được vẽ màu xám để tô màu bằng code (self_modulate).
## Mặt (mắt) và mũ được vẽ sẵn màu nên không tô.
## Thứ tự lớp từ dưới lên: thân (da) < mặt < trang phục < bàn tay < tóc < mũ.

const FRAME_SIZE := Vector2(24, 32)
## Dời hình lên để bàn chân nhân vật nằm đúng chỗ bóng đổ / va chạm.
const SPRITE_OFFSET := Vector2(0, -7)

const BODY := preload("res://assets/character/body.png")
const FACE := preload("res://assets/character/face.png")
const HANDS := preload("res://assets/character/hands.png")

const SKIN_TONES := [
	["Sáng", Color(1.0, 0.92, 0.85)],
	["Hồng hào", Color(0.98, 0.84, 0.76)],
	["Rám nắng", Color(0.9, 0.72, 0.58)],
	["Nâu", Color(0.74, 0.54, 0.4)],
	["Sẫm", Color(0.52, 0.37, 0.28)],
]

const HAIR_STYLES := [
	["Ngắn", preload("res://assets/character/hair_short.png")],
	["Dài", preload("res://assets/character/hair_long.png")],
	["Dựng đứng", preload("res://assets/character/hair_spiky.png")],
	["Đuôi ngựa", preload("res://assets/character/hair_ponytail.png")],
	["Trọc", null],
]

const HAIR_COLORS := [
	["Nâu", Color(0.55, 0.33, 0.2)],
	["Đen", Color(0.27, 0.23, 0.27)],
	["Vàng", Color(0.98, 0.85, 0.45)],
	["Đỏ", Color(0.85, 0.35, 0.2)],
	["Bạc", Color(0.92, 0.92, 0.96)],
	["Xanh dương", Color(0.4, 0.55, 0.95)],
	["Hồng", Color(0.95, 0.55, 0.75)],
	["Xanh lá", Color(0.45, 0.78, 0.42)],
]

const OUTFITS := [
	["Áo vải", preload("res://assets/character/outfit_tunic.png")],
	["Giáp sắt", preload("res://assets/character/outfit_armor.png")],
	["Áo choàng", preload("res://assets/character/outfit_robe.png")],
	["Áo da", preload("res://assets/character/outfit_leather.png")],
]

const OUTFIT_COLORS := [
	["Xanh dương", Color(0.4, 0.6, 1.0)],
	["Đỏ", Color(0.92, 0.35, 0.35)],
	["Xanh lá", Color(0.45, 0.78, 0.42)],
	["Tím", Color(0.68, 0.5, 0.95)],
	["Nâu", Color(0.72, 0.52, 0.34)],
	["Đen", Color(0.38, 0.38, 0.46)],
	["Trắng / thép", Color(1.0, 1.0, 1.0)],
	["Vàng", Color(1.0, 0.86, 0.42)],
]

const HATS := [
	["Không đội", null],
	["Mũ sắt", preload("res://assets/character/hat_helmet.png")],
	["Mũ phù thủy", preload("res://assets/character/hat_wizard.png")],
	["Mũ trùm", preload("res://assets/character/hat_hood.png")],
	["Khăn buộc đầu", preload("res://assets/character/hat_bandana.png")],
	["Vương miện", preload("res://assets/character/hat_crown.png")],
]

## Ngoại hình mặc định (chỉ số trong từng danh sách ở trên).
const DEFAULT := {
	"name": "Lữ Khách",
	"weapon": 0,  # chỉ số trong Weapons.ORDER
	"skin": 0,
	"hair": 0,
	"hair_color": 0,
	"outfit": 0,
	"outfit_color": 0,
	"hat": 0,
}


## Gắn các lớp ngoại hình lên một Sprite2D thân.
## Các lớp mặt / áo / tay / tóc / mũ là con của Sprite2D đó, tên "Face", "Outfit", "Hands", "Hair", "Hat".
static func apply_to_sprite(body: Sprite2D, look: Dictionary) -> void:
	body.texture = BODY
	body.hframes = 4
	body.vframes = 3
	body.offset = SPRITE_OFFSET
	var skin: Color = SKIN_TONES[look.get("skin", 0) % SKIN_TONES.size()][1]
	body.self_modulate = skin
	var outfit: Array = OUTFITS[look.get("outfit", 0) % OUTFITS.size()]
	var outfit_color: Color = OUTFIT_COLORS[look.get("outfit_color", 0) % OUTFIT_COLORS.size()][1]
	var hair: Array = HAIR_STYLES[look.get("hair", 0) % HAIR_STYLES.size()]
	var hair_color: Color = HAIR_COLORS[look.get("hair_color", 0) % HAIR_COLORS.size()][1]
	var hat: Array = HATS[look.get("hat", 0) % HATS.size()]
	_set_layer(body, "Face", FACE, Color.WHITE)
	_set_layer(body, "Outfit", outfit[1], outfit_color)
	_set_layer(body, "Hands", HANDS, skin)
	_set_layer(body, "Hair", hair[1], hair_color)
	_set_layer(body, "Hat", hat[1], Color.WHITE)


static func _set_layer(body: Sprite2D, layer_name: String, texture: Texture2D, tint: Color) -> void:
	var layer := body.get_node_or_null(layer_name) as Sprite2D
	if layer == null:
		layer = Sprite2D.new()
		layer.name = layer_name
		layer.hframes = body.hframes
		layer.vframes = body.vframes
		body.add_child(layer)
	layer.offset = body.offset
	layer.texture = texture
	layer.visible = texture != null
	layer.self_modulate = tint


## Đồng bộ khung hình và lật ngang của các lớp theo Sprite2D thân.
static func sync_frames(body: Sprite2D) -> void:
	for child in body.get_children():
		var layer := child as Sprite2D
		if layer:
			layer.frame = body.frame
			layer.flip_h = body.flip_h
