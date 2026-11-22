class_name Enemy
extends CharacterBody2D
## Lớp cơ sở cho mọi quái vật. Quái cụ thể (slime, dơi, cung thủ, boss)
## kế thừa file này và viết lại hàm _ai() để có cách di chuyển riêng.

signal died(enemy: Enemy)

@export var display_name := "Quái vật"
@export var max_hp := 20
@export var speed := 40.0
@export var contact_damage := 6
@export var xp_reward := 5
@export var gold_reward := 1
@export var detect_range := 110.0
@export var hit_radius := 7.0          # vùng trúng đòn (càng lớn càng dễ đánh trúng)
@export var visual_scale := 1.0        # phóng to hình quái (1.5 = to gấp rưỡi)
@export var overhead_bar := true       # hiện thanh máu nhỏ trên đầu (Boss dùng thanh máu lớn riêng)
@export var knockback_resist := 1.0  # 0 = không bị đẩy lùi, 1 = bị đẩy bình thường
@export var armor := 0  # giáp: trừ thẳng vào sát thương mỗi đòn (Thương xuyên và phá được giáp)
@export var death_color := Color(0.5, 0.85, 0.3)  # màu hạt bắn ra khi chết
@export var anim_speed := 6.0  # tốc độ đổi khung hình
## Vật phẩm rơi vào túi khi chết, mỗi mục: [tên vật phẩm, tỉ lệ rơi 0..1, ít nhất, nhiều nhất]
## Ví dụ sói: [["hide", 0.7, 1, 1], ["meat", 0.6, 1, 2], ["bone", 0.4, 1, 1]]
@export var item_drops: Array = []

var hp := 0
var player: Player = null
var knockback := Vector2.ZERO
var stun_time := 0.0
var contact_cd := 0.0
var flash_time := 0.0
var is_dead := false
var is_elite := false
var home := Vector2.ZERO
var wander_target := Vector2.ZERO
var wander_timer := 0.0
var anim_time := 0.0
var base_modulate := Color.WHITE
var squash := 0.0  # nảy hình khi bị đánh

const SHADOW_TEXTURE := preload("res://assets/sprites/shadow.png")
const SHIELD_TEXTURE := preload("res://assets/weapons/shield.png")
const OUTLINE_SHADER := preload("res://scripts/effects/outline.gdshader")

var highlighted := false   # chuột đang rê lên quái này (viền đỏ, hiện thanh máu)
var targeted := false      # người chơi đang khóa mục tiêu vào quái này (vòng đỏ dưới chân)
var sprite_base_y := 0.0   # hình được đẩy lên khi phóng to để chân vẫn chạm đất
var hp_bar: Node2D
var outline_material: ShaderMaterial

var max_armor := 0
var shield_icon: Sprite2D  # biểu tượng khiên trên đầu khi còn giáp

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	hp = max_hp
	var big := hit_radius >= 15.0   # quái to (Boss)
	var frame_h := float(sprite.texture.get_height()) / float(sprite.vframes) if sprite.texture else 16.0
	# Phóng to hình: đẩy hình lên để chân vẫn ở chỗ cũ
	sprite_base_y = -frame_h * (visual_scale - 1.0) / 2.0
	sprite.position.y = sprite_base_y
	sprite.scale = Vector2.ONE * visual_scale
	outline_material = ShaderMaterial.new()
	outline_material.shader = OUTLINE_SHADER
	sprite.material = outline_material
	var shadow := Sprite2D.new()
	shadow.texture = SHADOW_TEXTURE
	shadow.position = Vector2(0, 14 if big else 7)
	shadow.scale = Vector2.ONE * (2.0 if big else visual_scale)
	add_child(shadow)
	move_child(shadow, 0)
	max_armor = armor
	var head_y := sprite_base_y - frame_h * visual_scale / 2.0   # đỉnh đầu
	# Thanh máu nhỏ trên đầu (hiện khi bị đánh, khi rê chuột lên hoặc khi đang bị khóa mục tiêu)
	hp_bar = Node2D.new()
	hp_bar.position = Vector2(0, head_y - 4.0)
	hp_bar.z_index = 3
	hp_bar.visible = false
	hp_bar.draw.connect(_draw_hp_bar)
	add_child(hp_bar)
	shield_icon = Sprite2D.new()
	shield_icon.texture = SHIELD_TEXTURE
	shield_icon.scale = Vector2.ONE * 0.5
	shield_icon.position = Vector2(-_bar_width() / 2.0 - 5.0, head_y - 3.0)
	shield_icon.visible = armor > 0
	add_child(shield_icon)
	add_to_group("enemies")
	collision_layer = 4      # lớp "enemies"
	collision_mask = 1 | 4   # va vào tường và các quái khác
	home = global_position
	wander_target = global_position
	anim_time = randf() * TAU


