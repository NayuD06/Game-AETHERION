class_name Demo
extends Node
## Chế độ QUAY VIDEO: game tự chơi một cảnh ngắn để làm video / ảnh GIF giới thiệu (doc/README.md).
## Bình thường KHÔNG chạy. Chỉ chạy khi mở game bằng dòng lệnh có thêm  -- --demo=<tên cảnh>, ví dụ:
##   godot --path . --write-movie _video/lang.avi --fixed-fps 30 -- --demo=lang
## (--write-movie là Movie Maker của Godot: ghi lại từng khung hình ra file video.)
##
## Các cảnh (SCENES):
##   tao_nhan_vat  màn hình tạo nhân vật          lang      đi quanh làng, chế tạo, mua đồ, mặc trang bị
##   kiem / cung / giao  đánh quái bằng Kiếm / Cung / Thương, tung đủ 4 kỹ năng Q W E R
##   ham_nguc      đi qua 4 tầng hầm ngục (bẫy gai, đầm độc, mê cung tối, dung nham)
##   ruong         hạ hết quái trên tầng, rương mở khoá, mở rương nhặt đồ
##   boss          đánh Boss Malakar ở tầng 5
## Trong lúc quay: nhân vật tự đi, tự đánh, tự tung chiêu; chuột và bàn phím thật bị bỏ qua;
## máu không tụt dưới 35% (không chết giữa video). Quay xong cảnh thì game tự tắt.
## Nhân vật của bạn (user://nhan_vat.cfg) không bị đổi: cảnh quay chỉ mượn ngoại hình, không lưu lại.

const SCENES := ["tao_nhan_vat", "lang", "kiem", "cung", "giao", "ham_nguc", "ruong", "boss"]
const COMBAT_SPOT := Vector2i(47, 47)   # khoảng đất trống trong Rừng Hoang (ô trên bản đồ thế giới)
const BOSS_FIGHT := 13.0                 # đánh Boss khoảng bao nhiêu giây

var scene_name := ""
var level: Level
var hud: GameHUD
var player: Player
var creator: Control            # màn hình tạo nhân vật (chỉ cảnh tao_nhan_vat)
var caption_box: PanelContainer # dòng chú thích góc trên bên phải
var caption: Label


## Tên cảnh được yêu cầu trên dòng lệnh (--demo=...), "" = chơi bình thường.
static func requested() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--demo="):
			return arg.substr(7).strip_edges()
	return ""


## Gọi trước khi vào màn chơi: chọn vũ khí cho cảnh quay (chỉ trong bộ nhớ, không lưu lại).
static func prepare(scene: String) -> void:
	var weapon := 0   # chỉ số trong Weapons.ORDER: 0 Kiếm, 1 Thương, 2 Cung, 3 Sách phép
	if scene == "giao":
		weapon = 1
	elif scene == "cung":
		weapon = 2
	Game.appearance["weapon"] = weapon
	Game.appearance["name"] = "Lữ Khách"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	scene_name = requested()
	var parent := get_parent()
	if parent is Control:
		creator = parent as Control
	else:
		level = parent.get("level") as Level
		hud = parent.get("hud") as GameHUD
	_build_caption()
	get_viewport().gui_disable_input = true   # chuột thật không bấm được vào giao diện lúc quay
	_run.call_deferred()


func _process(_delta: float) -> void:
	if player != null and is_instance_valid(player):
		player.mp = player.max_mp


func _run() -> void:
	await get_tree().process_frame
	if not SCENES.has(scene_name):
		push_warning("Không có cảnh quay tên '%s'. Các cảnh: %s" % [scene_name, ", ".join(SCENES)])
	if creator != null:
		await _scene_creator()
	elif level != null and level.player != null:
		player = level.player
		player.demo_mode = true
		if scene_name != "lang":
			level.fade_rect.color.a = 1.0   # bắt đầu từ màn đen, sáng dần ở chỗ quay
		match scene_name:
			"lang":
				await _scene_village()
			"kiem", "cung", "giao":
				await _scene_weapon()
			"ham_nguc":
				await _scene_dungeon()
			"ruong":
				await _scene_chest()
			"boss":
				await _scene_boss()
			_:
				await _wait(2.0)
	await _wait(0.5)
	get_tree().quit()


# ================================================================ Các cảnh quay

