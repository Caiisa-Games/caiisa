extends Control

@onready var color_2: ColorRect = $ColorRect2
const SettingsMenuScene := preload("res://scenes/settings_menu.tscn")

func _ready() -> void:
	$TextureButton/AnimatedSprite2D.play("default")
	
func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_texture_button_pressed() -> void:
	color_2.visible = true
	var twe = create_tween()
	twe.tween_property(color_2, "modulate", Color(0, 0, 0, 1), 0.7)
	await twe.finished
	color_2.visible = false
	get_tree().change_scene_to_file("res://scenes/piece_selection.tscn")
	$TextureButton/AnimatedSprite2D.play("new_a")
	
	
func _on_texture_button_mouse_entered() -> void:
	$TextureButton/AnimatedSprite2D.play("hover")
func _on_texture_button_mouse_exited() -> void:
	$TextureButton/AnimatedSprite2D.play("unhover")


func _on_credits_button_pressed() -> void:
	if $Label.visible == false:
		if $Label2.position.y <= -650:
			$Label2.visible = true
			$Label.visible = false
			$Label2.position = Vector2(279, 620)
			create_tween().tween_property($Label2, "position", Vector2(279, -655), 10) 
			$TextureButton.mouse_filter = MOUSE_FILTER_IGNORE
			$ExitButton.mouse_filter = MOUSE_FILTER_IGNORE
			$Settings.mouse_filter = MOUSE_FILTER_IGNORE
			$Settings.get_child(1).visible = false
			await get_tree().create_timer(10).timeout
			$TextureButton.mouse_filter = MOUSE_FILTER_PASS
			$ExitButton.mouse_filter = MOUSE_FILTER_PASS
			$Settings.mouse_filter = MOUSE_FILTER_PASS
			
	elif $Label.visible == true:
		if $Label.position.y <= -650:
			$Label2.visible = false
			$Label.visible = true
			$Label.position = Vector2(279, 620)
			create_tween().tween_property($Label, "position", Vector2(279, -655), 10)
			$TextureButton.mouse_filter = MOUSE_FILTER_IGNORE
			$ExitButton.mouse_filter = MOUSE_FILTER_IGNORE
			$Settings.mouse_filter = MOUSE_FILTER_IGNORE
			$Settings.get_child(1).visible = false
			await get_tree().create_timer(10).timeout
			$TextureButton.mouse_filter = MOUSE_FILTER_PASS
			$ExitButton.mouse_filter = MOUSE_FILTER_PASS
			$Settings.mouse_filter = MOUSE_FILTER_PASS


func _on_settings_button_pressed() -> void:
	var menu : SettingsMenu = SettingsMenuScene.instantiate()
	#menu.closed.connect(_on_settings_closed)
	add_child(menu)
