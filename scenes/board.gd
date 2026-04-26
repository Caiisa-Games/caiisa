class_name BoardManager
extends Node2D

enum Mode { PREVIEW, BATTLE }
enum State { IDLE, SELECTED }

const GRID_SIZE := 7

@export var tile_scene: PackedScene
@export var board_data: BoardData
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

	match current_mode:
		Mode.PREVIEW:
			current_state = State.IDLE
			selected_tile = null
			#_update_placement_indicators(true)
		Mode.BATTLE:
			current_state = State.IDLE
			selected_tile = null
			_update_placement_indicators(false)



func place_piece(piece: PieceData, grid_x: int, grid_y: int, player: int) -> bool:
	var tile = tiles.get(Vector2i(grid_x, grid_y))
	if tile == null:
		return false

	
	if tile.occupant.piece_data != null:


	if tile.occupant != null:

		return false
	


	if current_mode == Mode.PREVIEW:
		var valid_row = 0 if player == 1 else GRID_SIZE - 1
		if grid_y != valid_row:
			return false
	
	tile.occupant.set_data(piece, player)
	return true


func clear_board() -> void:
	for tile in tiles.values():
		if tile.occupant:
			tile.occupant.clear_data()
	occupants.clear()


func get_valid_placement_tiles(player: int) -> Array[Tile]:
	var valid_tiles: Array[Tile] = []
	var valid_row = 0 if player == 1 else GRID_SIZE - 1
	
	for x in range(GRID_SIZE):
		var tile = tiles.get(Vector2i(x, valid_row))
		if tile != null and tile.occupant.piece_data == null:
			valid_tiles.append(tile)
	
	return valid_tiles

func get_tile_at(grid_pos: Vector2i) -> Tile:
	return tiles.get(grid_pos)

func highlight_valid_row(player: int) -> void:
	clear_all_highlights()
	
	var valid_tiles = get_valid_placement_tiles(player)
	for tile in valid_tiles:
		tile.set_placement_highlight(true)


func clear_all_highlights() -> void:
	for tile in tiles.values():
		tile.set_highlight_color(Tile.HighlightColor.MOVE)
		tile.set_placement_highlight(false)

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
	var valid_moves = get_valid_moves(occupant, from_tile)
	
	if not from_tile.occupant:
		return false
	if to_tile not in valid_moves:
		return false
	
	var player = from_tile.occupant.player
	from_tile.occupant.clear_data()
	to_tile.occupant.set_data(occupant, player)
	
	return true


func get_valid_moves(piece: PieceData, from_tile: Tile) -> Array[Tile]:
	var moves: Array[Tile] = []
	var movement = piece.movement if piece.movement else default_movement
	
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
			
			if target_pos.y < 0 or target_pos.x < 0 or target_pos.y >= GRID_SIZE or target_pos.x >= GRID_SIZE:
				break
			
			var target_tile = tiles.get(target_pos)
			if target_tile == null:
				break

			#if target_tile.occupant.piece_data != null:
				#if not movement.can_pass_through_pieces:
					#break
				#else:
					#continue
			
			moves.append(target_tile)
	
	return moves


func _get_tile_at_position(screen_pos: Vector2) -> Tile:
	for tile in tiles.values():
		var dist = screen_pos.distance_to(tile.position)
		if dist < 30:
			return tile
	return null

func _animate_occupant(occupant: Node2D, target_tile: Tile) -> void:
	var target_pos = target_tile.position
	var height = board_data.cell_heights[target_tile.grid_position.y * GRID_SIZE + target_tile.grid_position.x]
	target_pos.y -= height * 10
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(occupant, "position", target_pos, 0.3)


func _ready() -> void:
	generate()
