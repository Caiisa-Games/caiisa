class_name Card
extends Control

signal clicked(card: Card)

@export_group("Class Icons")
@export var tank_icon: Texture2D
@export var berserker_icon: Texture2D
@export var util_icon: Texture2D

@export_group("Stat Icons")
@export var hp_icon: Texture2D
@export var atk_icon: Texture2D
@export var kb_icon: Texture2D

@onready var blank_card = $BlankCard
@onready var card_texture = $CardTexture
@onready var glow = $SelectionGlow

var piece_data: PieceData
var is_selected: bool = false
var is_disabled: bool = false
var original_scale: Vector2

func _ready() -> void:
	original_scale = scale
	blank_card.hide()
	glow.hide()

func set_piece_data(data: PieceData) -> void:
	piece_data = data
	_update_display()

func _update_display() -> void:
	if not piece_data: return
	
	card_texture.texture = piece_data.card_texture
	
	$BlankCard/Margin/Content/NameLabel.text = piece_data.name.to_upper()
	$BlankCard/Margin/Content/StatsGrid/HP_Row/Bar.value = piece_data.defense
	$BlankCard/Margin/Content/StatsGrid/ATK_Row/Bar.value = piece_data.power
	$BlankCard/Margin/Content/StatsGrid/KB_Row/Bar.value = piece_data.knockback
	
	$BlankCard/Margin/Content/StatsGrid/HP_Row/Icon.texture = hp_icon
	$BlankCard/Margin/Content/StatsGrid/ATK_Row/Icon.texture = atk_icon
	$BlankCard/Margin/Content/StatsGrid/KB_Row/Icon.texture = kb_icon

	var c_icon = _get_class_icon()
	$BlankCard/Margin/Content/ClassIcon.texture = c_icon

func _get_class_icon() -> Texture2D:
	match piece_data.piece_class:
		PieceData.PieceClass.TANK: return tank_icon
		PieceData.PieceClass.BERSERKER: return berserker_icon
		PieceData.PieceClass.UTILITY: return util_icon
	return null

func select() -> void:
	is_selected = true
	glow.show()
	create_tween().tween_property(self, "scale", original_scale * 1.05, 0.1)

func deselect() -> void:
	is_selected = false
	glow.hide()
	create_tween().tween_property(self, "scale", original_scale, 0.1)

func _on_mouse_entered() -> void:
	if is_disabled: return
	card_texture.hide()
	blank_card.show()

func _on_mouse_exited() -> void:
	if is_disabled: return
	card_texture.show()
	blank_card.hide()

func _gui_input(event: InputEvent) -> void:
	if is_disabled: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
		accept_event()
