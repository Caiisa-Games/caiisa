class_name Unit
extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal unit_died(unit: Unit)

var max_hp: int
var current_hp: int
var power: int
var defense: int
var attack_range: int
var knockback_dist: int

var piece_data: PieceData

func _ready() -> void:
	_update_stats()
	hp_changed.emit(current_hp, max_hp)

func _update_stats() -> void:
	if piece_data == null:
		return
		
	max_hp = piece_data.defense
	current_hp = max_hp
	power = piece_data.power
	defense = piece_data.defense
	attack_range = 1
	knockback_dist = piece_data.knockback

func take_damage(amount: int) -> bool:
	current_hp -= amount
	
	_flash_damage()
	
	hp_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		unit_died.emit(self)
		return true
	
	return false

func _flash_damage() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func apply_knockback(target_unit: Unit) -> void:
	pass
