class_name BoardManager
extends Node2D

enum Mode { PREVIEW, BATTLE }
enum State { IDLE, SELECTED }

const GRID_SIZE := 7
@onready var color_rectfd: ColorRect = $ColorRectfd

@export var tile_scene: PackedScene
@export var board_data: BoardData
@export var show_base: bool = true
#@export var piece_data: PieceData

var tiles: Dictionary = {}  # Vector2i(x,y) -> Tile
var occupants: Dictionary = {}  # occupant_node -> Vector2i(grid_pos)
var selected_tile: Tile = null
var current_state: State = State.IDLE
var current_mode: Mode = Mode.BATTLE

var default_movement := MovementData.new()

func set_mode(mode: Mode) -> void:
	current_mode = mode
	
	current_state = State.IDLE
	selected_tile = null

func place_piece(piece: PieceData, grid_x: int, grid_y: int, player: int) -> bool:
	var tile = tiles.get(Vector2i(grid_x, grid_y))
	if tile == null:
		return false
	
	if tile.occupant.piece_data != null:
		return false
	
	if current_mode == Mode.PREVIEW:
		var valid_row = 0 if player == 1 else GRID_SIZE - 1
		if grid_y != valid_row:
			return false
	var show_health = current_mode == Mode.BATTLE
	tile.occupant.set_data(piece, player, piece.defense, show_health)
	return true


func clear_board() -> void:
	for tile in tiles.values():
		if tile.occupant:
			tile.occupant.clear_data()
	occupants.clear()

func get_tile_at(grid_pos: Vector2i) -> Tile:
	return tiles.get(grid_pos)

func highlight_tiles(color_tiles: Array[Tile], color: Tile.HighlightColor = Tile.HighlightColor.MOVE) -> void:
	clear_all_highlights()
	
	for tile in color_tiles:
		tile.set_highlight_color(color)
		
func highlight_tile(tile: Tile, color: Tile.HighlightColor = Tile.HighlightColor.MOVE, clear = false) -> void:
	if clear:
		clear_all_highlights()
	tile.set_highlight_color(color)

func clear_all_highlights() -> void:
	for tile in tiles.values():
		tile.set_highlight_color(Tile.HighlightColor.NONE)

func generate() -> void:
	var container = $TileContainer
	
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var tile = tile_scene.instantiate()
			tile.name = "Tile_%d_%d" % [x, y]
			tile.position = _get_iso_pos(x, y)
			
			var cell_index = y * GRID_SIZE + x
			var height = board_data.cell_heights[cell_index]
			
			tile.init()
			tile.set_height(height)
			tile.grid_position = Vector2i(x, y)
			
			var is_light = (x + y) % 2 == 0
			if is_light:
				tile.set_variant(Tile.TileVariant.LIGHT)
			else:
				tile.set_variant(Tile.TileVariant.DARK)
			
			container.add_child(tile)
			tiles[Vector2i(x, y)] = tile
	
	#if piece_data != null:
		#tiles[Vector2i(0, 0)].set_occupant(piece_data, 1)


func _get_iso_pos(x: int, y: int) -> Vector2:
	return Vector2(
		(x - y) * 64,
		(x + y) * 29
	)

func _deselect() -> void:
	selected_tile = null
	current_state = State.IDLE

func _move_occupant(from_tile: Tile, to_tile: Tile) -> bool:
	var occupant = from_tile.occupant.piece_data
	if not from_tile.occupant:
		return false
		
	#_animate_occupant(from_tile.occupant, to_tile)
	
	var show_health = current_mode == Mode.BATTLE
	
	var player = from_tile.occupant.player
	var hp = from_tile.occupant.current_hp
	from_tile.occupant.clear_data()
	to_tile.occupant.set_data(occupant, player, hp, show_health)
	
	return true

func _get_tile_at_position(screen_pos: Vector2) -> Tile:
	for tile in tiles.values():
		var dist = screen_pos.distance_to(tile.position)
		if dist < 30:
			return tile
	return null

func _animate_occupant(occupant: Occupant, target_tile: Tile) -> void:
	var target_pos = target_tile.occupant.global_position
	print("CURRENT POS: ", occupant.global_position)
	print("NEW POS: ", target_pos)
	var height = board_data.cell_heights[target_tile.grid_position.y * GRID_SIZE + target_tile.grid_position.x]
	target_pos.y -= height * 10
	occupant.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	
	var center_offset = Vector2(0, 0)
	
	target_pos += center_offset
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(occupant, "global_position", target_pos, 0.3)
	
func should_promote(occupant: Occupant, row: int, player: int) -> bool:
	if occupant.piece_data.name != "pawn":
		return false
	if player == 1 and row == GRID_SIZE - 1:
		return true
	if player == 2 and row == 0:
		return true
		
	return false

func _ready() -> void:
	if not show_base:
		$BoardBase.hide()
	generate()
