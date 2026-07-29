extends Node2D

@export var tile_scene: PackedScene
@export var board_data: BoardData
func generate_and_save() -> void:
	var container = $TileContainer
	
	for y in range(BoardManager.GRID_SIZE):
		for x in range(BoardManager.GRID_SIZE):
			var tile = tile_scene.instantiate()
			tile.name = "Tile_%d_%d" % [x, y]
			tile.position = _get_iso_pos(x, y)
			var cell_index = y * BoardManager.GRID_SIZE + x
			var cell = board_data.cell_heights[cell_index]
			tile.init()
			tile.set_height(cell)
			container.add_child(tile)

func _get_iso_pos(x: int, y: int) -> Vector2:
	return Vector2(
		(x - y) * 32,
		(x + y) * 16
	)

func _ready() -> void:
	generate_and_save()
