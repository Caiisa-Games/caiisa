extends Button

@onready var color_rect: ColorRect = $ColorRect




func _on_pressed() -> void:
	if color_rect.visible == false:
		color_rect.visible = true
	elif color_rect.visible == true:
		color_rect.visible = false
