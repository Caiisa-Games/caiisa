class_name Card
extends Control

@onready var blank_card = $BlankCard
@onready var card_texture = $CardTexture

@export var piece_data: PieceData

var is_selected: bool = false
var is_disabled: bool = false
var original_scale: Vector2

signal clicked(card: Card)

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
	if piece_data == null: return
	card_texture.texture = piece_data.card_texture
	$BlankCard/VBoxContainer/ProgressBar.value = piece_data.defense * 10
	$BlankCard/VBoxContainer/Label.text = piece_data.name

func _gui_input(event: InputEvent) -> void:
	if is_disabled: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)
			accept_event()

func _on_mouse_entered() -> void:
	if is_disabled: return
	card_texture.visible = false
	blank_card.visible = true

func _on_mouse_exited() -> void:
	card_texture.visible = true
	blank_card.visible = false

func select() -> void:
	is_selected = true
	scale = original_scale * 1.075
	modulate = Color(1.2, 1.2, 1)

func deselect() -> void:
	is_selected = false
	scale = original_scale
	modulate = Color.WHITE

func set_disabled(value: bool) -> void:
	is_disabled = value
	visible = not value
