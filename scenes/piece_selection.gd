class_name PieceSelection
extends Control

const MAX_PIECES := 3

@onready var card_flow = $HSplitContainer/LeftPanel/VBoxContainer/ScrollContainer/MarginContainer/CardFlow
@onready var board = $HSplitContainer/RightPanel/PreviewLayer/Board
@onready var selected_count_label = $HSplitContainer/RightPanel/SelectedCountLabel
@onready var player_turn_label = $HSplitContainer/RightPanel/PlayerTurnLabel
@onready var start_button = $HSplitContainer/LeftPanel/VBoxContainer/StartButton
@onready var remove_button = $HSplitContainer/RightPanel/Buttons/RemoveButton

var current_player: int = 1
var player1_selected_pieces: Dictionary = {}
var player2_selected_pieces: Dictionary = {}

var selected_tile: Tile

@export var available_pieces: Array[PieceData] = []

func _ready() -> void:
	board.set_mode(BoardManager.Mode.PREVIEW)
	_connect_board_signals()
	
	start_button.visible = false
	start_button.disabled = true
	
	_set_remvovebtn_status(false)

	_create_cards_for_current_player()
	_update_ui()

func _connect_board_signals() -> void:
	for tile in board.tiles.values():
		tile.tile_clicked.connect(_on_tile_clicked)

func _create_cards_for_current_player() -> void:
	for child in card_flow.get_children():
		child.queue_free()
	
	var card_scene = load("res://scenes/card.tscn")

	for piece in available_pieces:
		var card = card_scene.instantiate() as Card
		card.init()
		card.set_piece_data(piece)
		card.card_selected.connect(_on_card_selected)
		card.card_deselected.connect(_on_card_deselected)
		card_flow.add_child(card)

func _on_card_selected(card: Card) -> void:
	for child in card_flow.get_children():
		if child is Card and child != card:
			child.deselect()
	if current_player == 1:
		if MAX_PIECES == len(player1_selected_pieces):
			return
	else:
		if MAX_PIECES == len(player2_selected_pieces):
			return
	selected_tile = null
	AudioManager.play_sfx(preload("res://assets/sound/سلکت کردن مهره برای قبل از حرکت.mp3"))
	var valid_row = get_valid_placement_tiles(current_player)
	board.highlight_tiles(valid_row)

func _on_card_deselected(_card: Card) -> void:
	board.clear_all_highlights()

func _on_tile_clicked(grid_pos: Vector2i) -> void:
	var selected_card: Card = _get_selected_card()
	var tile = board.get_tile_at(grid_pos)
	
	if not _is_valid_placement_row(grid_pos.y):
		AudioManager.play_sfx(preload("res://assets/sound/کلیک روی خونه های غیر قابل دسترس به هنگام حرکت مهره.mp3"))
		_show_error_feedback("Invalid row! Player %d must place on row %d" % [current_player, _get_valid_row()])
		return

	if tile.occupant.piece_data != null and tile != selected_tile:
		_set_remvovebtn_status(true)
		if selected_card:
			selected_card.deselect()
		AudioManager.play_sfx(preload("res://assets/sound/سلکت کردن مهره برای قبل از حرکت.mp3"))
		var valid_moves = get_valid_placement_tiles(current_player)
		board.highlight_tiles(valid_moves)
		board.highlight_tile(tile, Tile.HighlightColor.SELF)
		selected_tile = tile
		return

	if selected_tile != null:
		_set_remvovebtn_status(false)
		if tile != selected_tile:
			AudioManager.play_sfx(preload("res://assets/sound/فرود اومدن مهره بعد از حرکت.mp3"))
			board._move_occupant(selected_tile, tile)
		board.clear_all_highlights()
		selected_tile = null
		return

	if selected_card == null:
		return
		
	if current_player == 1:
		if MAX_PIECES == len(player1_selected_pieces):
			_show_error_feedback("All pieces placed")
			return
	else:
		if MAX_PIECES == len(player2_selected_pieces):
			_show_error_feedback("All pieces placed")
			return
	
	var success = board.place_piece(
		selected_card.piece_data,
		grid_pos.x,
		grid_pos.y,
		current_player
	)
	
	if success:
		AudioManager.play_sfx(preload("res://assets/sound/فرود اومدن مهره بعد از حرکت.mp3"))
		var valid_moves = get_valid_placement_tiles(current_player)
		board.highlight_tiles(valid_moves)
		_handle_successful_placement(selected_card, tile)


