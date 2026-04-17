class_name PieceSelection
extends Control

const MAX_PIECES := 3

@onready var card_flow = $HSplitContainer/LeftPanel/ScrollContainer/CardFlow
@onready var board = $HSplitContainer/RightPanel/PreviewLayer/Board
@onready var selected_count_label = $HSplitContainer/RightPanel/SelectedCountLabel
@onready var player_turn_label = $HSplitContainer/RightPanel/PlayerTurnLabel
@onready var start_button = $HSplitContainer/LeftPanel/StartButton

var current_player: int = 1
var placed_pieces: Array[Dictionary] = []
var player1_selected_pieces: Array[PieceData] = []
var player2_selected_pieces: Array[PieceData] = []

@export var available_pieces: Array[PieceData] = []


func _ready() -> void:
	board.set_mode(BoardManager.Mode.PREVIEW)
	board.tile_clicked.connect(_on_board_tile_clicked)
	
	start_button.visible = false
	start_button.disabled = true
	start_button.pressed.connect(_on_start_button_pressed)
	
	_create_cards_for_current_player()
	_update_ui()


func _create_cards_for_current_player() -> void:
	for child in card_flow.get_children():
		child.queue_free()
	
	var card_scene = load("res://scenes/card.tscn")
		
	for piece in available_pieces:
		var card = card_scene.instantiate() as Card
		card.set_piece_data(piece)
		card.card_selected.connect(_on_card_selected)
		card.card_deselected.connect(_on_card_deselected)
		card_flow.add_child(card)


func _on_card_selected(card: Card) -> void:
	for child in card_flow.get_children():
		if child is Card and child != card:
			child.deselect()


func _on_card_deselected(card: Card) -> void:
	pass


func _on_board_tile_clicked(tile: Tile) -> void:
	var selected_card: Card = _get_selected_card()
	
	if selected_card == null:
		return
	
	if not _is_valid_placement_row(tile.grid_position.y):
		_show_error_feedback("Invalid row! Player %d must place on row %d" % [current_player, _get_valid_row()])
		return
	
	if tile.occupant != null:
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
		tile.grid_position.x,
		tile.grid_position.y,
		current_player
	)
	
	if success:
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
	placed_pieces.append({
		"piece": card.piece_data,
		"tile": tile,
		"player": current_player,
		"card": card
	})
	
	if current_player == 1:
		player1_selected_pieces.append(card.piece_data)
	else:
		player2_selected_pieces.append(card.piece_data)
	
	card.deselect()
	card.set_disabled(true)
	
	var player_pieces = _get_player_pieces(current_player)
	
	if player_pieces.size() >= MAX_PIECES:
		_finish_player_placement()
	else:
		_update_ui()


func _get_player_pieces(player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for piece in placed_pieces:
		if piece.player == player:
			result.append(piece)
	return result


func _finish_player_placement() -> void:
	if current_player == 1:
		current_player = 2
		_create_cards_for_current_player()
		_update_ui()
	else:
		start_button.disabled = false
		start_button.visible = true
		_update_ui()
		player_turn_label.text = "Both players ready!"


func _update_ui() -> void:
	var player_pieces = _get_player_pieces(current_player)
	selected_count_label.text = "%d/%d Pieces Placed" % [player_pieces.size(), MAX_PIECES]
	player_turn_label.text = "Player %d - Select Your Pieces" % current_player


func _show_error_feedback(message: String) -> void:
	print()
	push_warning(message) #TODO


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Battlefield.tscn")
<<<<<<< HEAD
	#$Camera2D.enabled = true
	#$HSplitContainer/RightPanel/PreviewLayer/Board.scale.x = float(1.2)
	#$HSplitContainer/RightPanel/PreviewLayer/Board.scale.y = float(1.2)


func _on_buttonmm_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
=======


func get_placement_data() -> Dictionary:
	return {
		"player1_pieces": player1_selected_pieces,
		"player2_pieces": player2_selected_pieces,
		"placed_pieces": placed_pieces
	}
>>>>>>> 907ba928ed2eed172fef555736e1eb0c29e1c884
