class_name PieceSelection
extends Control

const MAX_PIECES := 3

enum FlowStep { P1_SELECT, P2_SELECT, P1_PLACE, P2_PLACE }

@onready var selection_overlay = $UICanvas/MainUI/SelectionOverlay
@onready var selection_grid = $UICanvas/MainUI/SelectionOverlay/CenterContainer/VBoxContainer/SelectionGrid
@onready var confirm_selection_btn = $UICanvas/MainUI/SelectionOverlay/CenterContainer/VBoxContainer/ConfirmBtn

@onready var card_flow = $UICanvas/MainUI/HSplitContainer/LeftPanel/VBoxContainer/ScrollContainer/MarginContainer/CardFlow
@onready var confirm_placement_btn = $UICanvas/MainUI/HSplitContainer/LeftPanel/VBoxContainer/StartButton

@onready var board = $BoardCanvas/Board

@onready var selected_count_label = $UICanvas/MainUI/HSplitContainer/RightPanel/SelectedCountLabel
@onready var player_turn_label = $UICanvas/MainUI/HSplitContainer/RightPanel/PlayerTurnLabel
@onready var remove_button = $UICanvas/MainUI/HSplitContainer/RightPanel/Buttons/RemoveButton

@export var available_pieces: Array[PieceData] = []

var current_step: FlowStep = FlowStep.P1_SELECT
var current_player: int = 1
var player1_hand: Array[PieceData] = []
var player2_hand: Array[PieceData] = []
var player1_placed: Dictionary = {}
var player2_placed: Dictionary = {}

var selected_card: Card = null
var selected_tile: Tile = null

func _ready() -> void:
	board.set_mode(BoardManager.Mode.PREVIEW)
	_connect_board_signals()
	_set_remove_btn_status(false)
	_start_selection_phase()
	
	confirm_selection_btn.pressed.connect(_on_confirm_selection_pressed)
	confirm_placement_btn.pressed.connect(_on_confirm_placement_pressed)

func _connect_board_signals() -> void:
	for tile in board.tiles.values():
		tile.tile_clicked.connect(_on_tile_clicked)


func _start_selection_phase() -> void:
	board.hide()
	selection_overlay.show()
	confirm_selection_btn.disabled = true
	
	for child in selection_grid.get_children():
		child.queue_free()
	
	var card_scene = load("res://scenes/card.tscn")
	for piece in available_pieces:
		var card = card_scene.instantiate() as Card
		card.init()
		card.set_piece_data(piece)
		card.clicked.connect(_on_card_interacted)
		selection_grid.add_child(card)
	_update_ui()

func _start_placement_phase() -> void:
	selection_overlay.hide()
	board.show()
	selected_card = null
	confirm_placement_btn.visible = true
	confirm_placement_btn.disabled = true
	
	for child in card_flow.get_children():
		child.queue_free()
	
	var card_scene = load("res://scenes/card.tscn")
	for piece in _get_current_hand():
		var card = card_scene.instantiate() as Card
		card.init()
		card.set_piece_data(piece)
		card.clicked.connect(_on_card_interacted)
		card_flow.add_child(card)
	_update_ui()

func _on_card_interacted(card: Card) -> void:
	if current_step <= FlowStep.P2_SELECT:
		var hand = _get_current_hand()
		if card.is_selected:
			card.deselect()
			hand.erase(card.piece_data)
		elif hand.size() < MAX_PIECES:
			card.select()
			hand.append(card.piece_data)
		
		confirm_selection_btn.disabled = (hand.size() != MAX_PIECES)
	else:
		if card.is_selected:
			card.deselect()
			selected_card = null
			board.clear_all_highlights()
		else:
			for child in card_flow.get_children():
				child.deselect()
			card.select()
			selected_card = card
			selected_tile = null
			board.clear_all_highlights()
			board.highlight_tiles(get_valid_placement_tiles(current_player))
	_update_ui()

func _on_confirm_selection_pressed() -> void:
	AudioManager.play_sfx(preload("res://assets/sound/بعد از انتخاب همه ی کارت های یک پلیر.mp3"))
	if current_step == FlowStep.P1_SELECT:
		current_step = FlowStep.P2_SELECT
		current_player = 2
		_start_selection_phase()
	else:
		current_step = FlowStep.P1_PLACE
		current_player = 1
		_start_placement_phase()