## Quái ở khu vực 2 mạnh hơn (gọi trước khi thêm vào scene).
func make_elite() -> void:
	is_elite = true
	max_hp = int(max_hp * 2.0)
	contact_damage = int(contact_damage * 1.5)
	xp_reward = int(xp_reward * 2.5)
	gold_reward *= 3
	armor += 2
	speed *= 1.15
	base_modulate = Color(1.0, 0.7, 1.0)


## Quái trong hầm ngục: mạnh lên theo tầng (power, màu, tinh anh lấy từ scripts/dungeon.gd).
## Gọi trước khi thêm vào scene.
func apply_floor(power: Dictionary, tint: Color, elite: bool) -> void:
	max_hp = int(max_hp * float(power.get("hp", 1.0)))
	contact_damage = roundi(contact_damage * float(power.get("damage", 1.0)))
	if "arrow_damage" in self:
		set("arrow_damage", roundi(float(get("arrow_damage")) * float(power.get("damage", 1.0))))
	xp_reward = int(xp_reward * float(power.get("xp", 1.0)))
	gold_reward *= int(power.get("gold", 1))
	armor += int(power.get("armor", 0))
	speed *= float(power.get("speed", 1.0))
	base_modulate = tint
	is_elite = elite


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Player
	contact_cd = maxf(contact_cd - delta, 0.0)
	flash_time = maxf(flash_time - delta, 0.0)

	var move := Vector2.ZERO
	if stun_time > 0.0:
		stun_time -= delta
	else:
		move = _ai(delta)
	velocity = move + knockback
	knockback = knockback.move_toward(Vector2.ZERO, 500.0 * delta)
	move_and_slide()

	_check_contact()
	_animate(delta, move)


## Mặc định: đuổi theo người chơi khi thấy, không thì đi lang thang.
func _ai(delta: float) -> Vector2:
	if player_in_range(detect_range):
		return global_position.direction_to(player.global_position) * speed
	return _wander(delta)


func _wander(delta: float) -> Vector2:
	wander_timer -= delta
	if wander_timer <= 0.0:
		wander_timer = randf_range(1.5, 3.0)
		wander_target = home + Vector2(randf_range(-40, 40), randf_range(-40, 40))
	if global_position.distance_to(wander_target) < 4.0:
		return Vector2.ZERO
	return global_position.direction_to(wander_target) * speed * 0.4


func player_in_range(r: float) -> bool:
	return player != null and is_instance_valid(player) and not player.is_dead \
		and global_position.distance_to(player.global_position) <= r


func _check_contact() -> void:
	if contact_damage <= 0 or contact_cd > 0.0 or not player_in_range(_body_radius() + 8.0):
		return
	if player.take_damage(contact_damage, player.global_position - global_position):
		contact_cd = 0.8


func _animate(delta: float, move: Vector2) -> void:
	anim_time += delta * (anim_speed if move != Vector2.ZERO else anim_speed * 0.4)
	if sprite.hframes > 1:
		sprite.frame = int(anim_time) % sprite.hframes
	if move.x != 0.0:
		sprite.flip_h = move.x < 0.0
	# Nảy hình (bẹp ra rồi trở lại) khi bị đánh
	squash = move_toward(squash, 0.0, delta * 3.0)
	sprite.scale = Vector2(1.0 + squash, 1.0 - squash) * visual_scale
	if flash_time > 0.0:
		sprite.modulate = Color(4, 4, 4)
	elif stun_time > 0.0:
		sprite.modulate = Color(1.0, 1.0, 0.5)
	else:
		sprite.modulate = base_modulate


# ---------------------------------------------------------------- Nhận sát thương

## armor_pierce: bỏ qua bao nhiêu phần giáp (0..1). armor_break: giảm giáp đi bao nhiêu.
func take_damage(amount: int, push: Vector2 = Vector2.ZERO, armor_pierce: float = 0.0,
		armor_break: int = 0) -> void:
	if is_dead:
		return
	var effective_armor := roundi(armor * (1.0 - clampf(armor_pierce, 0.0, 1.0)))
	var final_damage := maxi(1, amount - effective_armor)
	var blocked := effective_armor > 0 and final_damage < amount * 0.6
	if armor_break > 0 and armor > 0:
		armor = maxi(armor - armor_break, 0)
		if armor == 0:
			Game.popup_text(global_position + Vector2(0, -16), "Phá giáp!", Color(0.6, 0.85, 1.0), 10)
			Game.burst(global_position, Color(0.75, 0.8, 0.9), 10, 70.0)
	shield_icon.visible = armor > 0
	amount = final_damage
	hp -= amount
	flash_time = 0.1
	squash = 0.3
	knockback = push * knockback_resist
	# Quái nhỏ bị khựng lại một chút khi trúng đòn
	if knockback_resist >= 0.5:
		stun(0.18)
	_update_hp_bar()
	var color := Color(0.65, 0.72, 0.85) if blocked else Color(1.0, 0.9, 0.4)
	Game.popup_text(global_position + Vector2(0, -6), str(amount), color)
	if hp <= 0:
		_die()


