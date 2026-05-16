class_name Card
extends Control

signal clicked(card: Card)

@export_group("Class Icons")
@export var tank_icon: Texture2D
@export var berserker_icon: Texture2D
@export var util_icon: Texture2D

@onready var blank_card: TextureRect = $BlankCard
@onready var card_texture: TextureRect = $CardTexture
@onready var selection_glow: Panel = get_node_or_null("SelectionGlow")

@onready var name_label: Label = $BlankCard/Margin/Content/Header/NameLabel
@onready var piece_texture: TextureRect = $BlankCard/Margin/Content/Header/PieceTexture
@onready var class_icon_rect: TextureRect = $BlankCard/Margin/Content/ClassIcon
@onready var class_icon_rect_front: TextureRect = $CardTexture/Panel/ClassIcon

@onready var defense_bar: ProgressBar = $BlankCard/Margin/Content/Stats/DefenseBar
@onready var power_bar: ProgressBar = $BlankCard/Margin/Content/Stats/PowerBar

var piece_data: PieceData
var is_selected: bool = false
var is_disabled: bool = false
var original_scale: Vector2

func _ready() -> void:
	original_scale = scale
	blank_card.visible = false
	if selection_glow: selection_glow.visible = false
	if piece_data:
		_update_display()

func set_piece_data(data: PieceData) -> void:
	piece_data = data
	if is_node_ready():
		_update_display()

func _update_display() -> void:
	if not piece_data: return
	
	card_texture.texture = piece_data.card_texture
	piece_texture.texture = piece_data.texture_white
	name_label.text = piece_data.name
	defense_bar.value = piece_data.defense * 10
	power_bar.value = piece_data.power * 10
	
	match piece_data.piece_class:
		PieceData.PieceClass.TANK:
			class_icon_rect.texture = tank_icon
		PieceData.PieceClass.BERSERKER:
			class_icon_rect.texture = berserker_icon
		PieceData.PieceClass.UTILITY:
			class_icon_rect.texture = util_icon
	
	class_icon_rect_front.texture = class_icon_rect.texture

func select() -> void:
	if is_selected: return
	is_selected = true
	
	_animate_selection(true)
	AudioManager.play_sfx(preload("res://assets/sound/فشردن دکمه های سنگی.mp3"))

func deselect() -> void:
	if not is_selected: return
	is_selected = false
	
	_animate_selection(false)

func _animate_selection(should_select: bool) -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if should_select:
		tween.tween_property(self, "scale", original_scale * 1.075, 0.2)
		tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.1), 0.2)
		if selection_glow: selection_glow.show()
	else:
		tween.tween_property(self, "scale", original_scale, 0.2)
		tween.tween_property(self, "modulate", Color.WHITE, 0.2)
		if selection_glow: selection_glow.hide()

func set_disabled(value: bool) -> void:
	is_disabled = value
	modulate = Color(0.3, 0.3, 0.3, 0.8) if value else Color.WHITE
	mouse_default_cursor_shape = Control.CURSOR_ARROW if value else Control.CURSOR_POINTING_HAND

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
	create_tween().tween_property(self, "position:y", position.y - 5, 0.1)

func _on_mouse_exited() -> void:
	if is_disabled: return
	card_texture.visible = true
	blank_card.visible = false
	create_tween().tween_property(self, "position:y", position.y + 5, 0.1)
