extends Node2D
## Thú hiền: thỏ, nai, chim, bướm, ếch, vịt, và ở các vùng mới: hải âu, thằn lằn, lạc đà, khỉ, gấu trúc,
## cáo, dê núi, cá, rùa biển, cá heo.
## Chúng tự đi lại, ăn cỏ, và bỏ chạy (chim bay đi) khi người chơi tới gần. Cá, rùa, vịt, cá heo bơi dưới nước.
## Không đánh được, chỉ để khung cảnh sinh động. Số lượng mỗi loại ở từng khu nằm trong AREAS (scripts/world_map.gd).

const TEXTURES := {
	"rabbit": preload("res://assets/critters/rabbit.png"),
	"deer": preload("res://assets/critters/deer.png"),
	"bird": preload("res://assets/critters/bird.png"),
	"butterfly": preload("res://assets/critters/butterfly.png"),
	"frog": preload("res://assets/critters/frog.png"),
	"duck": preload("res://assets/critters/duck.png"),
	"gull": preload("res://assets/critters/gull.png"),
	"lizard": preload("res://assets/critters/lizard.png"),
	"camel": preload("res://assets/critters/camel.png"),
	"monkey": preload("res://assets/critters/monkey.png"),
	"panda": preload("res://assets/critters/panda.png"),
	"fox": preload("res://assets/critters/fox.png"),
	"goat": preload("res://assets/critters/goat.png"),
	"fish": preload("res://assets/critters/fish.png"),
	"turtle": preload("res://assets/critters/turtle.png"),
	"dolphin": preload("res://assets/critters/dolphin.png"),
}
const FRAMES := { "rabbit": 2, "deer": 2, "bird": 4, "butterfly": 2, "frog": 2, "duck": 2, "gull": 4, "lizard": 2,
	"camel": 2, "monkey": 2, "panda": 2, "fox": 2, "goat": 2, "fish": 2, "turtle": 2, "dolphin": 4 }
## Các loài sống dưới nước (chỉ bơi trên ô nước)
const SWIMMERS := ["duck", "fish", "turtle", "dolphin"]
## Các loài nhảy lò cò khi đi (còn lại bước đi bình thường)
const HOPPERS := ["rabbit", "frog"]
## [tốc độ đi, tốc độ chạy trốn, khoảng cách bắt đầu sợ, bán kính đi dạo]
const STATS := {
	"rabbit": [28.0, 80.0, 44.0, 48.0],
	"deer": [16.0, 70.0, 64.0, 64.0],
	"bird": [10.0, 70.0, 40.0, 24.0],
	"butterfly": [0.0, 0.0, 0.0, 22.0],
	"frog": [40.0, 55.0, 30.0, 24.0],
	"duck": [9.0, 9.0, 0.0, 40.0],
	"gull": [10.0, 70.0, 46.0, 24.0],
	"lizard": [45.0, 95.0, 36.0, 30.0],
	"camel": [12.0, 40.0, 40.0, 60.0],
	"monkey": [30.0, 80.0, 44.0, 40.0],
	"panda": [8.0, 22.0, 26.0, 30.0],
	"fox": [26.0, 85.0, 58.0, 56.0],
	"goat": [18.0, 70.0, 50.0, 50.0],
	"fish": [14.0, 14.0, 0.0, 36.0],
	"turtle": [7.0, 7.0, 0.0, 40.0],
	"dolphin": [30.0, 30.0, 0.0, 90.0],
}
const BUTTERFLY_COLORS := [Color(1.0, 0.85, 0.3), Color(0.55, 0.75, 1.0), Color(1.0, 0.6, 0.8), Color(1.0, 1.0, 1.0)]
const SHADOW_TEXTURE := preload("res://assets/sprites/shadow.png")

var kind := "rabbit"
var level_ref: Node
var sprite: Sprite2D
var shadow: Sprite2D
var player: Node2D
var home := Vector2.ZERO
var target := Vector2.ZERO
var state := "idle"          # idle, walk, flee, fly, gone
var timer := 0.0
var anim_time := 0.0
var altitude := 0.0          # chim / bướm bay cao bao nhiêu pixel
var fly_dir := Vector2.ZERO


func setup(critter_kind: String) -> void:
	kind = critter_kind


