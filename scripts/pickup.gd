class_name Pickup
extends Node2D
## Vật phẩm rơi trên đất. Người chơi lại gần sẽ tự hút vào và nhặt.

enum Kind { XP_GEM, GOLD, POTION_HP, POTION_MP, POWER_CRYSTAL, ELEMENT_CORE }

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
var pop_velocity := Vector2.ZERO
var _time := 0.0
var _delay := 0.3  # chờ một chút sau khi rơi rồi mới hút

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
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
			player.heal(value)
		Kind.POTION_MP:
			player.restore_mana(value)
		Kind.POWER_CRYSTAL:
			player.add_attack(value)
		Kind.ELEMENT_CORE:
			player.unlock_thunder()
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
