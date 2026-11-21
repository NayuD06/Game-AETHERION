extends Node2D
## Cây thu hoạch được (bụi quả mọng, thảo dược, nấm, lúa mì, cà rốt, bí ngô, cây táo).
## Cây lớn dần qua từng khung hình trong ảnh (khung cuối = chín).
## Khi chín, người chơi đi tới gần (hoặc chuột phải vào cây) là tự hái, đồ vào túi (phím B).
## Hái xong cây quay về khung đầu và tự lớn lại sau grow_time giây.
## Thông số từng loại cây nằm trong HARVEST ở scripts/level.gd.

var item_id := "berry"
var frames := 2
var grow_time := 60.0        # thời gian từ lúc hái tới lúc chín lại (giây)
var amount_min := 1
var amount_max := 1
var reach := 14.0            # đứng gần bao nhiêu pixel thì hái được
var sway := true             # cây nhỏ đung đưa nhẹ khi chín
var tool := ""               # cần công cụ này trong túi mới thu hoạch được (gốc cây cần "axe" = Rìu)

var stage := 0
var timer := 0.0
var sprite: Sprite2D
var player: Node2D
var anim_time := 0.0
var full_msg_cd := 0.0


func setup(data: Dictionary) -> void:
	item_id = data.get("item", item_id)
	frames = int(data.get("frames", frames))
	grow_time = float(data.get("grow", grow_time))
	var amount: Array = data.get("amount", [1, 1])
	amount_min = int(amount[0])
	amount_max = int(amount[1])
	reach = float(data.get("reach", reach))
	sway = not data.get("tree", false)
	tool = str(data.get("tool", ""))
	sprite = Sprite2D.new()
	sprite.texture = data["tex"]
	sprite.hframes = frames
	sprite.centered = false
	sprite.offset = Vector2(-sprite.texture.get_width() / float(frames) / 2.0, -sprite.texture.get_height())
	add_child(sprite)
	# Lúc đầu phần lớn cây đã chín, một ít đang lớn cho tự nhiên
	if randf() < float(data.get("start_ripe", 1.0)):
		stage = frames - 1
	else:
		stage = randi() % (frames - 1)
		timer = randf() * _stage_time()
	sprite.frame = stage
	anim_time = randf() * TAU


func _process(delta: float) -> void:
	anim_time += delta
	full_msg_cd = maxf(full_msg_cd - delta, 0.0)
	if stage < frames - 1:
		timer += delta
		if timer >= _stage_time():
			timer = 0.0
			stage += 1
			sprite.frame = stage
			_pop()
		sprite.rotation = 0.0
		return
	if sway:
		sprite.rotation = sin(anim_time * 2.0) * 0.05
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
		return
	if player.get("is_dead"):
		return
	var center := global_position + Vector2(0, -8)
	if player.global_position.distance_to(center) < reach:
		_harvest()


func _stage_time() -> float:
	return grow_time / float(maxi(frames - 1, 1))


func _harvest() -> void:
	if tool != "" and player.count_item(tool) <= 0:
		if full_msg_cd <= 0.0:
			full_msg_cd = 6.0
			var tool_name: String = Items.info(tool).get("name", tool)
			Game.popup_text(global_position + Vector2(0, -20), "Cần %s" % tool_name, Color(0.9, 0.85, 0.7), 8)
		return
	var amount := randi_range(amount_min, amount_max)
	# Có Liềm trong túi: hái cây được thêm 1 (không tính nước, gỗ)
	if tool == "" and item_id != "water" and player.count_item("sickle") > 0:
		amount += 1
	if not player.add_item(item_id, amount):
		if full_msg_cd <= 0.0:
			full_msg_cd = 3.0
			Game.popup_text(global_position + Vector2(0, -20), "Túi đầy!", Color(1.0, 0.6, 0.5), 9)
		return
	var item_name: String = Items.info(item_id).get("name", item_id)
	Game.popup_text(global_position + Vector2(0, -18), "+%d %s" % [amount, item_name], Color(0.75, 1.0, 0.6), 9)
	Game.burst(global_position + Vector2(0, -8), Color(0.6, 0.9, 0.4), 6, 40.0, 60.0, 0.4, 1.5)
	stage = 0
	timer = 0.0
	sprite.frame = 0
	sprite.rotation = 0.0
	_pop()


## Nảy hình nhẹ khi đổi khung (vừa hái / vừa lớn thêm).
func _pop() -> void:
	sprite.scale = Vector2(1.15, 0.85)
	var tw := create_tween()
	tw.tween_property(sprite, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
