extends Control


@onready var color_2: ColorRect = $ColorRect2


func _ready() -> void:
	$TextureButton/AnimatedSprite2D.play("default")
func _on_credits_button_pressed() -> void:
	if $Label2.position.y <= -650:
		$Label2.position = Vector2(279, 620)
		create_tween().tween_property($Label2, "position", Vector2(279, -655), 10)     


func _on_exit_button_pressed() -> void:
	color_2.visible = true
	var twe = create_tween()
	twe.tween_property(color_2, "modulate", Color(0, 0, 0, 1), 0.2)
	await twe.finished
	color_2.visible = false
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
	$TextureButton/AnimatedSprite2D.play("default")