func stun(time: float) -> void:
	stun_time = maxf(stun_time, time * knockback_resist)


func _die() -> void:
	is_dead = true
	remove_from_group("enemies")
	_update_hp_bar()
	outline_material.set_shader_parameter("outline_on", false)
	queue_redraw()
	$CollisionShape2D.set_deferred("disabled", true)
	_drop_loot()
	Game.burst(global_position, death_color, 16, 80.0)
	Game.shake(1.5)
	died.emit(self)
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.4, 0.2), 0.2)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.25)
	tw.tween_callback(queue_free)


func _drop_loot() -> void:
	var parent := get_parent()
	# Ngọc kinh nghiệm: chia xp thành vài viên
	var gems := clampi(xp_reward / 4, 1, 6)
	var per_gem := maxi(1, xp_reward / gems)
	for i in gems:
		Pickup.spawn(parent, Pickup.Kind.XP_GEM, global_position, per_gem)
	if gold_reward > 0 and randf() < 0.6:
		Pickup.spawn(parent, Pickup.Kind.GOLD, global_position, gold_reward)
	var roll := randf()
	if roll < 0.12:
		Pickup.spawn(parent, Pickup.Kind.POTION_HP, global_position, 25)
	elif roll < 0.22 and Player.ELEMENTS_ENABLED:
		Pickup.spawn(parent, Pickup.Kind.POTION_MP, global_position, 15)
	elif roll < 0.25:
		Pickup.spawn(parent, Pickup.Kind.POWER_CRYSTAL, global_position, 2)
	for drop in item_drops:
		if drop is Array and drop.size() >= 4 and randf() < float(drop[1]):
			Pickup.spawn_item(parent, str(drop[0]), global_position, randi_range(int(drop[2]), int(drop[3])))


# ---------------------------------------------------------------- Chọn mục tiêu bằng chuột (kiểu LMHT / Dota)

## Bán kính thân (vòng va chạm), dùng để tính quái chạm vào người chơi.
func _body_radius() -> float:
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node != null and shape_node.shape is CircleShape2D:
		return (shape_node.shape as CircleShape2D).radius
	return 6.0


## Con trỏ chuột (toạ độ thế giới) có đang nằm trên quái này không. Vùng bấm rộng hơn hình một chút cho dễ chọn.
func is_under_mouse(pos: Vector2) -> bool:
	if is_dead:
		return false
	if global_position.distance_to(pos) <= hit_radius + 8.0:
		return true
	if sprite.texture == null:
		return false
	var frame := Vector2(sprite.texture.get_width() / float(sprite.hframes), sprite.texture.get_height() / float(sprite.vframes))
	var half := frame * visual_scale / 2.0 + Vector2(4, 4)
	var local := pos - (global_position + sprite.position)
	return absf(local.x) <= half.x and absf(local.y) <= half.y


func set_highlight(on: bool) -> void:
	if highlighted == on:
		return
	highlighted = on
	outline_material.set_shader_parameter("outline_on", on)
	_update_hp_bar()
	queue_redraw()


func set_targeted(on: bool) -> void:
	if targeted == on:
		return
	targeted = on
	outline_material.set_shader_parameter("outline_color", Color(1.0, 0.15, 0.1) if on else Color(1.0, 0.3, 0.25))
	_update_hp_bar()
	queue_redraw()


func _bar_width() -> float:
	return clampf(hit_radius * 2.0 + 4.0, 16.0, 36.0)


func _update_hp_bar() -> void:
	if hp_bar == null:
		return
	hp_bar.visible = overhead_bar and not is_dead and (hp < max_hp or highlighted or targeted)
	hp_bar.queue_redraw()


func _draw_hp_bar() -> void:
	var w := _bar_width()
	var ratio := clampf(float(hp) / float(maxi(max_hp, 1)), 0.0, 1.0)
	hp_bar.draw_rect(Rect2(-w / 2.0 - 1.0, -1.0, w + 2.0, 5.0), Color(0.05, 0.03, 0.05, 0.9))
	hp_bar.draw_rect(Rect2(-w / 2.0, 0.0, w * ratio, 3.0), Color(0.95, 0.2, 0.2) if not is_elite else Color(0.85, 0.3, 0.95))
	hp_bar.draw_rect(Rect2(-w / 2.0, 0.0, w * ratio, 1.0), Color(1.0, 0.55, 0.5, 0.8))


## Vòng dưới chân: đỏ đậm khi đang bị khóa mục tiêu, đỏ nhạt khi rê chuột lên.
func _draw() -> void:
	if is_dead or not (targeted or highlighted):
		return
	var r := hit_radius + 3.0
	var color := Color(1.0, 0.15, 0.1, 0.9) if targeted else Color(1.0, 0.45, 0.35, 0.6)
	draw_set_transform(Vector2(0, 7.0 if hit_radius < 15.0 else 14.0), 0.0, Vector2(1.0, 0.45))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 28, color, 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