func _scene_creator() -> void:
	_say("Tạo nhân vật: đặt tên, chọn vũ khí và ngoại hình")
	var edit := creator.get("name_edit") as LineEdit
	if edit != null:
		edit.text = ""
		await _wait(0.4)
		for ch in "Lữ Khách":
			edit.text += ch
			await _wait(0.09)
	await _wait(0.6)
	_say("Chọn vũ khí (cố định): Kiếm, Thương, Cung, Sách phép")
	for i in 3:
		creator.call("_change", "weapon", 1)
		await _wait(1.0)
	_say("Đổi màu da, kiểu tóc, màu tóc, trang phục, mũ")
	for i in 5:
		creator.call("_randomize")
		await _wait(0.75)
	await _wait(0.4)


func _scene_village() -> void:
	player.gold = 180
	player.add_item("hide", 4)
	player.add_item("rope", 3)
	player.add_item("wood", 3)
	player.add_item("bone", 2)
	_say("Làng Khởi Nguyên: chuột phải để đi (kiểu LMHT)")
	await _wait(1.4)
	var bench := _station_pos("bench")
	if bench != Vector2.INF:
		await _walk(bench + Vector2(0, 18))
	_say("Đứng gần bàn chế tạo là bảng chế tạo tự mở")
	await _wait(1.2)
	var recipe := _recipe_for("armor_1")
	if not recipe.is_empty():
		hud._on_craft_pressed(recipe)   # làm Áo giáp da
	await _wait(1.4)
	var smith := _npc_with_shop("smith")
	if smith != null:
		await _walk(smith.global_position + Vector2(0, 18))
	_say("Thợ rèn Bác Sắt: mua, bán và sửa trang bị")
	await _wait(1.2)
	hud._on_shop_buy("helmet_1")
	await _wait(0.9)
	hud._on_shop_buy("boots_1")
	await _wait(0.9)
	hud._on_shop_tab("sell")
	await _wait(1.1)
	hud._on_shop_tab("repair")
	await _wait(1.1)
	hud._on_shop_tab("buy")
	_say("Túi đồ (B): bấm vào trang bị là mặc lên người")
	_show_bag(true)
	await _wait(0.8)
	for id in ["armor_1", "helmet_1", "boots_1"]:
		var index := _bag_index(id)
		if index != -1:
			player.equip_bag_slot(index)
			await _wait(0.7)
	await _wait(1.4)
	_show_bag(false)
	_say("Đi về phía đông là tới Rừng Hoang")
	await _walk(_world_cell(33, 46), 3.0)
	await _wait(0.6)


func _scene_weapon() -> void:
	_set_level(20)
	player.attack += 6
	_give_gear(2)
	var center := _world_cell(COMBAT_SPOT.x, COMBAT_SPOT.y)
	player.teleport_to(center)
	await _wait(0.1)
	_quiet_messages("")
	level.create_tween().tween_property(level.fade_rect, "color:a", 0.0, 0.4)
	_spawn_pack(center, ["s", "X", "s", "N", "X", "s"], 58.0)
	var wname: String = Weapons.info(player.weapon)["name"]
	_say("%s: chuột phải vào quái để tự đánh" % wname)
	await _fight(2.2)
	for slot in 4:
		await _cast(slot)
		await _fight(1.5 if slot < 3 else 2.4)
	await _cast(0)
	await _fight(1.4)


func _scene_dungeon() -> void:
	_set_level(22)
	player.attack += 8
	_give_gear(3)
	player.add_item("torch")   # có đuốc: vòng sáng quanh người to hơn
	# Tầng 1: bẫy gai trên lối đi giữa hai phòng
	await _goto_floor(1, Vector2i(9, 17))
	_say("Hầm Ngục Cổ - Tầng 1: bẫy gai dưới sàn")
	await _walk(_floor_cell(1, 21, 17), 4.0)
	await _wait(0.4)
	# Tầng 2: đầm độc
	await _goto_floor(2, Vector2i(29, 8))
	_say("Tầng 2 - Hang Nấm Độc: đầm độc làm đi chậm và mất máu")
	await _walk(_floor_cell(2, 44, 8), 4.5)
	await _wait(0.3)
	# Tầng 3: mê cung tối, thắp bia cổ ngữ
	await _goto_floor(3, Vector2i(40, 4))
	_say("Tầng 3 - Mê Cung Bóng Tối: thắp sáng bia cổ ngữ")
	await _walk(_floor_cell(3, 48, 3), 3.0)
	await _wait(1.4)
	# Tầng 4: sông dung nham, lỗ phun lửa
	await _goto_floor(4, Vector2i(5, 6))
	_say("Tầng 4 - Lò Rèn Dung Nham: sông dung nham, lỗ phun lửa")
	await _walk(_floor_cell(4, 12, 8), 2.5)
	await _walk(_floor_cell(4, 20, 7), 3.0)
	await _wait(0.6)


