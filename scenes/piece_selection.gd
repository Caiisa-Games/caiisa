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

@export var available_pieces: Array[PieceData] = []

func _ready() -> void:
	board.set_mode(BoardManager.Mode.PREVIEW)
	
	start_button.visible = false
	
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
	var selected_card: Card = null
	for child in card_flow.get_children():
		if child is Card and child.is_selected:
			selected_card = child
			break
	
	if selected_card == null:
		return
	
	var valid_row = 0 if current_player == 1 else 6
	
	if tile.grid_position.y != valid_row:
		return
	
	if tile.occupant != null:
		return
	
	var success = board.place_piece(
		selected_card.piece_data,
		tile.grid_position.x,
		tile.grid_position.y,
		current_player
	)
	
	if success:
		placed_pieces.append({
			"piece": selected_card.piece_data,
			"tile": tile,
			"player": current_player,
			"card": selected_card
		})
		
		selected_card.deselect()
		
		var player_pieces = placed_pieces.filter(func(p): return p.player == current_player)
		
		if player_pieces.size() >= MAX_PIECES:
			_finish_player_placement()
		else:
			_update_ui()


func _finish_player_placement() -> void:
	if current_player == 1:
		current_player = 2
		
		_create_cards_for_current_player()
		
		_update_ui()
	else:
		start_button.disabled = false
		start_button.visible = true


func _update_ui() -> void:
	var player_pieces = placed_pieces.filter(func(p): return p.player == current_player)
	selected_count_label.text = "%d/%d" % [player_pieces.size(), MAX_PIECES]
	player_turn_label.text = "Player %d" % current_player


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Battlefield.tscn")
	#$Camera2D.enabled = true
	#$HSplitContainer/RightPanel/PreviewLayer/Board.scale.x = float(1.2)
	#$HSplitContainer/RightPanel/PreviewLayer/Board.scale.y = float(1.2)


func _on_buttonmm_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
