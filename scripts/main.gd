extends Node2D
## Điều khiển luồng game: tạm dừng, thua, thắng, chơi lại, tự lưu tài khoản.

## Tự lưu tài khoản sau mỗi bấy nhiêu giây chơi. Game còn lưu khi lên cấp, khi bấm Esc (tạm dừng),
## khi bấm N (về màn hình chọn tài khoản) và khi tắt cửa sổ game.
const AUTOSAVE_SECONDS := 30.0
const ACCOUNT_SCENE := "res://scenes/account_select.tscn"

@onready var level: Level = $Level
@onready var hud: GameHUD = $HUD

var game_over := false
var autosave_timer := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	hud.player = level.player
	level.player.died.connect(_on_player_died)
	level.player.leveled_up.connect(func(_lv: int) -> void: save_game())
	Game.game_won.connect(_on_game_won)
	# Chế độ quay video (chỉ khi mở game bằng dòng lệnh có -- --demo=..., xem scripts/demo.gd)
	if Demo.requested() != "":
		add_child(Demo.new())
	elif not Game.progress.has("tien_do"):
		save_game.call_deferred(false)   # nhân vật mới: lưu ngay để tài khoản có cấp 1, túi đồ khởi đầu


func _process(delta: float) -> void:
	if get_tree().paused or game_over or Game.account_id == "":
		return
	autosave_timer += delta
	if autosave_timer >= AUTOSAVE_SECONDS:
		save_game()


## Lưu tài khoản đang chơi. Không lưu khi đang quay video demo, khi đã chết hoặc đã thắng.
## show_text: hiện chữ "Đã lưu game" ở góc dưới bên phải.
func save_game(show_text: bool = true) -> bool:
	autosave_timer = 0.0
	if Game.account_id == "" or game_over or level.player == null or level.player.is_dead:
		return false
	var data := { "tien_do": level.player.get_save_data(), "the_gioi": level.get_save_data() }
	if not Game.save_progress(data):
		Game.message.emit("Không lưu được game!")
		return false
	if show_text:
		hud.show_saved()
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game(false)   # tắt cửa sổ game: lưu lần cuối


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not game_over:
		get_tree().paused = not get_tree().paused
		hud.set_paused(get_tree().paused)
		if get_tree().paused:
			save_game()
	elif event.is_action_pressed("restart") and game_over:
		# Chơi lại từ lần lưu gần nhất
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif event.is_action_pressed("new_character") and (game_over or get_tree().paused):
		save_game(false)
		get_tree().paused = false
		get_tree().change_scene_to_file(ACCOUNT_SCENE)


func _on_player_died() -> void:
	game_over = true
	await get_tree().create_timer(1.0).timeout
	hud.show_death()


func _on_game_won() -> void:
	save_game(false)
	game_over = true
	get_tree().paused = true
	hud.show_win()
