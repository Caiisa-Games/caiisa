class_name Tile
extends Node2D

enum HighlightColor { NONE, MOVE, ATTACK, SELF }
enum TileVariant { DARK, LIGHT }

const COLOR_MOVE := Color("4ecdc47d")
const COLOR_ATTACK := Color("ee00007d")
const COLOR_SELF := Color("f8d0007d")

@export var grid_position: Vector2i = Vector2i.ZERO
@export var height_level: int = 0

@export var texture_light: Texture2D
@export var texture_dark: Texture2D

signal tile_clicked(grid_pos: Vector2i)
signal tile_hovered(tile: Tile)
signal tile_exited(tile: Tile)

var base_container: Node2D
var base_sprite: Sprite2D
var height_sprite: Sprite2D
var height_label: Label
var occupant: Occupant
var area_2d: Area2D
var highlight_sprite: Polygon2D
var visual_root: Node2D
var variant: TileVariant = TileVariant.LIGHT

var is_highlighted: bool = false
var is_hovered: bool = false
var hover_tween: Tween

func init() -> void:
	base_container = $VisualRoot/BaseContainer
	base_sprite = $VisualRoot/BaseSprite
	height_sprite = $VisualRoot/HeightSprite
	height_label = $VisualRoot/HeightLabel
	occupant = $VisualRoot/Occupant
	area_2d = $VisualRoot/Area2D
	highlight_sprite = $VisualRoot/HighlightSprite
	visual_root = $VisualRoot

	if highlight_sprite:
		highlight_sprite.visible = false

	_update_visuals()

func set_height(level: int) -> void:
	height_level = level

	for child in base_container.get_children():
		child.queue_free()

	for i in range(level):
		var edge := Sprite2D.new()
		edge.texture = base_sprite.texture
		edge.position = Vector2(0.0, 10.0 - i * 10.0)
		edge.scale = Vector2(0.5, 0.5)
		base_container.add_child(edge)

	_update_visuals()


func set_variant(_variant: TileVariant) -> void:
	variant = _variant
	if height_sprite == null:
		return
	match _variant:
		TileVariant.LIGHT:
			height_sprite.texture = texture_light
		TileVariant.DARK:
			height_sprite.texture = texture_dark


func set_highlight_color(color: HighlightColor = HighlightColor.NONE) -> void:
	if highlight_sprite == null:
		return

	match color:
		HighlightColor.NONE:
			is_highlighted = false
			highlight_sprite.visible = false
		HighlightColor.MOVE:
			is_highlighted = true
			highlight_sprite.color = COLOR_MOVE
			highlight_sprite.visible = true
		HighlightColor.ATTACK:
			is_highlighted = true
			highlight_sprite.color = COLOR_ATTACK
			highlight_sprite.visible = true
		HighlightColor.SELF:
			is_highlighted = true
			highlight_sprite.color = COLOR_SELF
			highlight_sprite.visible = true


func _update_visuals() -> void:
	if height_sprite == null or area_2d == null or highlight_sprite == null:
		return

	var height_offset := height_level * 10

	height_sprite.position.y = -height_offset
	highlight_sprite.position.y = -height_offset

	if occupant:
		occupant.position.y = -height_offset

	if height_label:
		height_label.text = str(height_level)
		height_label.position.y = -height_offset - 20

	area_2d.position.y = -height_offset
		
func _animate_hover(should_hover: bool) -> void:
	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.set_trans(Tween.TRANS_CUBIC)
	hover_tween.set_ease(Tween.EASE_OUT)

	var target_lift := -4.0 if should_hover else 0.0

	hover_tween.tween_property(
		visual_root,
		"position:y",
		target_lift,
		0.15
	)

	var target_glow := Color(1.2, 1.2, 1.2) if should_hover else Color.WHITE
	hover_tween.parallel().tween_property(
		height_sprite,
		"modulate",
		target_glow,
		0.15
	)

func set_hovered(value: bool) -> void:
	if is_hovered == value:
		return
	is_hovered = value
	_animate_hover(value)
	
func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		tile_clicked.emit(grid_position)
		
	elif event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		tile_hovered.emit(self)

func _on_mouse_exited() -> void:
	tile_exited.emit(self)
