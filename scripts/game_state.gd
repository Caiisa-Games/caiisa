extends Node

var player_1_pieces: Dictionary = {}
var player_2_pieces: Dictionary = {}
var selected_board: BoardData
var selected_board_index: int = 0

var current_round: int = 1
var current_turn: int = 1
var winner: int = 0

func reset() -> void:
	player_1_pieces.clear()
	player_2_pieces.clear()
	current_round = 1
	current_turn = 1
	winner = 0


func get_pieces_for_player(player: int) -> Dictionary:
	match player:
		1: return player_1_pieces
		2: return player_2_pieces
	return {}
