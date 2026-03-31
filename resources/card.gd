extends Control

@export var data: PieceData

@onready var hp: ProgressBar = $Button2/TextureRect/ProgressBar
@onready var power: ProgressBar = $Button2/TextureRect/ProgressBar2
@onready var knock: ProgressBar = $Button2/TextureRect/ProgressBar3
@onready var hp_2: ProgressBar = $ColorRect2/ProgressBar4
@onready var power_2: ProgressBar = $ColorRect2/ProgressBar5
@onready var knock_3: ProgressBar = $ColorRect2/ProgressBar6

@onready var coll: ColorRect = $ColorRect
@onready var camer: Camera2D = $ColorRect/Camera2D
@onready var coll_2: ColorRect = $ColorRect2
@onready var label_3: Label = $ColorRect2/Label3
@onready var label_4: Label = $ColorRect2/Label4
@onready var label_5: Label = $ColorRect2/Label5
@onready var label_9: Label = $ColorRect/Label9
@onready var label_8: Label = $ColorRect2/Label8
@onready var label_7: Label = $ColorRect2/Label7
@onready var labelh: Label = $ColorRect/Labelh

func _ready() -> void:
	randomize()
	#hp.value = randi_range(11, 200)
	hp.value = randi_range(1, 10)
	hp_2.value = hp.value
	label_3.text = str(hp_2.value)
	
	power.value = randi_range(5, 150)
	power_2.value = power.value
	power_2.value = int(power_2.value / 2)
	power.value = int(power.value / 2)
	label_4.text = str(power_2.value)
	
	knock.value = randi_range(11, 200)
	knock_3.value = knock.value
	knock_3.value = int(knock_3.value / 2 - 10)
	knock.value = int(knock.value / 3)
	label_5.text = str(knock_3.value)
	
func _process(delta: float) -> void:
	pass

func _on_button_2_pressed() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	if coll.visible == false:
		coll.visible = true
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
