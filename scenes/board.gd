extends Node2D

@export var tile_scene: PackedScene
@export var board_data: BoardData
@export var piece_data: PieceData # TEMP

var location = Vector2i(0,0)

var tiles: Dictionary = {}
var occupants: Dictionary = {}  # occupant_node -> Vector2i(grid_pos)
var selected_tile: Node2D = null

enum State { IDLE, SELECTED }
var current_state: State = State.IDLE

var default_movement := MovementData.new()

func generate() -> void:
	var container = $TileContainer
	for y in range(7):
		for x in range(7):
			var tile = tile_scene.instantiate()
			tile.name = "Tile_%d_%d" % [x, y]
			tile.position = _get_iso_pos(x, y)

			var cell_index = y * 7 + x
			var height = board_data.cell_heights[cell_index]

			tile.init()
			tile.set_height(height)
			tile.grid_position = Vector2i(x, y)
			
			tile.tile_clicked.connect(_on_tile_clicked)

			container.add_child(tile)
			tiles[Vector2i(x, y)] = tile
			
			if x + y == 0:
				tile.set_occupant(piece_data, 1)

func _get_iso_pos(x: int, y: int) -> Vector2:
	return Vector2(
		(x - y) * 64,
		(x + y) * 29
	)

func _on_tile_clicked(grid_pos: Vector2i) -> void:
	var tile = tiles[grid_pos]
	
	match current_state:
		State.IDLE:
			if tile.occupant != null:
				selected_tile = tile
				current_state = State.SELECTED
		
		State.SELECTED:
			if tile == selected_tile:
				_deselect()
			elif tile.occupant == null:
				if _move_occupant(selected_tile, tile):
					_deselect()
			else:
				selected_tile = tile

func _deselect() -> void:
	selected_tile = null
	current_state = State.IDLE

func _move_occupant(from_tile: Node2D, to_tile: Node2D) -> bool:
	var occupant = from_tile.occupant

	var valid_moves = get_valid_moves(occupant, from_tile)
	if to_tile not in valid_moves:
		return false

	from_tile.occupant = null
	to_tile.occupant = occupant

	from_tile.clear_occupant()
	
	to_tile.set_occupant(occupant, 1)
	
	return true

	#_animate_occupant(occupant, to_tile)

func _animate_occupant(occupant: Node2D, target_tile: Node2D) -> void:
	var target_pos = target_tile.position
	
	var height = board_data.cell_heights[target_tile.grid_pos.y * 7 + target_tile.grid_pos.x]
	target_pos.y -= height * 10
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(occupant, "position", target_pos, 0.3)

func _get_tile_at_position(screen_pos: Vector2) -> Node2D:
	for tile in tiles.values():
		var dist = screen_pos.distance_to(tile.position)
		if dist < 30:
			return tile
	return null

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventKey and event.is_pressed():
		#if event.keycode == KEY_1:
			#var my_occupant = tiles[location]
			#location = Vector2i(randi() % 6, randi()%6)
			#_move_occupant(my_occupant, tiles[location])


func get_valid_moves(piece: PieceData, from_tile: Node2D) -> Array[Node2D]:
	var moves: Array[Node2D] = []
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
			if (target_pos.y < 0 or target_pos.x < 0) or (target_pos.y > 6 or target_pos.x > 6):
				break
			var target_tile = tiles[Vector2i(target_pos.x, target_pos.y)]
			
			if target_tile == null:
				break
			
			if target_tile.occupant != null and not movement.can_pass_through_pieces:
				break
			
			if target_tile.occupant != null and movement.can_pass_through_pieces:
				continue
			
			moves.append(target_tile)
	
	return moves

func _ready() -> void:
	generate()
