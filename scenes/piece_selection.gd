class_name PieceSelection
extends Control

const MAX_PIECES := 6

@onready var card_flow = $HSplitContainer/LeftPanel/ScrollContainer/MarginContainer/CardFlow
@onready var board = $HSplitContainer/RightPanel/PreviewLayer/Board
@onready var selected_count_label = $HSplitContainer/RightPanel/SelectedCountLabel
@onready var player_turn_label = $HSplitContainer/RightPanel/PlayerTurnLabel
@onready var start_button = $HSplitContainer/LeftPanel/StartButton

var current_player: int = 1
var player1_selected_pieces: Array[Dictionary] = []
var player2_selected_pieces: Array[Dictionary] = []

@export var available_pieces: Array[PieceData] = []

func _ready() -> void:
	board.set_mode(BoardManager.Mode.PREVIEW)
	board.highlight_valid_row(current_player)
	_connect_board_signals()
	
	start_button.visible = false
	start_button.disabled = true
	
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
	board.highlight_valid_row(current_player)
	for child in card_flow.get_children():
		if child is Card and child != card:
			child.deselect()

func _on_card_deselected(card: Card) -> void:
	pass

func _on_tile_clicked(grid_pos: Vector2i) -> void:
	var selected_card: Card = _get_selected_card()
	var tile = board.get_tile_at(grid_pos)
	
	if selected_card == null:
		return
	
	if not _is_valid_placement_row(grid_pos.y):
		_show_error_feedback("Invalid row! Player %d must place on row %d" % [current_player, _get_valid_row()])
		return
	
	if tile.occupant.piece_data != null:
		_show_error_feedback("Tile already occupied!")
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
		board.highlight_valid_row(current_player)
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
		player1_selected_pieces.append({"piece": card.piece_data,
										"tile_pos": tile.grid_position})
	else:
		player2_selected_pieces.append({"piece": card.piece_data,
										"tile_pos": tile.grid_position})
	
	card.deselect()
	card.set_disabled(true)
	
	var player_pieces = _get_player_pieces(current_player)
	
	if player_pieces.size() >= MAX_PIECES:
		_finish_player_placement()
	else:
		_update_ui()


func _get_player_pieces(player: int) -> Array[Dictionary]:
	if player == 1:
		return player1_selected_pieces
	if player == 2:
		return player2_selected_pieces
	return [{}]


func _finish_player_placement() -> void:
	board.clear_all_highlights()
	start_button.disabled = false
	start_button.visible = true
	_update_ui()
	if current_player == 2:
		player_turn_label.text = "Both players ready!"


func _update_ui() -> void:
	var player_pieces = _get_player_pieces(current_player)
	selected_count_label.text = "%d/%d Pieces Placed" % [player_pieces.size(), MAX_PIECES]
	player_turn_label.text = "Player %d - Select Your Pieces" % current_player


func _show_error_feedback(message: String) -> void:
	push_warning(message) #TODO


func _on_start_button_pressed() -> void:
	if current_player == 1:
		start_button.disabled = true
		start_button.visible = false
		current_player = 2
		_create_cards_for_current_player()
		_update_ui()
	elif current_player == 2:
		GameState.player_1_pieces = player1_selected_pieces
		GameState.player_2_pieces = player2_selected_pieces

		get_tree().change_scene_to_file("res://scenes/battle.tscn")


func get_placement_data() -> Dictionary:
	return {
		"player1_pieces": player1_selected_pieces,
		"player2_pieces": player2_selected_pieces,
	}
