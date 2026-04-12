extends Control

@export var data: PieceData

@onready var texture_sprite: TextureRect = $VBoxContainer/TextureRect
@onready var title_label: Label = $VBoxContainer/Label
@onready var hp: ProgressBar = $VBoxContainer/ProgressBar


func _ready() -> void:
	if not data: return

	hp.value = data.defense
	
	texture_sprite.texture = data.texture
	title_label.text = data.name


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Battlefield.tscn")
