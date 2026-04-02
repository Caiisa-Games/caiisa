extends Node2D

@export var grid_position: Vector2i = Vector2i.ZERO
@export var height_level: int = 0

var base_sprite: Sprite2D
var height_sprite: Sprite2D
var height_label: Label
var occupant_node: Node2D

var occupant: PieceData = null
var occupant_player: int = 0
var is_interactive: bool = false

func init() -> void:
	base_sprite = $BaseSprite
	height_sprite = $HeightSprite
	height_label = $HeightLabel
	occupant_node = $Occupant
	
	_update_visuals()

func set_height(level: int) -> void:
	"""0-3"""
	height_level = level
	_update_visuals()


#func set_occupant(piece: PieceData, player: int) -> void:
	#"""Place a piece on this tile."""
	#occupant = piece
	#occupant_player = player
	##_update_occupant_visuals()
#
#
#func clear_occupant() -> void:
	#"""Remove the piece from this tile."""
	#occupant = null
	#occupant_player = 0
	#
	#for child in occupant_node.get_children():
		#child.queue_free()


func set_interactive(enabled: bool) -> void:
	"""Enable/disable click interaction."""
	is_interactive = enabled

func _update_visuals() -> void:
	var height_offset := height_level * 10
	height_sprite.position.y = -height_offset
	
	height_label.text = str(height_level)
	#height_label.visible = false

#func _on_tile_clicked() -> void:
	#print("Tile clicked: ", grid_position, " | Height: ", height_level)