func _scene_chest() -> void:
	_set_level(18)
	player.attack += 4
	# Phòng dưới cùng bên phải của Tầng 1 (có một rương ở ô 37, 26)
	var chest := _chest_near(_floor_cell(1, 37, 26))
	if chest != null:
		_retier(chest, "gold")
	# Cho video ngắn: bỏ bớt quái ở các phòng khác, chỉ để lại quái trong phòng này
	var room := Rect2(_floor_cell(1, 18, 21) - Vector2(8, 8), Vector2(24 * Level.TILE, 7 * Level.TILE))
	var keep := 0
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or level.floor_of(enemy.global_position) != 1:
			continue
		if room.has_point(enemy.global_position):
			keep += 1
		else:
			enemy.remove_from_group("enemies")
			enemy.queue_free()
	level.floor_alive[1] = keep
	await _goto_floor(1, Vector2i(30, 22))
	_say("Rương báu trong hầm ngục bị KHOÁ")
	await _walk(_floor_cell(1, 36, 26), 2.5)   # đứng sát rương: hiện chữ "Khoá!"
	await _wait(1.0)
	_say("Hạ hết quái trên tầng thì rương mở khoá")
	await _fight_until_clear(1, 10.0)
	await _wait(1.4)
	if chest != null:
		_say("Mở rương: trang bị, nguyên liệu, vàng, bình máu")
		await _walk(chest.global_position + Vector2(0, 8), 3.0, false)
		await _wait(0.9)
		# Đi vòng quanh rương nhặt đồ (trang bị mới tự mặc vào ô còn trống)
		for offset in [Vector2(-18, 6), Vector2(-6, 18), Vector2(14, 12), Vector2(0, 4)]:
			await _walk(chest.global_position + offset, 1.0, false)
	await _wait(0.6)
	_say("Trang bị nhặt được tự mặc vào ô còn trống")
	_show_bag(true)
	await _wait(2.6)


func _scene_boss() -> void:
	_set_level(30)
	_give_gear(5)
	player.hp = player.max_hp
	var boss: Enemy = null
	for node in get_tree().get_nodes_in_group("boss"):
		var e := node as Enemy
		if e != null and level.floor_of(e.global_position) == 5:
			boss = e
	await _goto_floor(5, Vector2i(28, 21))
	_say("Tầng 5: Boss Malakar, Vua Xương Bất Tử")
	await _walk(_floor_cell(5, 28, 17), 2.0)
	if boss == null:
		await _fight(6.0)
		return
	# Đánh Boss khoảng BOSS_FIGHT giây (tăng sức đánh nếu chậm quá để video không dài)
	var t := 0.0
	var next_cast := 0.4
	var next_check := 0.5
	var order := [0, 2, 1, 3, 0, 2, 1, 0, 2, 3, 1, 0]
	var step := 0
	while t < BOSS_FIGHT + 6.0 and is_instance_valid(boss) and not boss.is_dead:
		if player.attack_target == null or not is_instance_valid(player.attack_target):
			player.attack_target = boss
		if t >= next_cast and player.skill_busy <= 0.0 and player.dash_timer <= 0.0:
			next_cast = t + 1.25
			var slot: int = order[step % order.size()]
			step += 1
			_say_skill(slot)
			player.demo_cast(slot, boss.global_position)
		if t >= next_check:
			next_check = t + 0.5
			var want := clampf(1.0 - t / BOSS_FIGHT, 0.04, 1.0)
			var have := float(boss.hp) / float(maxi(boss.max_hp, 1))
			if have > want + 0.08:
				player.attack = mini(int(player.attack * 1.2) + 1, 400)
			elif have < want - 0.15:
				player.attack = maxi(int(player.attack * 0.85), 10)
			if t > BOSS_FIGHT + 3.0:
				boss.take_damage(boss.hp + boss.armor + 1)
		await get_tree().process_frame
		t += get_process_delta_time()
	_say("Hạ Malakar: rơi Rương kim cương, Cổng Xoáy mở ra")
	player.attack_target = null
	await _wait(1.6)
	var chest := _chest_near(player.global_position, 200.0)
	if chest != null:
		await _walk(chest.global_position + Vector2(0, 8), 3.0, false)
		await _wait(0.8)
		for offset in [Vector2(-16, 8), Vector2(12, 14), Vector2(0, 4)]:
			await _walk(chest.global_position + offset, 1.0, false)
	await _wait(1.4)


# ================================================================ Điều khiển nhân vật

