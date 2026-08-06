extends Node

enum GameMode {
	MULTIPLAYER,
	SINGLEPLAYER
}

var game_mode = null

var board: BoardData

var player_1_pieces: Dictionary = {}
var player_2_pieces: Dictionary = {}

var winner: int = 0

var intro_played: bool = false

var current_stage := 0

func reset() -> void:
	player_1_pieces.clear()
	player_2_pieces.clear()
	winner = 0
	
func unlock_stage(stage: int) -> void:
	var highest_unlocked_level = SaveManager.data.highest_unlocked_level
	if current_stage == highest_unlocked_level:
		highest_unlocked_level = stage
		SaveManager.data.highest_unlocked_level = highest_unlocked_level
		SaveManager.save()


func get_pieces_for_player(player: int) -> Dictionary:
	match player:
		1: return player_1_pieces
		2: return player_2_pieces
	return {}
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F11:
			toggle_fullscreen()

func toggle_fullscreen() -> void:
	var current_mode := DisplayServer.window_get_mode()
	
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 648))
