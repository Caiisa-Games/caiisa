extends Control

@onready var color_2: ColorRect = $ColorRect2
const SettingsMenuScene := preload("res://scenes/settings_menu.tscn")

var is_settings_open := false

func _ready() -> void:
	$TextureButton/AnimatedSprite2D.play("default")
	
	AudioManager.play_music(preload("res://assets/sound/music_menu.ogg"))
	
func _on_exit_button_pressed() -> void:
	AudioManager.play_sfx(preload("res://assets/sound/فشردن دکمه های سنگی.mp3"))
	get_tree().quit()

func _on_texture_button_pressed() -> void:
	AudioManager.play_music(preload("res://assets/sound/music_transition.ogg"), "Music", false)
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
	if $CreditsLabel.position.y > -650:
		return

	AudioManager.play_sfx(preload("res://assets/sound/فشردن دکمه های سنگی.mp3"))
	$CreditsLabel.visible = true
	$CreditsLabel.position = Vector2(279, 620)
	create_tween().tween_property($CreditsLabel, "position", Vector2(279, -655), 10) 
	$TextureButton.mouse_filter = MOUSE_FILTER_IGNORE
	$ExitButton.mouse_filter = MOUSE_FILTER_IGNORE
	await get_tree().create_timer(10).timeout
	$TextureButton.mouse_filter = MOUSE_FILTER_PASS
	$ExitButton.mouse_filter = MOUSE_FILTER_PASS

func _on_settings_button_pressed() -> void:
	AudioManager.play_sfx(preload("res://assets/sound/فشردن دکمه های سنگی.mp3"))
	if is_settings_open:
		return
	var menu : SettingsMenu = SettingsMenuScene.instantiate()
	menu.closed.connect(_on_settings_closed)
	add_child(menu)
	is_settings_open = true

func _on_settings_closed() -> void:
	is_settings_open = false


func _on_settings_hover() -> void:
	$SettingsButton/AnimatedSprite2D.play("hover")

func _on_settings_exit() -> void:
	$SettingsButton/AnimatedSprite2D.play("unhover")