## Đi tới pos (tìm đường như bấm chuột phải). Đợi tới nơi, tối đa max_time giây.
func _walk(pos: Vector2, max_time: float = 6.0, marker: bool = true) -> void:
	player.command_move(pos, marker)
	var t := 0.0
	var retry := 0.5
	while t < max_time and player.global_position.distance_to(pos) > 5.0:
		await get_tree().process_frame
		var delta := get_process_delta_time()
		t += delta
		retry -= delta
		if retry <= 0.0 and player.path_index >= player.path.size():
			retry = 0.5
			player.command_move(pos, false)   # bị quái chắn đường: đi lại


## Đánh thường quái gần nhất (giống bấm chuột phải vào quái) trong seconds giây.
func _fight(seconds: float, radius: float = 170.0) -> void:
	var t := 0.0
	while t < seconds:
		_keep_target(radius)
		await get_tree().process_frame
		t += get_process_delta_time()


## Đánh tới khi tầng fl hết quái (tối đa max_time giây), xen kẽ tung kỹ năng.
func _fight_until_clear(fl: int, max_time: float) -> void:
	var t := 0.0
	var next_cast := 0.8
	var slot := 0
	while t < max_time and level.floor_enemies_left(fl) > 0:
		_keep_target(400.0)
		if t >= next_cast and player.skill_busy <= 0.0 and player.dash_timer <= 0.0 and _nearest(70.0) != null:
			next_cast = t + 1.6
			player.demo_cast(slot, _aim_point())
			slot = (slot + 1) % 3
		await get_tree().process_frame
		t += get_process_delta_time()
	# Còn sót con nào chạy xa thì hạ nốt cho video khỏi dài
	if level.floor_enemies_left(fl) > 0:
		for node in get_tree().get_nodes_in_group("enemies"):
			var enemy := node as Enemy
			if enemy != null and not enemy.is_dead and level.floor_of(enemy.global_position) == fl:
				enemy.take_damage(99999)
	player.attack_target = null


func _keep_target(radius: float) -> void:
	var target := player.attack_target
	if target == null or not is_instance_valid(target) or target.is_dead:
		var e := _nearest(radius)
		if e != null:
			player.attack_target = e


## Tung kỹ năng ở ô slot (0 = Q, 1 = W, 2 = E, 3 = R) về phía đám quái gần nhất.
func _cast(slot: int) -> void:
	var t := 0.0
	while (player.skill_busy > 0.0 or player.dash_timer > 0.0 or player.cutscene_time > 0.0) and t < 2.5:
		await get_tree().process_frame
		t += get_process_delta_time()
	_say_skill(slot)
	player.demo_cast(slot, _aim_point())


## Điểm ngắm: giữa đám quái quanh con gần nhất (không có quái thì phía trước mặt).
func _aim_point() -> Vector2:
	var first := _nearest(220.0)
	if first == null:
		return player.global_position + player.facing * 40.0
	var sum := Vector2.ZERO
	var count := 0
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy != null and not enemy.is_dead and enemy.global_position.distance_to(first.global_position) < 50.0:
			sum += enemy.global_position
			count += 1
	return sum / float(count) if count > 0 else first.global_position


func _nearest(radius: float) -> Enemy:
	var best: Enemy = null
	var best_dist := radius
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.is_dead or enemy.display_name.begins_with("Bù nhìn"):
			continue
		var d := enemy.global_position.distance_to(player.global_position)
		if d < best_dist:
			best = enemy
			best_dist = d
	return best


## Lên thẳng cấp lv (không hiện chữ LÊN CẤP nhiều lần).
func _set_level(lv: int) -> void:
	while player.level < lv:
		player.level += 1
		player.max_hp += Player.LEVEL_HP
		player.max_mp += 3
		player.attack += Player.LEVEL_ATTACK
	player.xp = 0
	player.xp_to_next = Player.xp_needed(player.level)
	player.hp = player.max_hp
	player.mp = player.max_mp
	player.skills_changed.emit()


## Mặc đủ bộ trang bị bậc tier (1 = Da ... 5 = Bóng Đêm).
func _give_gear(tier: int) -> void:
	for slot in Equipment.SLOTS:
		player.gear[slot] = Equipment.make("%s_%d" % [slot, tier])
	player._apply_gear()
	player.hp = player.max_hp
	player.gear_changed.emit()


