extends Node
## Đo độ mượt khi đi bộ qua nhiều vùng: in ra thời gian từng khung hình (p50, p99, max).

var main: Node


func _ready() -> void:
	await get_tree().process_frame
	Accounts.setup()
	var look := CharacterParts.DEFAULT.duplicate()
	look["name"] = "_thu_do_"
	var tid := Accounts.create(look)
	Game.use_account(tid)
	var t0 := Time.get_ticks_msec()
	main = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(main)
	for i in 5:
		await get_tree().process_frame
	print("LOAD_MS ", Time.get_ticks_msec() - t0)
	var lv: Level = main.level
	var p: Player = lv.player
	p.teleport_to(lv.to_global(Vector2(150.5, 104.5) * 16.0))
	for i in 90:
		await get_tree().process_frame
	var times := []
	var t_start := Time.get_ticks_msec()
	p.command_move(lv.to_global(Vector2(300.5, 140.5) * 16.0), false)
	while Time.get_ticks_msec() - t_start < 15000:
		var t := Time.get_ticks_usec()
		await get_tree().process_frame
		times.append((Time.get_ticks_usec() - t) / 1000.0)
	times.sort()
	var n := times.size()
	print("WALK frames=%d p50=%.1f p90=%.1f p99=%.1f max=%.1f end=%s" % [n, times[n / 2], times[n * 9 / 10], times[n * 99 / 100], times[n - 1], str(Vector2i(p.position / 16.0))])
	var slow := 0
	for t in times:
		if t > 20.0:
			slow += 1
	print("WALK slow(>20ms)=", slow)
	main.queue_free()
	await get_tree().process_frame
	Accounts.delete(tid)
	get_tree().quit()
