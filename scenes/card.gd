class_name Card
extends Control

var blank_card: TextureRect
var card_texture: TextureRect

@export var piece_data: PieceData

var is_selected: bool = false
signal card_selected(card: Card)
signal card_deselected(card: Card)

var original_scale: Vector2

func init() -> void:
	card_texture = $CardTexture
	blank_card = $BlankCard
	blank_card.visible = false
	
	original_scale = scale
	
	_update_display()

func set_piece_data(data: PieceData) -> void:
	piece_data = data
	_update_display()
	
func _update_display() -> void:
	if piece_data == null:
		return

	$CardTexture.texture = piece_data.card_texture
	$BlankCard/VBoxContainer/ProgressBar.value = piece_data.defense * 10
	$BlankCard/VBoxContainer/Label.text = piece_data.name
func select() -> void:
	is_selected = true
	scale = original_scale * 1.075
	card_selected.emit(self)

func deselect() -> void:
	is_selected = false
	scale = original_scale
	card_deselected.emit(self)

func set_disabled(value: bool) -> void:
	visible = not value

func _on_card_click(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_selected:
				deselect()
			else:
				select()


func _on_card_mouse_entered() -> void:
	card_texture.visible = false
	blank_card.visible = true

func _on_card_mouse_exited() -> void:
	card_texture.visible = true
	blank_card.visible = false
