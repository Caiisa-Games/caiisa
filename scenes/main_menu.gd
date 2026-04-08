extends Control


var gh := false
func _ready() -> void:
	$BoxContainer/StartButton.pressed.connect(on_start_pressed)
	$BoxContainer/QuitButton.pressed.connect(on_quit_pressed)

func on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/piece_selection.tscn")

func on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_button_pressed() -> void:
	if _on_credits_button_pressed:
		$Label2.position = Vector2(375, 645)
		create_tween().tween_property($Label2, "position", Vector2(375, -840), 25).set_trans(Tween.TRANS_SINE)     
		$BoxContainer/creditsButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$BoxContainer/StartButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$BoxContainer/QuitButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
		await get_tree().create_timer(25).timeout
		$BoxContainer/creditsButton.mouse_filter = Control.MOUSE_FILTER_PASS
		$BoxContainer/StartButton.mouse_filter = Control.MOUSE_FILTER_PASS
		$BoxContainer/QuitButton.mouse_filter = Control.MOUSE_FILTER_PASS