func _ready() -> void:
	home = position
	target = position
	timer = randf_range(0.5, 3.0)
	anim_time = randf() * 10.0
	shadow = Sprite2D.new()
	shadow.texture = SHADOW_TEXTURE
	shadow.scale = Vector2(1.2, 1.2) if kind == "deer" or kind == "camel" else Vector2(0.6, 0.6)
	shadow.position = Vector2(0, 1)
	shadow.modulate.a = 0.0 if SWIMMERS.has(kind) else 0.8
	add_child(shadow)
	sprite = Sprite2D.new()
	sprite.texture = TEXTURES[kind]
	sprite.hframes = FRAMES[kind]
	var frame_h := sprite.texture.get_height()
	sprite.offset = Vector2(0, -frame_h / 2.0 + 2.0)
	add_child(sprite)
	if kind == "butterfly":
		sprite.self_modulate = BUTTERFLY_COLORS[randi() % BUTTERFLY_COLORS.size()]
		z_index = 5   # bay phía trên mọi thứ
	if kind == "fish":
		sprite.modulate = Color(1, 1, 1, 0.75)   # cá bơi dưới mặt nước nên hơi mờ


func _process(delta: float) -> void:
	anim_time += delta
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	match kind:
		"butterfly":
			_butterfly(delta)
		"bird", "gull":
			_bird(delta)
		"duck", "fish", "turtle", "dolphin":
			_duck(delta)
		_:
			_ground_animal(delta)


func _player_near(dist: float) -> bool:
	return player != null and not player.get("is_dead") and global_position.distance_to(player.global_position) < dist


# ---------------------------------------------------------------- thỏ, nai, ếch
func _ground_animal(delta: float) -> void:
	var stats: Array = STATS[kind]
	if state != "flee" and _player_near(stats[2]):
		var away: Vector2 = (global_position - player.global_position).normalized()
		target = _free_spot(position + away.rotated(randf_range(-0.6, 0.6)) * stats[2] * 1.4)
		state = "flee"
	var moving := false
	if state == "flee" or state == "walk":
		var speed: float = stats[1] if state == "flee" else stats[0]
		moving = _step_to(target, speed, delta)
		if not moving:
			state = "idle"
			timer = randf_range(1.0, 4.0)
	else:
		timer -= delta
		if timer <= 0.0:
			state = "walk"
			target = _free_spot(home + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * stats[3])
	# khung 1 = đang nhảy / đang bước, khung 0 = đứng (nai đứng thì cúi ăn cỏ)
	if not HOPPERS.has(kind):
		sprite.frame = int(anim_time * 6.0) % 2 if moving else 0
	else:
		sprite.frame = 1 if moving and fmod(anim_time * 4.0, 1.0) < 0.6 else 0
		sprite.position.y = -absf(sin(anim_time * 12.0)) * 3.0 if moving else 0.0


## Đi tới đích, trả về false khi đã tới nơi hoặc bị vướng.
func _step_to(dest: Vector2, speed: float, delta: float) -> bool:
	if position.distance_to(dest) < 1.5:
		return false
	var dir := (dest - position).normalized()
	var next := position + dir * speed * delta
	if not _open(next):
		return false
	position = next
	sprite.flip_h = dir.x < 0.0
	return true


func _open(local_pos: Vector2) -> bool:
	if level_ref == null or not level_ref.has_method("is_open"):
		return true
	return level_ref.is_open(get_parent().to_global(local_pos), 4.0)


## Chỗ trống gần điểm muốn tới (không có thì đứng yên).
func _free_spot(want: Vector2) -> Vector2:
	for i in 6:
		var p := want.lerp(position, i / 6.0)
		if _open(p):
			return p
	return position


