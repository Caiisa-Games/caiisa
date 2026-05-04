class_name Occupant
extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal died

var piece_data: PieceData = null
var current_hp: int = 0
var max_hp: int = 0
var player: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: Label = $HealthLabel

func _ready() -> void:
	if health_bar:
		health_bar.visible = false

func set_data(data: PieceData, _player: int, _current_hp: int) -> void:
	if not data:
		return
	piece_data = data
	player = _player
	current_hp = _current_hp

	if player == 1:
		sprite.texture = data.texture_white
	elif player == 2:
		sprite.texture = data.texture_black

	health_bar.visible = true
	_update_stats()


func clear_data() -> void:
	piece_data = null
	sprite.texture = null
	player = 0
	current_hp = 0
	max_hp = 0

	health_bar.visible = false
	health_bar.text = ""

	modulate = Color.WHITE


func take_damage(amount: int) -> bool:
	if piece_data == null:
		return false

	current_hp = max(current_hp - amount, 0)
	_update_hp()

	_flash_damage()

	if current_hp <= 0:
		died.emit()
		return true
	return false

func _update_stats() -> void:
	if piece_data == null:
		return

	max_hp  = piece_data.defense

	if sprite.texture:
		var sprite_height: float = sprite.texture.get_height() * sprite.scale.y
		var tile_height: int = get_parent().height_level if get_parent() is Tile else 0
		health_bar.position.y = -15.0 - sprite_height - tile_height * 10.0

	_update_hp()

func _update_hp() -> void:
	health_bar.text = "%d/%d" % [current_hp, max_hp]
	hp_changed.emit(current_hp, max_hp)

func _flash_damage() -> void:
	modulate = Color.RED
	var tween := create_tween()
	tween.tween_interval(0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.0)
