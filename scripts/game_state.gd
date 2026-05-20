extends Node

var board: BoardData

var player_1_pieces: Dictionary = {}
var player_2_pieces: Dictionary = {}

var winner: int = 0

var intro_played: bool = false

func reset() -> void:
	player_1_pieces.clear()
	player_2_pieces.clear()
	winner = 0


func get_pieces_for_player(player: int) -> Dictionary:
	match player:
		1: return player_1_pieces
		2: return player_2_pieces
	return {}
