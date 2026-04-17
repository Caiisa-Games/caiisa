class_name BoardData
extends Resource

@export var board_name: String = "Unnamed Board"
@export var grid_size: Vector2i = Vector2i(7, 7)

@export var cell_heights: Array[int] = []

func _ready() -> void:
	if cell_heights.is_empty():
		cell_heights.resize(49)
		cell_heights.fill(0)
