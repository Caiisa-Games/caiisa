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


var sdf = 1
func _ready() -> void:
	randomize()
	#hp.value = randi_range(11, 200)
	hp.value = randi_range(0, 100)
	hp_2.value = hp.value
	#hp_2.value = hp_2.value / 10
	
	power.value = randi_range(0, 100)
	power_2.value = power.value
	knock.value = randi_range(0, 100)
	knock_3.value = knock.value
	
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