func _on_confirm_placement_pressed() -> void:
	AudioManager.play_sfx(preload("res://assets/sound/بعد از انتخاب همه ی کارت های یک پلیر.mp3"))
	if current_step == FlowStep.P1_PLACE:
		current_step = FlowStep.P2_PLACE
		current_player = 2
		_start_placement_phase()
	else:
		GameState.player_1_pieces = player1_placed
		GameState.player_2_pieces = player2_placed
		get_tree().change_scene_to_file("res://scenes/battle.tscn")

func _on_tile_clicked(grid_pos: Vector2i) -> void:
	if current_step < FlowStep.P1_PLACE: return
	var tile = board.get_tile_at(grid_pos)
	
	if tile.occupant.piece_data != null and tile != selected_tile:
		_handle_board_piece_click(tile)
	elif selected_tile != null:
		_handle_repositioning(tile)
	elif selected_card != null and _is_valid_placement_row(grid_pos.y):
		_place_new_piece(grid_pos, tile)

func _place_new_piece(grid_pos: Vector2i, tile: Tile) -> void:
	if board.place_piece(selected_card.piece_data, grid_pos.x, grid_pos.y, current_player):
		_get_current_placed_dict()[grid_pos] = selected_card.piece_data
		selected_card.set_disabled(true)
		selected_card.deselect()
		selected_card = null
		board.clear_all_highlights()
		_update_ui()
		confirm_placement_btn.disabled = (_get_current_placed_dict().size() != MAX_PIECES)

func _get_current_hand(): return player1_hand if current_player == 1 else player2_hand
func _get_current_placed_dict(): return player1_placed if current_player == 1 else player2_placed
func _is_valid_placement_row(y): return y == (0 if current_player == 1 else board.GRID_SIZE - 1)

func get_valid_placement_tiles(player: int):
	var tiles: Array[Tile] = []
	var y = 0 if player == 1 else board.GRID_SIZE - 1
	for x in range(board.GRID_SIZE):
		var t = board.get_tile_at(Vector2i(x, y))
		if t and t.occupant.piece_data == null: tiles.append(t)
	return tiles

func _update_ui() -> void:
	player_turn_label.text = "Player %d Turn" % current_player
	if current_step <= FlowStep.P2_SELECT:
		selected_count_label.text = "Hand: %d/%d" % [_get_current_hand().size(), MAX_PIECES]
	else:
		selected_count_label.text = "Placed: %d/%d" % [_get_current_placed_dict().size(), MAX_PIECES]

func _set_remove_btn_status(v):
	remove_button.visible = v
	remove_button.disabled = !v

func _handle_board_piece_click(tile: Tile) -> void:
	if selected_card: selected_card.deselect()
	selected_card = null
	selected_tile = tile
	_set_remove_btn_status(true)
	board.clear_all_highlights()
	board.highlight_tiles(get_valid_placement_tiles(current_player))
	board.highlight_tile(tile, Tile.HighlightColor.SELF)

func _handle_repositioning(target_tile: Tile) -> void:
	if target_tile != selected_tile and _is_valid_placement_row(target_tile.grid_position.y) and target_tile.occupant.piece_data == null:
		var dict = _get_current_placed_dict()
		dict[target_tile.grid_position] = dict[selected_tile.grid_position]
		dict.erase(selected_tile.grid_position)
		board._move_occupant(selected_tile, target_tile)
	selected_tile = null
	_set_remove_btn_status(false)
	board.clear_all_highlights()

func _on_remove_button_pressed() -> void:
	if selected_tile:
		var data = selected_tile.occupant.piece_data
		_get_current_placed_dict().erase(selected_tile.grid_position)
		selected_tile.occupant.clear_data()
		for child in card_flow.get_children():
			if child is Card and child.piece_data == data:
				child.set_disabled(false)
		board.clear_all_highlights()
		_set_remove_btn_status(false)
		selected_tile = null
		_update_ui()
		confirm_placement_btn.disabled = true
