extends Control

@onready var card_container = $Margin/VBoxContainer/CenterContainer/GridContainer
@onready var details = $Margin/VBoxContainer/MapDetailsPanel

@export var maps: Array[BoardData] = []
var selected: BoardData

func _ready() -> void:
	load_maps()

func load_maps():
	for data in maps:
		var card = preload("res://scenes/map_card.tscn").instantiate() as BoardCard
		card.setup(data)
		card.pressed.connect(select_map.bind(data))
		
		card_container.add_child(card)
		
func select_map(data: BoardData):

	for card in card_container.get_children():
		(card as BoardCard).set_selected(data == card.board_data && selected != data)
	if selected == data:
		selected = null
	else:
		selected = data
