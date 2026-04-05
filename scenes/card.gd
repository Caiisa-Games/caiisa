extends Control

@export var data: PieceData

@onready var hp: ProgressBar = $Button2/TextureRect/ProgressBar
@onready var power: ProgressBar = $Button2/TextureRect/ProgressBar2
@onready var knock: ProgressBar = $Button2/TextureRect/ProgressBar3
@onready var hp_2: ProgressBar = $ColorRect2/ProgressBar4
@onready var power_2: ProgressBar = $ColorRect2/ProgressBar5
@onready var knock_3: ProgressBar = $ColorRect2/ProgressBar6

@onready var texture_sprite: Sprite2D = $Button2/TextureRect/TextureSprite
@onready var title_label: Label = $Button2/TextureRect/TitleLabel

@onready var coll: ColorRect = $ColorRect
@onready var camer: Camera2D = $ColorRect/Camera2D
@onready var coll_2: ColorRect = $ColorRect2
@onready var coll_3: ColorRect = $ColorRect3

@onready var label_3: Label = $ColorRect2/Label3
@onready var label_4: Label = $ColorRect2/Label4
@onready var label_5: Label = $ColorRect2/Label5
@onready var label_9: Label = $ColorRect/Label9
@onready var label_8: Label = $ColorRect2/Label8
@onready var label_7: Label = $ColorRect2/Label7
@onready var labelh: Label = $ColorRect/Labelh

@onready var button_2: Button = $Button2

var is_dragging = false
var drag_offset = Vector2.ZERO

func _ready() -> void:
	if not data: return

	hp.value = data.defense
	hp_2.value = hp.value
	label_3.text = str(hp_2.value)
	
	power.value = data.power
	power_2.value = power.value

	label_4.text = str(power_2.value)
	
	knock.value = data.knockback
	knock_3.value = knock.value
	label_5.text = str((knock_3.value + 20) / 100)
	
	texture_sprite.texture = data.texture
	title_label.text = data.name
	
func _on_button_2_pressed() -> void:
	if coll_3.visible == false:
		coll_3.visible = true
		if coll.visible == true:
			coll_3.visible = false
	else:
		coll_3.visible = false
		
func _on_button_pressed() -> void:
	if coll.visible == false:
		coll.visible = true
		if coll_3.visible == true:
			coll_3.visible = false
		else:
			coll_3.visible = false
	#else:
	elif coll.visible == true and coll_2.visible == true:
		coll_2.visible = false
	else:
		coll.visible = false
		
func _on_button_5_pressed() -> void:
	if camer.visible == false:
		camer.enabled = true
		camer.visible = true
	else:
		camer.enabled = false
		camer.visible = false


func _on_button_4_pressed() -> void:
	if coll_2.visible == false:
		coll_2.visible = true


func _on_button_3_pressed() -> void:
	if coll_2.visible == true:
		coll_2.visible = false


func _on_button_6_pressed() -> void:
	if label_9.visible == false:
		label_9.visible = true
		label_8.visible = true
		label_7.visible = false
		labelh.visible = false
	else:
		label_9.visible = false
		label_8.visible = false
		label_7.visible = true
		labelh.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_offset = get_global_mouse_position() - global_position
				get_viewport().set_input_as_handled()
			else:
				is_dragging = false
				get_viewport().set_input_as_handled()
	
	elif event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position() - drag_offset
		get_viewport().set_input_as_handled()
