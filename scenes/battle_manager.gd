class_name BattleManager
extends Node2D

enum Phase { SELECT, MOVE }
enum Turn { PLAYER_1, PLAYER_2 }

@export var mini_queen_data: PieceData

@onready var fade_overlay: ColorRect = $ColorRectr
@onready var loading_bar: ProgressBar = $ProgressBar
@onready var tip_label: Label = $Label
@onready var ui_layer: CanvasLayer = $UI
@onready var board_layer: CanvasLayer = $BoardLayer
@onready var game_over_layer: CanvasLayer = $GameOverLayer
@onready var board: BoardManager = $BoardLayer/Board
@onready var round_label: Label = $UI/TopBar/RoundLabel

@onready var round_label_gm: Label = $GameOverLayer/Control/VBoxContainer/RoundLabel
@onready var winner_label: Label = $GameOverLayer/Control/VBoxContainer/WinnerLabel

@onready var top_bar: Panel = $UI/TopBar
@onready var bottom_panel: Panel = $UI/BottomPanel
@onready var end_turn_btn: Button = $UI/TopBar/EndTurnButton
@onready var player_1_energybar: ProgressBar = $UI/BottomPanel/Player1Energy
@onready var player_2_energybar: ProgressBar = $UI/BottomPanel/Player2Energy

const FADE_IN_DURATION := 3.0
const LOADING_DURATION := 5.0
const FADE_OUT_DURATION := 1.0

var player_1_pieces: Dictionary = {}
var player_2_pieces: Dictionary = {}
var current_turn: Turn = Turn.PLAYER_1
var current_phase: Phase = Phase.SELECT
var selected_piece: Tile = null
var valid_moves: Array[Tile] = []
var round_number: int = 1
var winner: int = 0

const MAX_ENERGY := 10
var player_energy := { Turn.PLAYER_1: 0, Turn.PLAYER_2: 0 }
signal energy_changed(player: int, current: int, max: int)

func _ready() -> void:
	_prepare_scene()
	_start_intro_sequence()

func _prepare_scene() -> void:
	ui_layer.hide()
	board_layer.hide()
	game_over_layer.hide()
	fade_overlay.show()
	fade_overlay.modulate = Color.BLACK
	loading_bar.value = 0
	loading_bar.show()
	var tip_number = randi() % 6 + 1
	tip_label.text = tr("tip" + str(tip_number))
	tip_label.show()

