extends Button
class_name BoardCard

var board_data: BoardData
var is_selected := false

var glow: Panel
var original_scale: Vector2

func setup(data: BoardData) -> void:
	board_data = data
	
	original_scale = scale
	
	var name_label: Label = $Panel/VBoxContainer/Name
	var meta_label: Label = $Panel/VBoxContainer/Meta
	glow = $SelectionGlow
	
	name_label.text = board_data.board_name
	meta_label.text = "%dx%d" % [data.grid_size.x, data.grid_size.y]

func set_selected(value: bool):
	is_selected = value

	if value:
		glow.show()
		create_tween().tween_property(self, "scale", original_scale * 1.05, 0.1)
	else:
		glow.hide()
		create_tween().tween_property(self, "scale", original_scale, 0.1)

		# anim
