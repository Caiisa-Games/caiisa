class_name BattleManager
extends Node2D

enum Phase { SELECT, MOVE, ATTACK }
enum Turn { PLAYER_1, PLAYER_2 }

@export var player_1_pieces: Array[Dictionary] = []  # [{piece: PieceData, tile: Vector2i}]
@export var player_2_pieces: Array[Dictionary] = []

var current_turn: Turn = Turn.PLAYER_1
var current_phase: Phase = Phase.SELECT
var selected_piece: Tile = null
var valid_moves: Array[Tile] = []
var has_moved_this_turn: bool = false
var has_attacked_this_turn: bool = false
var round_number: int = 1

@onready var board = $BoardLayer/Board
@onready var turn_label = $UI/TopBar/TurnLabel
@onready var round_label = $UI/TopBar/RoundLabel
@onready var info_label = $UI/RightPanel/InfoLabel
@onready var move_button = $UI/LeftPanel/Player1Panel/ActionButtons/MoveButton
@onready var attack_button = $UI/LeftPanel/Player1Panel/ActionButtons/AttackButton

func _ready() -> void:
	player_1_pieces = GameState.player_1_pieces
	player_2_pieces = GameState.player_2_pieces	
	
	_setup_board()
	_connect_board_signals()
	_update_ui()


func _setup_board() -> void:
	board.set_mode(BoardManager.Mode.BATTLE)
	
	for piece_data in player_1_pieces:
		var pos = piece_data.tile_pos
		board.place_piece(piece_data.piece, pos.x, pos.y, 1)
	
	for piece_data in player_2_pieces:
		var pos = piece_data.tile_pos
		board.place_piece(piece_data.piece, pos.x, pos.y, 2)


func _connect_board_signals() -> void:
	for tile in board.tiles.values():
		tile.tile_clicked.connect(_on_tile_clicked)

func _on_tile_clicked(grid_pos: Vector2i) -> void:
	var tile = board.get_tile_at(grid_pos)
	if tile == null:
		return
	
	var current_player = 1 if current_turn == Turn.PLAYER_1 else 2
	
	match current_phase:
		Phase.SELECT:
			_handle_selection(tile, current_player)
		
		Phase.MOVE:
			_handle_move(tile)


func _handle_selection(tile: Tile, player: int) -> void:
	if tile.occupant == null:
		_clear_selection()
		return
	
	selected_piece = tile
	current_phase = Phase.MOVE
	_update_valid_moves()
	_update_ui()


func _handle_move(tile: Tile) -> void:
	if tile in valid_moves:
		_execute_move(tile)
	elif tile.occupant != null:
		_handle_selection(tile, 1 if current_turn == Turn.PLAYER_1 else 2)
	else:
		_clear_selection()


func _handle_attack(tile: Tile) -> void:
	# TODO: Implement attack logic
	pass

func _execute_move(tile: Tile) -> void:
	if selected_piece == null:
		return
			
	var player_id = selected_piece.occupant_player
	
	board._move_occupant(selected_piece, tile)
	
	has_moved_this_turn = true
	selected_piece = tile
	_clear_selection()
	_update_ui()


func _clear_selection() -> void:
	selected_piece = null
	current_phase = Phase.SELECT
	valid_moves.clear()
	board.clear_all_highlights()
	_update_ui()


func _update_valid_moves() -> void:
	if selected_piece == null or selected_piece.occupant == null:
		return
	
	valid_moves = board.get_valid_moves(selected_piece.occupant, selected_piece)
	
	board.clear_all_highlights()
	for tile in valid_moves:
		tile.set_placement_highlight(true)


func _end_turn() -> void:
	if current_turn == Turn.PLAYER_1:
		current_turn = Turn.PLAYER_2
	else:
		current_turn = Turn.PLAYER_1
		round_number += 1
	
	has_moved_this_turn = false
	has_attacked_this_turn = false
	_clear_selection()
	_update_ui()

func _update_ui() -> void:
	turn_label.text = "Player %d's Turn" % (1 if current_turn == Turn.PLAYER_1 else 2)
	round_label.text = "Round %d" % round_number
	
	#move_button.disabled = has_moved_this_turn or selected_piece == null
	#attack_button.disabled = has_attacked_this_turn or selected_piece == null
	
	#match current_phase:
		#Phase.SELECT:
			#info_label.text = "Select a piece to move"
		#Phase.MOVE:
			#info_label.text = "Click a highlighted tile to move"

func _on_move_button_pressed() -> void:
	if selected_piece != null:
		current_phase = Phase.MOVE
		_update_valid_moves()
		_update_ui()


func _on_attack_button_pressed() -> void:
	# TODO: Implement attack phase
	pass


func _on_end_turn_button_pressed() -> void:
	_end_turn()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
