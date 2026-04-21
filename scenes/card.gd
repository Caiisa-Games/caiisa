class_name Card
extends TextureRect

@export var piece_data: PieceData

var is_selected: bool = false
signal card_selected(card: Card)
signal card_deselected(card: Card)


func _ready() -> void:
	$DescriptionPanel.visible = false
	_update_display()
	#var popup = get_popup()
	#get_popup().connect("index_hover", self, "_on_hover")

func set_piece_data(data: PieceData) -> void:
	piece_data = data
	_update_display()
	
func _update_display() -> void:
	if piece_data == null:
		return
	
	$VBoxContainer/ProgressBar.value = piece_data.defense
	$VBoxContainer/TextureRect.texture = piece_data.texture
	$VBoxContainer/Label.text = piece_data.name

func select() -> void:
	is_selected = true
	$SelectionHighlight.visible = true
	card_selected.emit(self)


func deselect() -> void:
	is_selected = false
	$SelectionHighlight.visible = false
	card_deselected.emit(self)

func set_disabled(value: bool) -> void:
	visible = not value

func _on_card_click(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_selected:
				deselect()
			else:
				select()

#func _on_card_mouse_entered() -> void:
	#$DescriptionPanel.visible = true
#
#
#func _on_card_mouse_exited() -> void:
	#$DescriptionPanel.visible = false

func _on_menu_button_2_focus_entered() -> void:
	print(55)