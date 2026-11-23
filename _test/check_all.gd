extends Node
## Kiểm tra nhanh (dùng cho CI): nạp mọi script và scene của game, báo lỗi nếu có cái nào hỏng.

var errors := 0
var count := 0


func _ready() -> void:
	_scan("res://scripts")
	_scan("res://scenes")
	print("CHECK đã nạp %d tệp, lỗi %d" % [count, errors])
	print("CHECK OK" if errors == 0 else "CHECK FAIL")
	get_tree().quit(1 if errors > 0 else 0)


func _scan(dir: String) -> void:
	for f in DirAccess.get_files_at(dir):
		var path := dir + "/" + f
		if f.ends_with(".gd"):
			count += 1
			var s := load(path) as GDScript
			if s == null or not s.can_instantiate():
				_fail(path)
		elif f.ends_with(".tscn"):
			count += 1
			var p := load(path) as PackedScene
			if p == null or not p.can_instantiate():
				_fail(path)
	for d in DirAccess.get_directories_at(dir):
		_scan(dir + "/" + d)


func _fail(path: String) -> void:
	errors += 1
	push_error("HỎNG: " + path)
