extends Node
## Vào thẳng tài khoản Full để chụp màn hình (chỉ để kiểm tra, xóa sau khi xong).

func _ready() -> void:
	Accounts.setup()
	for a in Accounts.list():
		if a["full"]:
			Game.use_account(a["id"])
	get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
