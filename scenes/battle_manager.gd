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
var has_attacked: bool = false
var round_number: int = 1
var winner: int = 0

@onready var board: BoardManager = $BoardLayer/Board
@onready var turn_label = $UI/TopBar/TurnLabel
@onready var round_label = $UI/TopBar/RoundLabel
@onready var winner_label = $GameOverLayer/Control/WinnerLabel

@onready var UI = $UI
@onready var game_over = $GameOverLayer

func _ready() -> void:
	var h = load("res://assets/sound/بعد از انتخاب همه ی کارت های یک پلیر.mp3")
	AudioManager.play_sfx(h)
	AudioManager.play_music(preload("res://assets/sound/music_game.ogg"))
	player_1_pieces = GameState.player_1_pieces
	player_2_pieces = GameState.player_2_pieces
	
	game_over.visible = false
	
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
		
func get_valid_moves(piece: PieceData, from_tile: Tile) -> Array[Tile]:
	var moves: Array[Tile] = []
	var movement = piece.movement if piece.movement else board.default_movement
	
	var directions: Array[Vector2i] = []
	match movement.movement_type:
		MovementData.MovementType.ORTHOGONAL:
			directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		MovementData.MovementType.DIAGONAL:
			directions = [Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(1,1)]
		MovementData.MovementType.BOTH:
			directions = [
				Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT,
				Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(1,1)
			]
	
	for dir in directions:
		for range_step in range(1, movement.move_range + 1):
			var target_pos = from_tile.grid_position + (dir * range_step)
			
			if target_pos.y < 0 or target_pos.x < 0 or target_pos.y >= board.GRID_SIZE or target_pos.x >= board.GRID_SIZE:
				break
			
			var target_tile = board.tiles.get(target_pos)
			if target_tile == null:
				break
			
			moves.append(target_tile)
	
	return moves

func _on_tile_clicked(grid_pos: Vector2i) -> void:
	var tile: Tile = board.get_tile_at(grid_pos)
	if tile == null:
		return
		
	print("TILE POS: ", tile.grid_position)
	
	var current_player = 1 if current_turn == Turn.PLAYER_1 else 2
	
	match current_phase:
		Phase.SELECT:
			_handle_selection(tile, current_player)
		
		Phase.MOVE:
			_handle_move(tile)

func _handle_selection(tile: Tile, player: int) -> void:
	if tile.occupant.piece_data == null:
		_clear_selection()
		return
	
	if tile.occupant.player != player:
		_clear_selection()
		return
	
	var audio = load("res://assets/sound/سلکت کردن مهره برای قبل از حرکت.mp3")
	AudioManager.play_sfx(audio)
	
	selected_piece = tile
	current_phase = Phase.MOVE
	_update_valid_moves()
	_update_ui()
	
func _handle_move(tile: Tile) -> void:
	var turn = 1 if current_turn == Turn.PLAYER_1 else 2
	if tile in valid_moves:
		if tile.occupant.piece_data != null and tile.occupant.player != turn:
			_handle_attack(tile)
		else:
			AudioManager.play_sfx(preload("res://assets/sound/فرود اومدن مهره بعد از حرکت.mp3"))
			_execute_move(tile)
	else:
		AudioManager.play_sfx(preload("res://assets/sound/کلیک روی خونه های غیر قابل دسترس به هنگام حرکت مهره.mp3"))
		_clear_selection()

func _handle_attack(tile: Tile) -> void:
	if has_attacked:
		has_attacked = false
		return
	has_attacked = true
	var target = tile.occupant
	if target == null:
		return
	
	if target == selected_piece.occupant:
		return
	
	var attacker_player = selected_piece.occupant.player
	var defender_player = target.player
	
	if attacker_player == defender_player:
		return
	
	var movement = selected_piece.occupant.piece_data.movement
	if not movement:
		movement = MovementData.new()
	if not CombatRules.is_within_range(
		selected_piece.grid_position,
		tile.grid_position,
		movement.move_range
	):
		return
	var attacker_tile = selected_piece
	var attacker_height = attacker_tile.height_level
	var defender_height = tile.height_level
	
	var height_delta = attacker_height - defender_height
	
	var damage = CombatRules.calculate_damage(
		selected_piece.occupant.piece_data.power,
		height_delta,
		false
	)
	
	var died = target.take_damage(damage)
	
	var finished = false
	if died:
		finished = _handle_died(target)
	var audio = load("res://assets/sound/دمیج دادن به مهره ی مقابل.mp3")
	AudioManager.play_sfx(audio)
	if finished:
		_handle_game_over()
	else:
		_end_turn()
		_clear_selection()

func _execute_move(tile: Tile) -> void:
	if selected_piece == null:
		return

	board._move_occupant(selected_piece, tile)
	
	_end_turn()
	_clear_selection()
	_update_ui()

func _handle_died(target: Occupant) -> bool:
	var pieces: Array[Dictionary];
	match target.player:
		1: pieces = player_1_pieces
		2: pieces = player_2_pieces

	for item in pieces:
		if item["piece"] == target.piece_data:
			pieces.erase(item)
	
	if len(player_1_pieces) == 0:
		winner = 2
		return true
	elif len(player_2_pieces) == 0:
		winner = 1
		return true
	target.clear_data()
	return false

func _clear_selection() -> void:
	selected_piece = null
	current_phase = Phase.SELECT
	valid_moves.clear()
	board.clear_all_highlights()
	_update_ui()

func _update_valid_moves() -> void:
	if selected_piece == null or selected_piece.occupant == null:
		return
	
	valid_moves = get_valid_moves(selected_piece.occupant.piece_data, selected_piece)
	
	board.clear_all_highlights()
	for tile in valid_moves:
		if tile.occupant.piece_data:
			if tile.occupant.player != selected_piece.occupant.player:
				tile.set_highlight_color(Tile.HighlightColor.ATTACK)
			else:
				valid_moves.erase(tile)
		else:
			tile.set_highlight_color(Tile.HighlightColor.MOVE)

func _end_turn() -> void:
	if current_turn == Turn.PLAYER_1:
		current_turn = Turn.PLAYER_2
	else:
		current_turn = Turn.PLAYER_1
		round_number += 1
	
	_clear_selection()
	_update_ui()

func _update_ui() -> void:
	turn_label.text = tr("player_turn") % (1 if current_turn == Turn.PLAYER_1 else 2)
	round_label.text = tr("current_round") % round_number
	
func _handle_game_over() -> void:
	if winner == 0:
		return
	
	#UI.visible = false
	game_over.visible = true
	
	winner_label.text = tr("player_won") % winner

func _on_end_turn_button_pressed() -> void:
	_end_turn()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
