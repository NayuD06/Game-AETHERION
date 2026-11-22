class_name DungeonTrap
extends Node2D
## Bẫy trong hầm ngục (do level.gd đặt theo bản đồ chữ trong scripts/dungeon.gd):
##   "spike": bẫy gai '9'. Gai nhú lên (báo trước) rồi đâm lên, sau đó thụt xuống.
##   "vent":  lỗ phun lửa '/'. Lỗ đỏ lên (báo trước) rồi phun cột lửa.
## Bẫy chạy theo chu kỳ, mỗi bẫy lệch thời gian một chút (phase) để tạo thành "sóng" gai / lửa.
## Đang lướt (F) qua bẫy thì không bị trúng.

const SPIKE_TEX := preload("res://assets/dungeon/spikes.png")
const VENT_TEX := preload("res://assets/dungeon/vent.png")
const FLAME_TEX := preload("res://assets/dungeon/flame.png")

var kind := "spike"
var damage := 8
var period := 2.2        # một vòng (giây)
var warn_time := 0.45    # thời gian báo trước
var active_time := 0.55  # thời gian gai đâm / lửa phun
var phase := 0.0         # lệch thời gian so với các bẫy khác
var light: PointLight2D  # đèn của lỗ phun lửa (level.gd tạo, sáng lên khi phun)

var time := 0.0
var state := 0           # 0 = nghỉ, 1 = báo trước, 2 = tấn công
var hit_done := false    # vòng này đã trúng người chơi chưa
var sprite: Sprite2D
var flame: Sprite2D
var player: Player


func setup(trap_kind: String, trap_damage: int, trap_phase: float) -> void:
	kind = trap_kind
	damage = trap_damage
	phase = trap_phase
	if kind == "vent":
		period = 3.0
		warn_time = 0.8
		active_time = 0.7


func _ready() -> void:
	z_index = -9   # nằm trên sàn, dưới nhân vật
	sprite = Sprite2D.new()
	sprite.texture = SPIKE_TEX if kind == "spike" else VENT_TEX
	sprite.hframes = 3 if kind == "spike" else 2
	add_child(sprite)
	if kind == "vent":
		flame = Sprite2D.new()
		flame.texture = FLAME_TEX
		flame.hframes = 4
		flame.centered = false
		flame.offset = Vector2(-8, -30)
		flame.z_as_relative = false
		flame.z_index = 2   # vẽ đè lên nhân vật
		var glow := CanvasItemMaterial.new()
		glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glow.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		flame.material = glow
		flame.visible = false
		add_child(flame)


func _process(delta: float) -> void:
	time += delta
	var t := fposmod(time + phase, period)
	var new_state := 0
	if t >= period - active_time:
		new_state = 2
	elif t >= period - active_time - warn_time:
		new_state = 1
	if new_state != state:
		state = new_state
		hit_done = false
		_on_state_changed()
	if state == 2 and kind == "vent":
		flame.frame = int(time * 14.0) % 4
		flame.scale.y = clampf((t - (period - active_time)) / 0.12, 0.2, 1.0)
	if state == 2 and not hit_done:
		_try_hit()


func _on_state_changed() -> void:
	if kind == "spike":
		sprite.frame = state   # 0 lỗ, 1 nhú, 2 đâm lên
		return
	sprite.frame = 1 if state >= 1 else 0
	flame.visible = state == 2
	if light:
		light.energy = [0.0, 0.5, 1.4][state]
	if state == 2 and _player_near(160.0):
		Game.burst(global_position + Vector2(0, -6), Color(1.0, 0.55, 0.15), 8, 50.0, 70.0, 0.4, 1.5)


func _try_hit() -> void:
	var reach := 10.0 if kind == "spike" else 11.0
	if not _player_near(reach):
		return
	hit_done = true
	if player.take_damage(damage):
		Game.popup_text(player.global_position + Vector2(0, -14), "Bẫy gai!" if kind == "spike" else "Bỏng!",
			Color(1.0, 0.6, 0.4), 8)


func _player_near(dist: float) -> bool:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Player
	return player != null and not player.is_dead and player.global_position.distance_to(global_position) <= dist
