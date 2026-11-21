class_name Projectile
extends Area2D
## Đạn bay thẳng: cầu lửa của người chơi, mũi tên / quả cầu bóng tối của quái.

const RING_EFFECT := preload("res://scripts/effects/ring_effect.gd")

var direction := Vector2.RIGHT
var speed := 200.0
var damage := 5
var from_player := true
var life := 2.0
var hit_color := Color(1, 0.6, 0.2)
var pierce := 0              # xuyên qua thêm bao nhiêu con quái
var heavy := false           # đòn nặng (mũi tên gồng đầy): khựng hình khi trúng
var armor_pierce := 0.0
var armor_break := 0
var _already_hit: Array = []
var _done := false           # đã nổ, không trúng thêm gì nữa

@onready var sprite: Sprite2D = $Sprite2D


## Gọi trước khi thêm đạn vào scene.
func setup(dir: Vector2, spd: float, dmg: int, is_player: bool, texture: Texture2D, color: Color) -> void:
	direction = dir.normalized()
	speed = spd
	damage = dmg
	from_player = is_player
	hit_color = color
	rotation = direction.angle()
	# Lớp va chạm: 1 = tường, 2 = người chơi, 4 = quái
	collision_layer = 0
	collision_mask = 1 | (4 if is_player else 2)
	set_meta("texture", texture)


func _ready() -> void:
	if has_meta("texture"):
		sprite.texture = get_meta("texture")
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	# Đạn của người chơi trúng quái khi bay vào vùng trúng đòn (hit_radius) của quái,
	# rộng hơn thân quái nên dễ bắn trúng hơn.
	if from_player and not _done:
		for node in get_tree().get_nodes_in_group("enemies"):
			var enemy := node as Enemy
			if enemy == null or enemy.is_dead or _already_hit.has(enemy):
				continue
			if enemy.global_position.distance_to(global_position) <= enemy.hit_radius + 3.0:
				if _hit_enemy(enemy):
					return


func _on_body_entered(body: Node2D) -> void:
	if _done:
		return
	if from_player and body is Enemy:
		var enemy := body as Enemy
		if enemy.is_dead or _already_hit.has(enemy):
			return
		_hit_enemy(enemy)
	elif not from_player and body is Player:
		if (body as Player).take_damage(damage, direction):
			_explode()
	elif body is StaticBody2D:
		_explode()


func _explode() -> void:
	if _done:
		return
	_done = true
	var ring := RING_EFFECT.new()
	ring.max_radius = 12.0
	ring.duration = 0.2
	ring.color = hit_color
	ring.global_position = global_position
	get_parent().add_child.call_deferred(ring)
	queue_free()



## Trúng một con quái. Trả về true nếu viên đạn đã nổ (không bay tiếp).
func _hit_enemy(enemy: Enemy) -> bool:
	_already_hit.append(enemy)
	enemy.take_damage(damage, direction * (220.0 if heavy else 110.0), armor_pierce, armor_break)
	if heavy:
		Game.hit_stop(0.05)
		Game.shake(2.5)
	if pierce > 0:
		pierce -= 1
		Game.burst(global_position, hit_color, 5, 40.0, 0.0, 0.2, 1.5)
		return false
	_explode()
	return true
