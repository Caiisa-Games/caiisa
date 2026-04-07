extends Node2D

@export var tile_scene: PackedScene
@export var board_data: BoardData
@export var piece_data: PieceData # TEMP

var location = Vector2i(0,0)

var tiles: Dictionary = {}
var occupants: Dictionary = {}  # occupant_node -> Vector2i(grid_pos)

func generate() -> void:
	var container = $TileContainer
	
	for y in range(7):
		for x in range(7):
			var tile = tile_scene.instantiate()
			tile.name = "Tile_%d_%d" % [x, y]
			tile.position = _get_iso_pos(x, y)
			
			var cell_index = y * 7 + x
			var cell = board_data.cell_heights[cell_index]
			tile.init()
			tile.set_height(cell)
			
			container.add_child(tile)
			tiles[Vector2i(x, y)] = tile
			
			if x + y == 0:
				tile.set_occupant(piece_data, 1)

func _get_iso_pos(x: int, y: int) -> Vector2:
	return Vector2(
		(x - y) * 64,
		(x + y) * 29
	)
	
func move_occupant(from_tile: Node2D, to_grid_pos: Vector2i, animated: bool = false) -> void:
	var occupant = from_tile.occupant
	
	if not occupant:
		push_error("No occupant to move!")
		return
	
	if not tiles.has(to_grid_pos):
		push_error("Invalid target position!")
		return
	
	var target_tile = tiles[to_grid_pos]
	
	from_tile.clear_occupant()
	
	target_tile.set_occupant(occupant, 1)
	
	#if animated:
		#_animate_occupant(occupant, target_tile)

func _animate_occupant(occupant: Node2D, target_tile: Node2D) -> void:
	var target_pos = target_tile.position
	
	var height = board_data.cell_heights[target_tile.grid_pos.y * 7 + target_tile.grid_pos.x]
	target_pos.y -= height * 10
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(occupant, "position", target_pos, 0.3)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_1:
			var my_occupant = tiles[location]
			location = Vector2i(randi() % 6, randi()%6)
			move_occupant(my_occupant, location)

func _ready() -> void:
	generate()