func _start_intro_sequence() -> void:
	var intro = create_tween()
	intro.tween_interval(0.5)
	intro.tween_property(fade_overlay, "modulate:a", 0.0, FADE_IN_DURATION)
	intro.parallel().tween_property(loading_bar, "value", 100.0, LOADING_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	intro.tween_property(fade_overlay, "modulate:a", 1.0, FADE_OUT_DURATION)
	intro.tween_callback(_initialize_game_logic)
	intro.tween_interval(0.5)
	intro.tween_property(fade_overlay, "modulate:a", 0.0, 0.5)
	intro.finished.connect(func(): fade_overlay.hide())

func _initialize_game_logic() -> void:
	loading_bar.hide()
	tip_label.hide()
	ui_layer.show()
	board_layer.show()
	AudioManager.play_music(preload("res://assets/sound/music_game.ogg"))
	player_1_pieces = GameState.player_1_pieces.duplicate()
	player_2_pieces = GameState.player_2_pieces.duplicate()
	_setup_board()
	_connect_board_signals()
	_update_ui()

func _setup_board() -> void:
	board.board_data = GameState.board
	if not board.board_data:
		push_error("No board data")
		return
	board.generate()
	board.set_mode(BoardManager.Mode.BATTLE)
	for pos in player_1_pieces:
		board.place_piece(player_1_pieces[pos], pos.x, pos.y, 1)
	for pos in player_2_pieces:
		board.place_piece(player_2_pieces[pos], pos.x, pos.y, 2)

func _connect_board_signals() -> void:
	for tile in board.tiles.values():
		tile.tile_clicked.connect(_on_tile_clicked)

func _on_tile_clicked(grid_pos: Vector2i) -> void:
	var tile: Tile = board.get_tile_at(grid_pos)
	if not tile: return
	var p_idx = 1 if current_turn == Turn.PLAYER_1 else 2
	match current_phase:
		Phase.SELECT: _handle_selection(tile, p_idx)
		Phase.MOVE: _handle_move(tile)

func _handle_selection(tile: Tile, p_idx: int) -> void:
	if not tile.occupant.piece_data or tile.occupant.player != p_idx:
		_clear_selection()
		return
	AudioManager.play_sfx(preload("res://assets/sound/سلکت کردن مهره برای قبل از حرکت.mp3"))
	selected_piece = tile
	tile.occupant.set_selected(true)
	current_phase = Phase.MOVE
	_update_valid_moves()
	board.highlight_tile(tile, Tile.HighlightColor.SELF)

func _handle_move(tile: Tile) -> void:
	var p_idx = 1 if current_turn == Turn.PLAYER_1 else 2
	if tile in valid_moves:
		if tile.occupant.piece_data and tile.occupant.player != p_idx:
			await _handle_attack(tile)
		else:
			AudioManager.play_sfx(preload("res://assets/sound/فرود اومدن مهره بعد از حرکت.mp3"))
			_execute_dictionary_move(selected_piece, tile)
			board._move_occupant(selected_piece, tile)
			await _check_promotion(tile)
			_end_turn()
	else:
		AudioManager.play_sfx(preload("res://assets/sound/کلیک روی خونه های غیر قابل دسترس به هنگام حرکت مهره.mp3"))
		_clear_selection()

func _handle_attack(tile: Tile) -> void:
	var attacker_tile = selected_piece
	var target_occupant = tile.occupant
	var damage = CombatRules.calculate_damage(
		attacker_tile.occupant.piece_data.power,
		attacker_tile.height_level - tile.height_level,
		false
	)
	var died = await target_occupant.take_damage(damage)
	AudioManager.play_sfx(preload("res://assets/sound/دمیج دادن به مهره ی مقابل.mp3"))
	gain_energy(current_turn, 1)
	if died:
		_handle_died(tile)
		_execute_dictionary_move(attacker_tile, tile)
		board._move_occupant(attacker_tile, tile)
		gain_energy(current_turn, 2)
		await _check_promotion(tile)
	else:
		await _apply_knockback(attacker_tile, tile)
	if winner != 0:
		GameState.winner = winner
		_handle_game_over()
	else:
		_end_turn()

func _apply_knockback(attacker_tile: Tile, target_tile: Tile) -> void:
	var knock_power = attacker_tile.occupant.piece_data.knockback
	if knock_power <= 0: return
	var diff = target_tile.grid_position - attacker_tile.grid_position
	var dir = Vector2i(sign(diff.x), sign(diff.y))
	var start_pos = target_tile.grid_position
	var end_pos = start_pos
	for i in range(knock_power):
		var next = end_pos + dir
		if not board.is_within_bounds(next.x, next.y) or board.get_tile_at(next).occupant.piece_data:
			break
		end_pos = next
	if end_pos != start_pos:
		var end_tile = board.get_tile_at(end_pos)
		_execute_dictionary_move(target_tile, end_tile)
		board._move_occupant(target_tile, end_tile)
		_execute_dictionary_move(attacker_tile, target_tile)
		board._move_occupant(attacker_tile, target_tile)
		await _check_promotion(target_tile)

func _execute_dictionary_move(from: Tile, to: Tile) -> void:
	var dict = player_1_pieces if from.occupant.player == 1 else player_2_pieces
	dict[to.grid_position] = dict[from.grid_position]
	dict.erase(from.grid_position)

func _check_promotion(tile: Tile) -> void:
	if board.should_promote(tile.occupant, tile.grid_position.y, tile.occupant.player):
		await tile.occupant.promote_to(mini_queen_data)

func _handle_died(target_tile: Tile) -> void:
	var target = target_tile.occupant
	var dict = player_1_pieces if target.player == 1 else player_2_pieces
	dict.erase(target_tile.grid_position)
	target.clear_data()
	if player_1_pieces.is_empty(): winner = 2
	elif player_2_pieces.is_empty(): winner = 1

func _update_valid_moves() -> void:
	valid_moves.clear()
	board.clear_all_highlights()
	if not selected_piece: return
	var piece = selected_piece.occupant.piece_data
	var move_data = piece.movement if piece.movement else board.default_movement
	var dirs = []
	match move_data.movement_type:
		MovementData.MovementType.ORTHOGONAL: dirs = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		MovementData.MovementType.DIAGONAL: dirs = [Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(1,1)]
		MovementData.MovementType.BOTH: dirs = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(1,1)]
	for d in dirs:
		for r in range(1, move_data.move_range + 1):
			var tp = selected_piece.grid_position + (d * r)
			if not board.is_within_bounds(tp.x, tp.y): break
			var target = board.get_tile_at(tp)
			if target.occupant.piece_data:
				if target.occupant.player != selected_piece.occupant.player:
					valid_moves.append(target)
					target.set_highlight_color(Tile.HighlightColor.ATTACK)
				break
			valid_moves.append(target)
			target.set_highlight_color(Tile.HighlightColor.MOVE)

func _end_turn() -> void:
	if player_energy[current_turn] < 2:
		return
	player_energy[current_turn] -= 2
	if current_turn == Turn.PLAYER_1:
		current_turn = Turn.PLAYER_2
	else:
		current_turn = Turn.PLAYER_1
		round_number += 1
	_clear_selection()

func _clear_selection() -> void:
	if selected_piece:
		selected_piece.occupant.set_selected(false)
	selected_piece = null
	current_phase = Phase.SELECT
	valid_moves.clear()
	board.clear_all_highlights()
	_update_ui()

func _update_ui() -> void:
	var p_idx = 1 if current_turn == Turn.PLAYER_1 else 2
	player_1_energybar.value = player_energy[Turn.PLAYER_1] * 10
	player_2_energybar.value = player_energy[Turn.PLAYER_2] * 10
	end_turn_btn.disabled = player_energy[current_turn] < 2
	for t in board.tiles.values():
		if t.occupant.piece_data:
			if t.occupant.player == p_idx: t.occupant.show_orb()
			else: t.occupant.hide_orb()
	round_label.text = tr("current_round") % round_number

func _handle_game_over() -> void:
	game_over_layer.show()
	AudioManager.play_sfx(preload("res://assets/sound/صفحه ی ویکتوری و برد.mp3"))
	winner_label.text = tr("player_won") % winner
	round_label_gm.text = tr("current_round") % round_number
	
	top_bar.hide()
	bottom_panel.hide()
	
func gain_energy(player: int, amount: int) -> void:
	player_energy[player] = clamp(player_energy[player] + amount, 0, MAX_ENERGY)
	energy_changed.emit(player, player_energy[player], MAX_ENERGY)
	
func spend_energy(player: int, amount: int) -> bool:
	if player_energy[player] < amount:
		return false
	
	player_energy[player] -= amount
	energy_changed.emit(player, player_energy[player], MAX_ENERGY)
	return true

func _on_end_turn_button_pressed() -> void:
	_end_turn()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_replay_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/piece_selection.tscn")