## Qua cầu thang sang tầng fl của hầm ngục, đứng ở ô c (toạ độ trong bản đồ tầng, scripts/dungeon.gd).
func _goto_floor(fl: int, c: Vector2i) -> void:
	var dest := _floor_cell(fl, c.x, c.y)
	level._go_through_cave(level.to_local(dest), Dungeon.floor_name(fl), fl)
	await _wait(1.0)
	_quiet_messages("")
	Game.message.emit(Dungeon.FLOORS[fl - 1]["message"])


func _spawn_pack(center: Vector2, kinds: Array, dist: float) -> void:
	for i in kinds.size():
		var scene: PackedScene = Level.ENEMY_SCENES.get(kinds[i])
		if scene == null:
			continue
		var enemy := scene.instantiate() as Enemy
		var pos := center + Vector2(dist, 0)
		for tries in 24:
			var angle := TAU * float(i) / float(kinds.size()) + float(tries) * 0.45
			var p := center + Vector2.RIGHT.rotated(angle) * (dist + float(tries % 4) * 6.0)
			if level.is_open(p, 8.0):
				pos = p
				break
		enemy.position = level.to_local(pos)
		level.entities.add_child(enemy)
		Game.burst(pos, Color(0.8, 0.8, 0.9), 6, 30.0)


# ================================================================ Tìm đồ vật trong màn chơi

func _world_cell(x: int, y: int) -> Vector2:
	return level.to_global(Vector2(x + 0.5, y + 0.5) * Level.TILE)


func _floor_cell(fl: int, x: int, y: int) -> Vector2:
	var origin := level.floor_rects[fl - 1].position
	return _world_cell(origin.x + x, origin.y + y)


func _station_pos(kind: String) -> Vector2:
	for st in level.stations:
		if st["kind"] == kind:
			return level.to_global(st["pos"])
	return Vector2.INF


func _npc_with_shop(shop: String) -> Node2D:
	for node in level.entities.get_children():
		var value: Variant = node.get("shop")
		if value is String and value == shop:
			return node as Node2D
	return null


func _recipe_for(gives: String) -> Dictionary:
	for recipe in Recipes.LIST:
		if str(recipe.get("gives", "")) == gives:
			return recipe
	return {}


func _bag_index(id: String) -> int:
	for i in player.bag.size():
		if player.bag[i]["id"] == id:
			return i
	return -1


func _chest_near(pos: Vector2, radius: float = 40.0) -> Chest:
	var best: Chest = null
	var best_dist := radius
	for node in get_tree().get_nodes_in_group("chests"):
		var chest := node as Chest
		if chest == null or chest.opened:
			continue
		var d := chest.global_position.distance_to(pos)
		if d < best_dist:
			best = chest
			best_dist = d
	return best


func _retier(chest: Chest, tier: String) -> void:
	chest.tier = tier
	chest.sprite.texture = Chest.TIERS[tier]["texture"]
	chest._update_look()


# ================================================================ Chữ trên màn hình

func _show_bag(on: bool) -> void:
	hud.bag_panel.visible = on
	hud.equip_panel.visible = on
	hud._refresh_bag()


## Xoá các thông báo đang chờ (cảnh quay nhảy thẳng tới chỗ khác). area_name != "" thì hiện tên khu.
func _quiet_messages(area_name: String) -> void:
	hud.message_queue.clear()
	hud.message_label.text = ""
	hud.message_timer = 0.0
	if area_name != "":
		hud.show_area_title(area_name)


func _say_skill(slot: int) -> void:
	var s := player.slot_skill(slot)
	var wname: String = Weapons.info(player.weapon)["name"]
	_say("%s - %s: %s" % [wname, Skills.SLOT_KEYS[slot], s.get("name", "")])


func _say(text: String) -> void:
	caption.text = text
	caption_box.visible = text != ""
	caption_box.modulate.a = 0.0
	create_tween().tween_property(caption_box, "modulate:a", 1.0, 0.2)


func _build_caption() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 25   # trên cả màn đen chuyển cảnh
	add_child(layer)
	caption_box = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.05, 0.1, 0.8)
	sb.border_color = Color(1.0, 0.82, 0.45, 0.9)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 7.0
	sb.content_margin_right = 7.0
	sb.content_margin_top = 2.0
	sb.content_margin_bottom = 3.0
	caption_box.add_theme_stylebox_override("panel", sb)
	caption_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption_box.visible = false
	layer.add_child(caption_box)
	caption = Label.new()
	caption.add_theme_font_size_override("font_size", 10)
	caption.add_theme_color_override("font_color", Color(1.0, 0.95, 0.82))
	caption.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	caption.add_theme_constant_override("outline_size", 3)
	caption_box.add_child(caption)
	caption_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 6)
	caption_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
