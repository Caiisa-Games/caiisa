extends Node2D
class_name Occupant

signal hp_changed(current_hp: int, max_hp: int)
signal died

var piece_data: PieceData
var current_hp: int
var max_hp: int
var player: int = 0

@onready var sprite = $Sprite2D
@onready var health_bar = $HealthLabel

func _ready() -> void:
	if piece_data:
		_update_stats()

func _update_stats() -> void:
	if not piece_data: return
	
	max_hp = piece_data.defense
	current_hp = max_hp
	
	var p = piece_data.texture.get_height()
	health_bar.position.y -= (p * sprite.scale.y) + 20

	_update_hp()
	
func set_data(data: PieceData, _player: int) -> void:
	piece_data = data
	sprite.texture = data.texture
	player = _player
	
	health_bar.visible = true
	
	_update_stats()
	
func clear_data() -> void:
	piece_data = null
	sprite.texture = null
	player = 0
	
	health_bar.visible = false
	
	_update_stats()

func take_damage(amount: int) -> bool:
	current_hp -= amount
	_update_hp()
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_hp <= 0:
		died.emit()
		return true
	return false

func _update_hp() -> void:
	health_bar.text = "%d/%d" % [current_hp, max_hp]
	
	hp_changed.emit(current_hp, max_hp)
