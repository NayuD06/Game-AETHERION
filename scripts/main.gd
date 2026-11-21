extends Node2D
## Điều khiển luồng game: tạm dừng, thua, thắng, chơi lại.

@onready var level: Level = $Level
@onready var hud: GameHUD = $HUD

var game_over := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	hud.player = level.player
	level.player.died.connect(_on_player_died)
	Game.game_won.connect(_on_game_won)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not game_over:
		get_tree().paused = not get_tree().paused
		hud.set_paused(get_tree().paused)
	elif event.is_action_pressed("restart") and game_over:
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif event.is_action_pressed("new_character") and (game_over or get_tree().paused):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/character_creator.tscn")


func _on_player_died() -> void:
	game_over = true
	await get_tree().create_timer(1.0).timeout
	hud.show_death()


func _on_game_won() -> void:
	game_over = true
	get_tree().paused = true
	hud.show_win()
