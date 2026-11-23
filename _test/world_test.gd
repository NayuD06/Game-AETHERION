extends Node
## Chạy thử thế giới lớn: save cũ, đi khắp các vùng, thuyền, câu cá, lưu / nạp bản đồ khám phá.

var main: Node
var errors := 0


func _ready() -> void:
	await get_tree().process_frame
	Accounts.setup()
	# 1) Save kiểu cũ (trước khi mở rộng): chỗ đứng theo toạ độ bản đồ cũ
	var look := CharacterParts.DEFAULT.duplicate()
	look["name"] = "_thu_the_gioi_"
	look["weapon"] = 1
	var old_pos := Vector2(15.5, 50.5) * 16.0 + Vector2(32, 0)
	var tid := Accounts.create(look, { "tien_do": { "level": 12, "gold": 500 }, "the_gioi": { "gate_open": false, "pos": old_pos, "floor": 0, "fires": [old_pos + Vector2(40, 0)] } })
	Game.use_account(tid)
	var t0 := Time.get_ticks_msec()
	await _start_main()
	print("LOAD_MS ", Time.get_ticks_msec() - t0)
	var lv: Level = main.level
	var p: Player = lv.player
	print("MAP size=", lv.map_size, " overworld=", lv.overworld_size, " floors=", lv.floor_rects.size(), " dungeon_col=", lv.dungeon_column)
	print("PLAYER pos cell=", Vector2i(p.position / 16.0), " want=", Vector2i(old_pos / 16.0) + WorldMap.CORE.position)
	_check(lv.map_size == Vector2i(514, 288), "kích thước bản đồ")
	_check(Vector2i(p.position / 16.0) == Vector2i(old_pos / 16.0) + WorldMap.CORE.position, "save cũ chuyển sang toạ độ mới")
	_check(lv.chunks.size() > 0, "có vùng đất được dựng quanh người chơi")
	print("COUNTS sleepers=", lv.sleepers.size(), " signs=", lv.signs.size(), " stations=", lv.stations.size(), " chests=", lv.chests.size(), " chunks=", lv.chunks.size())
	print("NPC check: ", _npc_names(lv))
	print("FOG explored=", _explored(lv), " arena=", lv.arena_rect)
	print("FIRES placed=", lv.placed_fires)
	# 2) Đi khắp các làng
	var spots := { "Làng Chài": Vector2i(37, 141), "Làng Tuyết": Vector2i(49, 36), "Làng Hoa Đào": Vector2i(278, 53),
		"Làng Tre": Vector2i(287, 147), "Ốc Đảo": Vector2i(176, 248), "Tàn Tích": Vector2i(288, 228), "Đảo Nấm": Vector2i(46, 238) }
	for name in spots:
		var c: Vector2i = spots[name]
		var at := _open_near(lv, c)
		var t1 := Time.get_ticks_usec()
		p.teleport_to(lv.to_global(at))
		await get_tree().process_frame
		var first := (Time.get_ticks_usec() - t1) / 1000.0
		var worst := 0.0
		for i in 30:
			var t2 := Time.get_ticks_usec()
			await get_tree().process_frame
			worst = maxf(worst, (Time.get_ticks_usec() - t2) / 1000.0)
		_check(lv._current_area_name().begins_with(name), "tới được " + name)
		print("VISIT %s cell=%s area=%s first_ms=%.1f worst_ms=%.1f chunks=%d awake=%d weather=%s" % [name, str(Vector2i(at / 16.0)), lv._current_area_name(), first, worst, lv.chunks.size(), _awake(lv), lv.weather_kind])
	# 3) Thuyền
	p.teleport_to(lv.to_global(Vector2(30.5, 141.5) * 16.0))
	for i in 5:
		await get_tree().process_frame
	print("NO BOAT on water -> pos cell=", Vector2i(p.position / 16.0), " on_boat=", p.on_boat)
	_check(not p.on_boat, "chưa có thuyền thì không đi trên nước")
	p.add_item("boat")
	p.add_item("fishing_rod")
	p.teleport_to(lv.to_global(Vector2(10.5, 141.5) * 16.0))
	for i in 5:
		await get_tree().process_frame
	print("BOAT pos=", Vector2i(p.position / 16.0), " on_boat=", p.on_boat, " mask=", p.collision_mask)
	_check(p.on_boat, "có thuyền thì đi được trên biển")
	p.command_move(lv.to_global(Vector2(5.5, 120.5) * 16.0), false)
	for i in 120:
		await get_tree().physics_frame
	print("BOAT after move pos=", Vector2i(p.position / 16.0), " path=", p.path.size(), " on_boat=", p.on_boat)
	# đi bộ từ biển lên bờ bằng đường tìm được
	p.command_move(lv.to_global(Vector2(30.5, 141.5) * 16.0), false)
	for i in 400:
		await get_tree().physics_frame
	print("BOAT back to shore pos=", Vector2i(p.position / 16.0), " on_boat=", p.on_boat)
	_check(not p.on_boat, "lên bờ thì cất thuyền")
	# 4) Câu cá: đứng cạnh chỗ câu cá ở hồ / biển
	var fish_before := p.count_item("fish") + p.count_item("shrimp") + p.count_item("big_fish") + p.count_item("pearl")
	p.teleport_to(lv.to_global(Vector2(21.5, 137.5) * 16.0))
	for i in 20:
		await get_tree().process_frame
	var fish_after := p.count_item("fish") + p.count_item("shrimp") + p.count_item("big_fish") + p.count_item("pearl")
	print("FISHING got=", fish_after - fish_before, " pos=", Vector2i(p.position / 16.0))
	# 5) Lưu rồi nạp lại
	var explored_before := _explored(lv)
	main.save_game(false)
	var saved := Accounts.read(tid)
	var w: Dictionary = saved["the_gioi"]
	print("SAVE map_v=", w.get("map_v"), " fog_len=", str(w.get("fog", "")).length(), " pos=", w.get("pos"))
	_check(int(w.get("map_v", 0)) == 2 and str(w.get("fog", "")) != "", "lưu bản đồ khám phá")
	await _stop_main()
	Game.use_account(tid)
	await _start_main()
	lv = main.level
	p = lv.player
	for i in 5:
		await get_tree().process_frame
	print("RELOAD explored=", _explored(lv), " before=", explored_before, " pos cell=", Vector2i(p.position / 16.0), " fires=", lv.placed_fires.size())
	_check(_explored(lv) == explored_before, "nạp lại giữ nguyên bản đồ khám phá")
	# 6) Crab / scorpion
	var crabs := 0
	var scorpions := 0
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.display_name.contains("Cua"):
			crabs += 1
		if e.display_name.contains("cạp"):
			scorpions += 1
	print("ENEMIES total=", get_tree().get_nodes_in_group("enemies").size(), " crabs=", crabs, " scorpions=", scorpions)
	_check(crabs > 0 and scorpions > 0, "có cua và bọ cạp")
	await _stop_main()
	Accounts.delete(tid)
	if errors > 0:
		print("TEST FAIL: %d lỗi" % errors)
	else:
		print("TEST OK")
	print("TEST DONE")
	get_tree().quit(1 if errors > 0 else 0)


func _check(ok: bool, what: String) -> void:
	if not ok:
		errors += 1
		push_error("SAI: " + what)


func _npc_names(lv: Level) -> String:
	var out := []
	for n in lv.entities.get_children():
		if n.get_script() == Level.NPC_SCRIPT:
			out.append(str(n.get("npc_name") if n.get("npc_name") != null else n.name))
	return "%d npcs" % out.size()


func _explored(lv: Level) -> int:
	var n := 0
	for b in lv.explored:
		n += b
	return n


func _awake(lv: Level) -> int:
	var n := 0
	for s in lv.sleepers:
		if is_instance_valid(s) and s.process_mode != Node.PROCESS_MODE_DISABLED:
			n += 1
	return n


func _open_near(lv: Level, c: Vector2i) -> Vector2:
	for r in 12:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var n := c + Vector2i(dx, dy)
				if lv.is_open(lv.to_global(Vector2(n.x + 0.5, n.y + 0.5) * 16.0), 6.0):
					return Vector2(n.x + 0.5, n.y + 0.5) * 16.0
	return Vector2(c.x + 0.5, c.y + 0.5) * 16.0


func _start_main() -> void:
	main = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(main)
	for i in 5:
		await get_tree().process_frame


func _stop_main() -> void:
	main.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
