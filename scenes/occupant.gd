class_name Occupant
extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal died

@export var piece_data: PieceData = null
var current_hp: int = 0
var max_hp: int = 0
var player: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: Label = $HealthLabel
@onready var orb: AnimatedSprite2D = $Orb

func _ready() -> void:
	if health_bar:
		health_bar.visible = false
	if orb:
		orb.hide()

func set_data(data: PieceData, _player: int, _current_hp: int, show_health = true) -> void:
	if not data:
		return
	piece_data = data
	player = _player
	current_hp = _current_hp

	if player == 1:
		sprite.texture = data.texture_white
	elif player == 2:
		sprite.texture = data.texture_black

	health_bar.visible = show_health
	
	_update_stats()

func clear_data() -> void:
	piece_data = null
	sprite.texture = null
	player = 0
	current_hp = 0
	max_hp = 0

	health_bar.visible = false
	health_bar.text = ""
	
	orb.hide()

	modulate = Color.WHITE

func show_orb() -> void:
	var tile_h = 0
	if get_parent() is Tile:
		tile_h = get_parent().height_level
	orb.play("level" + str(tile_h)) 
	orb.show()
	
	_update_stats()
	
func hide_orb() -> void:
	orb.hide()
	
	_update_stats()

func take_damage(amount: int) -> bool:
	if piece_data == null:
		return false

	current_hp = max(current_hp - amount, 0)
	_update_hp()

	_flash_damage()

	if current_hp <= 0:
		await get_tree().create_timer(0.3).timeout 
		
		var fade = create_tween()
		fade.tween_property(self, "modulate:a", 0.0, 0.3)
		
		await fade.finished
		
		died.emit()
		return true
	return false
	
func promote_to(new_data: PieceData) -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.4).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate", Color(2, 2, 2), 0.4)
	
	await tween.finished
	
	set_data(new_data, player, min(current_hp+2, new_data.defense))
	
	var burst = create_tween().set_parallel(true)
	burst.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_ELASTIC)
	burst.tween_property(self, "modulate", Color.WHITE, 0.5)
	
	_update_hp()

func _update_stats() -> void:
	if piece_data == null:
		return

	max_hp = piece_data.defense

	if sprite.texture:
		var sprite_height: float = sprite.texture.get_height() * sprite.scale.y
		var tile_height: int = get_parent().height_level if get_parent() is Tile else 0
		if orb.visible:
			orb.position.y = -sprite_height - tile_height * 10.0
			health_bar.position.y = -47 - sprite_height - tile_height * 9.0
		else:
			health_bar.position.y = -15.0 - sprite_height - tile_height * 10.0

	_update_hp()

func _update_hp() -> void:
	if max_hp <= 0: return
	
	health_bar.text = "%d/%d" % [current_hp, max_hp]

	var pct := float(current_hp) / max_hp

	var color_healthy = Color("#00ff73") # Green
	var color_warning = Color("#ffe600") # Yellow
	var color_danger  = Color("#ff3b3b") # Red

	var target_color: Color
	if pct > 0.5:
		target_color = color_warning.lerp(color_healthy, (pct - 0.5) * 2.0)
	else:
		target_color = color_danger.lerp(color_warning, pct * 2.0)

	var tween = create_tween()
	tween.tween_property(health_bar, "modulate", target_color, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	hp_changed.emit(current_hp, max_hp)

func _flash_damage() -> void:
	modulate = Color.RED
	var tween := create_tween()
	tween.tween_interval(0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.0)
