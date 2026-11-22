class_name Pickup
extends Node2D
## Vật phẩm rơi trên đất. Người chơi lại gần sẽ tự hút vào và nhặt.

enum Kind { XP_GEM, GOLD, POTION_HP, POTION_MP, POWER_CRYSTAL, ELEMENT_CORE, ITEM }
## ITEM: vật phẩm cất vào túi (da thú, thịt, xương..., trang bị), tên vật phẩm nằm trong item_id.

const TEXTURES := {
	Kind.XP_GEM: preload("res://assets/items/xp_gem.png"),
	Kind.GOLD: preload("res://assets/items/coin.png"),
	Kind.POTION_HP: preload("res://assets/items/potion_hp.png"),
	Kind.POTION_MP: preload("res://assets/items/potion_mp.png"),
	Kind.POWER_CRYSTAL: preload("res://assets/items/power_crystal.png"),
	Kind.ELEMENT_CORE: preload("res://assets/items/element_core.png"),
}

const MAGNET_RANGE := 40.0
const COLLECT_RANGE := 8.0

var kind: Kind = Kind.XP_GEM
var value := 1
var item_id := ""          # chỉ dùng khi kind = ITEM (tên trong scripts/items.gd hoặc scripts/equipment.gd)
var rarity := ""           # độ hiếm của trang bị (scripts/equipment.gd), "" = Thường
var pop_velocity := Vector2.ZERO
var _time := 0.0
var _delay := 0.3  # chờ một chút sau khi rơi rồi mới hút
var _sparkle := 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if kind == Kind.ITEM:
		sprite.texture = Items.info(item_id).get("icon")
	else:
		sprite.texture = TEXTURES[kind]
	_time = randf() * TAU


func _process(delta: float) -> void:
	_time += delta
	_delay -= delta
	# Bay văng ra lúc mới rơi
	position += pop_velocity * delta
	pop_velocity = pop_velocity.move_toward(Vector2.ZERO, 300.0 * delta)
	# Nhấp nhô
	sprite.position.y = sin(_time * 4.0) * 1.5 - 2.0
	# Trang bị độ hiếm Hiếm trở lên nằm dưới đất thì lấp lánh theo màu độ hiếm
	if kind == Kind.ITEM and Equipment.rarity_rank(rarity) >= 1:
		_sparkle -= delta
		if _sparkle <= 0.0:
			_sparkle = 0.45
			Game.burst(global_position + Vector2(randf_range(-4, 4), -6), Equipment.rarity_info(rarity)["color"], 2, 14.0, -8.0, 0.5, 1.2)

	if _delay > 0.0:
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead:
		return
	var dist := global_position.distance_to(player.global_position)
	var magnet := MAGNET_RANGE * (3.0 if kind == Kind.ELEMENT_CORE else 1.0)
	if dist < magnet:
		global_position = global_position.move_toward(player.global_position, 160.0 * delta)
	if dist < COLLECT_RANGE:
		_collect(player)


func _collect(player: Player) -> void:
	match kind:
		Kind.XP_GEM:
			player.add_xp(value)
		Kind.GOLD:
			player.gold += value
		Kind.POTION_HP:
			# Cất vào túi để dùng sau (phím D), túi đầy thì uống luôn
			if player.add_item("potion_hp"):
				Game.popup_text(player.global_position, "+1 Bình máu", Color(1.0, 0.5, 0.5))
			else:
				player.heal(value)
		Kind.POTION_MP:
			if player.add_item("potion_mp"):
				Game.popup_text(player.global_position, "+1 Bình năng lượng", Color(0.5, 0.7, 1.0))
			else:
				player.restore_mana(value)
		Kind.POWER_CRYSTAL:
			player.add_attack(value)
		Kind.ELEMENT_CORE:
			player.unlock_thunder()
		Kind.ITEM:
			if Equipment.is_gear(item_id):
				# Trang bị: chỗ đó đang trống thì tự mặc luôn
				var r: String = rarity if rarity != "" else Equipment.DEFAULT_RARITY
				if not player.pick_up_gear(Equipment.make(item_id, r)):
					Game.popup_text(global_position + Vector2(0, -12), "Túi đầy!", Color(1.0, 0.6, 0.5), 9)
					_delay = 2.0
					return
				queue_free()
				return
			if not player.add_item(item_id, value):
				# Túi đầy: để nguyên dưới đất, chờ một lúc rồi thử lại
				Game.popup_text(global_position + Vector2(0, -12), "Túi đầy!", Color(1.0, 0.6, 0.5), 9)
				_delay = 2.0
				return
			var item_name: String = Items.info(item_id).get("name", item_id)
			Game.popup_text(player.global_position + Vector2(0, -14), "+%d %s" % [value, item_name], Color(0.95, 0.85, 0.6), 9)
	queue_free()


## Hàm tiện ích: tạo vật phẩm tại vị trí pos và thêm vào parent.
static func spawn(parent: Node, item_kind: Kind, pos: Vector2, amount: int = 1) -> void:
	var scene: PackedScene = load("res://scenes/pickup.tscn")
	var p := scene.instantiate() as Pickup
	p.kind = item_kind
	p.value = amount
	p.position = pos
	p.pop_velocity = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(30.0, 70.0)
	parent.add_child.call_deferred(p)


## Rơi một vật phẩm cất vào túi (da thú, thịt...) tại vị trí pos.
## Trang bị thì có thể ghi thêm độ hiếm (item_rarity).
static func spawn_item(parent: Node, id: String, pos: Vector2, amount: int = 1, item_rarity: String = "") -> void:
	var scene: PackedScene = load("res://scenes/pickup.tscn")
	var p := scene.instantiate() as Pickup
	p.kind = Kind.ITEM
	p.item_id = id
	p.rarity = item_rarity
	p.value = amount
	p.position = pos
	p.pop_velocity = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(30.0, 70.0)
	parent.add_child.call_deferred(p)