func _get_selected_card() -> Card:
	for child in card_flow.get_children():
		if child is Card and child.is_selected:
			return child
	return null


func _is_valid_placement_row(row: int) -> bool:
	var valid_row = _get_valid_row()
	return row == valid_row


func _get_valid_row() -> int:
	return 0 if current_player == 1 else 6


func _handle_successful_placement(card: Card, tile: Tile) -> void:

	if current_player == 1:
		player1_selected_pieces[tile.grid_position] = card.piece_data
	else:
		player2_selected_pieces[tile.grid_position] = card.piece_data

	
	card.deselect()
	card.set_disabled(true)
	
	var player_pieces = _get_player_pieces(current_player)
	
	if player_pieces.size() >= MAX_PIECES:
		_finish_player_placement()
	else:
		_update_ui()

func _set_remvovebtn_status(visibility: bool):
	remove_button.visible = visibility
	remove_button.disabled = !visibility

func _get_player_pieces(player: int) -> Dictionary:
	if player == 1:
		return player1_selected_pieces
	if player == 2:
		return player2_selected_pieces
	return {}


func _finish_player_placement() -> void:
	board.clear_all_highlights()
	start_button.disabled = false
	start_button.visible = true
	_update_ui()
	if current_player == 2:
		player_turn_label.text = tr("both_ready")


func _update_ui() -> void:
	var player_pieces = _get_player_pieces(current_player)
	selected_count_label.text = tr("pieces_selected") % [player_pieces.size(), MAX_PIECES]
	player_turn_label.text = tr("turn_label") % current_player


func _show_error_feedback(message: String) -> void:
	push_warning(message) #TODO

func get_valid_placement_tiles(player: int) -> Array[Tile]:
	var valid_tiles: Array[Tile] = []
	var valid_row = 0 if player == 1 else board.GRID_SIZE - 1
	
	for x in range(board.GRID_SIZE):
		var tile = board.tiles.get(Vector2i(x, valid_row))
		if tile != null and tile.occupant.piece_data == null:
			valid_tiles.append(tile)
	
	return valid_tiles

func _on_start_button_pressed() -> void:
	if current_player == 1:
		start_button.disabled = true
		start_button.visible = false
		current_player = 2
		_create_cards_for_current_player()
		_update_ui()
		AudioManager.play_sfx(preload("res://assets/sound/بعد از انتخاب همه ی کارت های یک پلیر.mp3"))
	elif current_player == 2:
		GameState.player_1_pieces = player1_selected_pieces
		GameState.player_2_pieces = player2_selected_pieces
		get_tree().change_scene_to_file("res://scenes/battle.tscn")

func get_placement_data() -> Dictionary:
	return {
		"player1_pieces": player1_selected_pieces,
		"player2_pieces": player2_selected_pieces,
	}

func _on_exit_pressed() -> void:
	AudioManager.play_sfx(preload("res://assets/sound/فشردن دکمه های سنگی.mp3"))
	
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_remove_button_pressed() -> void:
	if selected_tile == null:
		AudioManager.play_sfx(preload("res://assets/sound/کلیک روی خونه های غیر قابل دسترس به هنگام حرکت مهره.mp3"))
		return
	
	board.clear_all_highlights()
	selected_tile.occupant.clear_data()
	match current_player:
		1: player1_selected_pieces.erase(selected_tile.grid_position)
		2: player2_selected_pieces.erase(selected_tile.grid_position)
	
	AudioManager.play_sfx(preload("res://assets/sound/فشردن دکمه های سنگی.mp3"))
	_update_ui()
	_set_remvovebtn_status(false)
