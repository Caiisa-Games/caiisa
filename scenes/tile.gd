extends Node2D

@export var grid_position: Vector2i = Vector2i.ZERO
@export var height_level: int = 0

var base_container: Node2D
var base_sprite: Sprite2D
var height_sprite: Sprite2D
var height_label: Label
var occupant_node: Sprite2D

var occupant: PieceData = null
var occupant_player: int = 0
var is_interactive: bool = false

func init() -> void:
	base_container = $BaseContainer
	base_sprite = $BaseSprite
	height_sprite = $HeightSprite
	height_label = $HeightLabel
	occupant_node = $Occupant/Sprite2D
	
	_update_visuals()

func set_height(level: int) -> void:
	"""0-3"""
	height_level = level
	for child in base_container.get_children():
		child.queue_free()

	for i in range(level):
		var edge = Sprite2D.new()
		edge.texture = base_sprite.texture
		
		edge.position.y = 10 -(i*10)
		edge.position.x = 0
		edge.scale.x = 0.5
		edge.scale.y = 0.5
		base_container.add_child(edge)
	
	_update_visuals()


func set_occupant(piece: PieceData, player: int) -> void:
	occupant = piece
	occupant_node.texture = piece.texture
	occupant_player = player
	#_update_occupant_visuals()
	
func clear_occupant() -> void:
	occupant = null
	occupant_player = 0
	
	for child in occupant_node.get_children():
		child.queue_free()

func set_interactive(enabled: bool) -> void:
	is_interactive = enabled

func _update_visuals() -> void:
	var height_offset := height_level * 10
	height_sprite.position.y = -height_offset
	occupant_node.position.y = -height_offset
	
	height_label.text = str(height_level)
	#height_label.visible = false

#func _on_tile_clicked() -> void:
	#print("Tile clicked: ", grid_position, " | Height: ", height_level)
