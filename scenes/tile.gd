class_name Tile
extends Node2D

@export var grid_position: Vector2i = Vector2i.ZERO
@export var height_level: int = 0
@export var highlight_color: Color = Color("#4ECDC4")

signal tile_clicked(grid_pos: Vector2i)

var base_container: Node2D
var base_sprite: Sprite2D
var height_sprite: Sprite2D
var height_label: Label
var occupant: Occupant
var area_2d = Area2D
var highlight_sprite: Polygon2D

var is_interactive: bool = false
var is_highlighted: bool = false


func init() -> void:
	base_container = $BaseContainer
	base_sprite = $BaseSprite
	height_sprite = $HeightSprite
	height_label = $HeightLabel
	occupant = $Occupant
	area_2d = $Area2D
	highlight_sprite = $HighlightSprite

	if highlight_sprite:
		highlight_sprite.visible = false
	
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

func set_interactive(enabled: bool) -> void:
	is_interactive = enabled

func _update_visuals() -> void:
	var height_offset := height_level * 10
	height_sprite.position.y = -height_offset
	area_2d.position.y = -height_offset
	highlight_sprite.position.y = -height_offset
	$Occupant/Sprite2D.position.y = -height_offset - 44
	
	height_label.text = str(height_level)
	#height_label.visible = false
	
func set_placement_highlight(enabled: bool) -> void:
	is_highlighted = enabled
	if highlight_sprite:
		highlight_sprite.visible = enabled

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tile_clicked.emit(grid_position)
