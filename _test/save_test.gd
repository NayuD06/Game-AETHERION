extends Node
## Chạy thử hệ thống tài khoản (chỉ để kiểm tra, xóa sau khi xong).

var main: Node


func _ready() -> void:
	await get_tree().process_frame
	Accounts.setup()
	var accs := Accounts.list()
	for a in accs:
		print("ACC ", a["name"], " lv=", a["level"], " full=", a["full"], " weapon=", a["weapon"], " last=", Accounts.time_text(int(a["last_played"])))
	var full_id := ""
	for a in accs:
		if a["full"]:
			full_id = a["id"]
	print("FULL_ID ", full_id)
	# 1) Tài khoản Full
	Game.use_account(full_id)
	await _start_main()
	var p: Player = main.level.player
	print("FULL lv=%d xp=%d/%d hp=%d mp=%d atk=%d def=%d gold=%d bag=%d/%d slots=%s" % [p.level, p.xp, p.xp_to_next, p.max_hp, p.max_mp, p.attack, p.defense, p.gold, p.bag.size(), p.bag_slots, str(p.skill_slots)])
	print("FULL gear=", p.gear)
	print("FULL gate=", main.level.gate_open, " floor=", main.level.current_floor, " unlocked R=", p.is_slot_unlocked(3), " reorder=", p.can_reorder_skills())
	p.add_xp(100000)
	print("FULL after xp lv=%d xp=%d" % [p.level, p.xp])
	await _stop_main()
	# 2) Tài khoản thử: tạo, chơi, lưu, nạp lại
	var look := CharacterParts.DEFAULT.duplicate()
	look["name"] = "_thu_luu_"
	look["weapon"] = 2
	var tid := Accounts.create(look)
	Game.use_account(tid)
	print("NEW progress empty=", Game.progress.is_empty())
	await _start_main()
	p = main.level.player
	print("NEW lv=%d gold=%d bag=%s gear=%s" % [p.level, p.gold, str(p.bag), str(p.gear)])
	p.add_xp(1100)
	p.gold = 123
	p.add_item("wood", 5)
	p.add_attack(4)
	p.store_gear(Equipment.make("helmet_3", "epic"))
	if p.can_reorder_skills():
		p.swap_skills(0, 3)
	var lv: Level = main.level
	lv._open_cave_seal(false)
	var dest := lv._stairs_pos(2, "up") + Vector2(0, 32)
	p.teleport_to(lv.to_global(dest))
	for i in 10:
		await get_tree().process_frame
	print("NEW before save lv=%d atk=%d floor=%d save_floor=%d slots=%s" % [p.level, p.attack, lv.current_floor, lv.save_floor, str(p.skill_slots)])
	var ok: bool = main.save_game(false)
	print("SAVE ok=", ok)
	var saved := Accounts.read(tid)
	print("FILE tien_do=", saved["tien_do"])
	print("FILE the_gioi=", saved["the_gioi"])
	var want_atk := p.attack
	var want_slots := str(p.skill_slots)
	await _stop_main()
	Game.use_account(tid)
	await _start_main()
	p = main.level.player
	lv = main.level
	for i in 10:
		await get_tree().process_frame
	print("LOAD lv=%d atk=%d(want %d) gold=%d bag=%d floor=%d gate=%s slots=%s(want %s) in_dungeon=%s" % [p.level, p.attack, want_atk, p.gold, p.bag.size(), lv.current_floor, str(lv.gate_open), str(p.skill_slots), want_slots, str(lv.in_dungeon)])
	await _stop_main()
	Accounts.delete(tid)
	print("DELETED exists=", FileAccess.file_exists(Accounts.path(tid)))
	print("TEST DONE")
	get_tree().quit()


func _start_main() -> void:
	main = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(main)
	for i in 5:
		await get_tree().process_frame


func _stop_main() -> void:
	main.queue_free()
	for i in 3:
		await get_tree().process_frame
