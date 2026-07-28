class_name Occupant
extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal energy_changed(current_energy: int, max_energy: int)
signal died

@export var piece_data: PieceData = null
@export var max_energy: int = 10
var current_hp: int = 0
var max_hp: int = 0
var player: int = 0
var current_energy: int = 3

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_ui: Node2D = $HealthUI
@onready var health_bar: ProgressBar = $HealthUI/HealthBar
@onready var hp_label: Label = $HealthUI/HPLabel
@onready var energy_bar: ProgressBar = $HealthUI/EnergyBar
@onready var orb: AnimatedSprite2D = $Orb

var _hovered := false
var _selected := false
var _label_timer := 0.0

func _ready() -> void:
	if orb:
		orb.hide()
	
	if health_ui:
		health_ui.visible = false
	
func _process(delta: float) -> void:
	if _label_timer > 0:
		_label_timer -= delta

		if _label_timer <= 0:
			_update_label_visibility()
			
func show_hp_label(duration := 1.5):
	hp_label.visible = true
	_label_timer = duration

func set_selected(value: bool):
	_selected = value
	_update_label_visibility()


func set_hovered(value: bool):
	_hovered = value
	_update_label_visibility()


func _update_label_visibility():
	hp_label.visible = _hovered or _selected
	energy_bar.visible = _hovered or _selected

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

	health_ui.visible = show_health
	_update_label_visibility()
	
	_update_stats()

func clear_data() -> void:
	piece_data = null
	sprite.texture = null
	player = 0
	current_hp = 0
	max_hp = 0

	health_ui.visible = false
	hp_label.text = ""
	
	orb.hide()

	modulate = Color.WHITE

func show_orb() -> void:
	var tile_h = 0
	if get_parent().get_parent() is Tile:
		tile_h = get_parent().get_parent().height_level
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
	show_hp_label()

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
		var tile := get_parent().get_parent() as Tile

		var iso_depth := (tile.grid_position.x + tile.grid_position.y)
		
		var sprite_height := sprite.texture.get_height() * sprite.scale.y

		var tile_height := tile.height_level
		var base_y := -sprite_height - (tile_height * 5.0)-  iso_depth * 2.0
		
		orb.position.y = base_y - 15
		health_ui.position.y = base_y

	_update_hp()
	_update_energy()

func _update_hp() -> void:
	if max_hp <= 0:
		return

	var pct := float(current_hp) / max_hp
	
	hp_label.text = "%d/%d" % [current_hp, max_hp]

	var tween := create_tween()

	tween.tween_property(
		health_bar,
		"value",
		pct * 100.0,
		0.18
	).set_trans(Tween.TRANS_CUBIC)\
	 .set_ease(Tween.EASE_OUT)

	var healthy = Color("#00ff73")
	var warning = Color("#ffe600")
	var danger  = Color("#ff3b3b")

	var color: Color

	if pct > 0.5:
		color = warning.lerp(
			healthy,
			(pct - 0.5) * 2.0
		)
	else:
		color = danger.lerp(
			warning,
			pct * 2.0
		)

	health_bar.modulate = color

	hp_changed.emit(current_hp, max_hp)

func _update_energy() -> void:
	if max_energy <= 0:
		return

	var pct := float(current_energy) / max_energy
	print(pct)
	
	#hp_label.text = "%d/%d" % [current_energy, max_energy]

	var tween := create_tween()

	tween.tween_property(
		energy_bar,
		"value",
		pct * 100.0,
		0.18
	).set_trans(Tween.TRANS_CUBIC)\
	 .set_ease(Tween.EASE_OUT)
	
	energy_bar.modulate = Color(0.158, 0.391, 1.0, 1.0)
#
	#var healthy = Color("#00ff73")
	#var warning = Color("#ffe600")
	#var danger  = Color("#ff3b3b")
#
	#var color: Color
#
	#if pct > 0.5:
		#color = warning.lerp(
			#healthy,
			#(pct - 0.5) * 2.0
		#)
	#else:
		#color = danger.lerp(
			#warning,
			#pct * 2.0
		#)
#
	#health_bar.modulate = color

func _flash_damage() -> void:
	modulate = Color.RED
	var tween := create_tween()
	tween.tween_interval(0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.0)

func gain_energy(amount: int):
	var new_energy = clamp(amount + current_energy, 0, max_energy)
	
	current_energy += new_energy
	energy_changed.emit(current_energy, max_energy)

func spend_energy(amount: int) -> bool:
	if amount > current_energy:
		return false
	
	current_energy -= amount
	energy_changed.emit(current_energy, max_energy)
	return true
