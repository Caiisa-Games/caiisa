extends Control


func _ready() -> void:
	$BoxContainer/StartButton.pressed.connect(on_start_pressed)
	$BoxContainer/QuitButton.pressed.connect(on_quit_pressed)

func on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://card.tscn")

func on_quit_pressed() -> void:
	get_tree().quit()