# ---------------------------------------------------------------- chim: mổ thóc, người tới thì bay đi rồi quay lại
func _bird(delta: float) -> void:
	match state:
		"fly":
			timer -= delta
			altitude += 40.0 * delta
			position += fly_dir * 70.0 * delta
			sprite.frame = 2 + int(anim_time * 12.0) % 2
			if timer < 0.6:
				modulate.a = maxf(timer / 0.6, 0.0)
			if timer <= 0.0:
				state = "gone"
				timer = randf_range(6.0, 12.0)
				visible = false
		"gone":
			timer -= delta
			if timer <= 0.0:
				position = _free_spot(home + Vector2(randf_range(-20, 20), randf_range(-14, 14)))
				altitude = 30.0
				visible = true
				state = "land"
		"land":
			altitude = maxf(altitude - 35.0 * delta, 0.0)
			modulate.a = minf(modulate.a + delta * 2.0, 1.0)
			sprite.frame = 2 + int(anim_time * 12.0) % 2
			if altitude <= 0.0:
				state = "idle"
		_:
			if _player_near(STATS[kind][2]):
				state = "fly"
				timer = 2.2
				fly_dir = (global_position - player.global_position).normalized().rotated(randf_range(-0.5, 0.5))
				sprite.flip_h = fly_dir.x < 0.0
			else:
				# mổ thóc: đổi khung chậm, thỉnh thoảng nhảy lò cò một chút
				sprite.frame = int(anim_time * 3.0) % 2
				timer -= delta
				if timer <= 0.0:
					timer = randf_range(1.5, 4.0)
					target = _free_spot(position + Vector2(randf_range(-10, 10), randf_range(-6, 6)))
				_step_to(target, STATS[kind][0], delta)
	sprite.position.y = -altitude
	shadow.scale = Vector2.ONE * clampf(0.6 - altitude * 0.01, 0.2, 0.6)


# ---------------------------------------------------------------- bướm: bay lượn quanh một chỗ
func _butterfly(_delta: float) -> void:
	var r: float = STATS["butterfly"][3]
	position = home + Vector2(sin(anim_time * 0.7) * r, sin(anim_time * 1.1 + 1.0) * r * 0.6)
	sprite.frame = int(anim_time * 10.0) % 2
	altitude = 10.0 + sin(anim_time * 3.0) * 3.0
	sprite.position.y = -altitude
	sprite.flip_h = cos(anim_time * 0.7) < 0.0
	shadow.scale = Vector2(0.3, 0.3)


# ---------------------------------------------------------------- vịt: bơi chậm trên mặt nước
func _duck(delta: float) -> void:
	if kind == "dolphin" and _dolphin_jump(delta):
		return
	sprite.frame = int(anim_time * (4.0 if kind == "fish" else 2.0)) % 2
	if state == "walk":
		if position.distance_to(target) < 1.5:
			state = "idle"
			timer = randf_range(2.0, 5.0)
			return
		var dir := (target - position).normalized()
		var swim_speed: float = STATS[kind][0]
		var next: Vector2 = position + dir * swim_speed * delta
		if not _water(next):
			state = "idle"
			timer = 1.0
			return
		position = next
		sprite.flip_h = dir.x < 0.0
	else:
		timer -= delta
		if timer <= 0.0:
			var radius: float = STATS[kind][3]
			var want: Vector2 = home + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * radius
			if _water(want):
				target = want
				state = "walk"
			else:
				timer = 0.5


## Cá heo thỉnh thoảng nhảy vọt lên khỏi mặt nước. Trả về true khi đang nhảy.
func _dolphin_jump(delta: float) -> bool:
	if state == "jump":
		timer -= delta
		var t := 1.0 - timer / 1.1
		altitude = sin(t * PI) * 14.0
		sprite.frame = 2 if t < 0.5 else 3
		position.x += (-1.0 if sprite.flip_h else 1.0) * 26.0 * delta
		sprite.position.y = -altitude
		if timer <= 0.0 or not _water(position):
			state = "idle"
			timer = randf_range(1.0, 3.0)
			altitude = 0.0
			sprite.position.y = 0.0
			Game.burst(global_position, Color(0.85, 0.95, 1.0), 6, 30.0, 40.0, 0.4, 1.4)   # bọt nước
		return true
	if state == "idle" and randf() < delta * 0.12 and _water(position + Vector2(-30.0 if sprite.flip_h else 30.0, 0)):
		state = "jump"
		timer = 1.1
		return true
	return false


func _water(local_pos: Vector2) -> bool:
	if level_ref == null or not level_ref.has_method("is_water"):
		return true
	var g: Vector2 = get_parent().to_global(local_pos)
	for o in [Vector2.ZERO, Vector2(7, 0), Vector2(-7, 0), Vector2(0, 6), Vector2(0, -6)]:
		if not level_ref.is_water(g + o):
			return false
	return true
