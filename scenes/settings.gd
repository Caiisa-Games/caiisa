extends Button


@onready var color_rec: ColorRect = $ColorRectf



@onready var chec: CheckButton = $ColorRect/VBoxContainer/Label3/CheckButton


func _on_pressed() -> void:
	if color_rec.visible == false:
		color_rec.visible = true
	elif color_rec.visible == true:
		color_rec.visible = false


func _on_check_button_pressed() -> void:
	$"../Label".visible = true
	$ColorRectf/VBoxContainer.visible = false
	$ColorRectf/VBoxContainer2.visible = true

func _ready() -> void:
	if $".".mouse_filter == MOUSE_FILTER_IGNORE:
		color_rec.visible = false
	elif $".".mouse_filter == MOUSE_FILTER_PASS:
		color_rec.visible = true
	
	#self.connect("item_se")

func _on_check_button_6_pressed() -> void:
	$ColorRectf/VBoxContainer.visible = true
	$ColorRectf/VBoxContainer2.visible = false


func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		$ColorRectf/VBoxContainer.visible = true
		$ColorRectf/VBoxContainer2.visible = false
		$"../Label".visible = false
	elif index == 1:
		$"../Label".visible = true
		$ColorRectf/VBoxContainer.visible = false
		$ColorRectf/VBoxContainer2.visible = true
