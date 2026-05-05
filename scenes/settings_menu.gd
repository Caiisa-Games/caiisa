class_name SettingsMenu
extends CanvasLayer

signal closed

var data := SettingsData.new()
#@onready var btn_apply: Button = $PanelContainer/VBoxContainer/Buttons/ApplyButton
#@onready var btn_reset: Button = $PanelContainer/VBoxContainer/Buttons/ResetButton
#@onready var btn_back: Button = $PanelContainer/VBoxContainer/Buttons/BackButton
#
#func _ready() -> void:
	##print(get_tree_string_pretty())
	#btn_apply.pressed.connect(_on_apply)
	#btn_reset.pressed.connect(_on_reset)
	#btn_back.pressed.connect(_on_back)
	#$Button/AnimatedSprite2D.play("default")
#func _on_apply() -> void:
	#SettingsManager.save_settings()
#
#func _on_reset() -> void:
	#SettingsManager.reset_to_defaults()
	#get_tree().reload_current_scene()
#
#func _on_back() -> void:
	#SettingsManager.save_settings()
	#closed.emit()
	#queue_free()
	#pass
	
	
func _on_check_button_pressed() -> void:
	if $Button/PanelContainer/VBoxContainer/Label2/CheckButton.button_pressed == false:
		var jh = load("")
		AudioManager.play_music(jh)
	else:
		var sg = load("res://assets/sound/music_menu.ogg")
		AudioManager.play_music(sg)


func _on_button_mouse_entered() -> void:
	$Button/AnimatedSprite2D.play("hoverr")


func _on_button_mouse_exited() -> void:
	$Button/AnimatedSprite2D.play("elseee")

	#$"../../..".position.x = 483
	#$"../../..".position.y = 210
	#$"../..".position.x = 104
	#$"../..".position.y = 63
func _on_button_pressed() -> void:
	AudioManager.play_sfx(preload("res://assets/sound/فشردن دکمه های سنگی.mp3"))
	if $Button/PanelContainer.visible == false:
		$Button/PanelContainer.visible = true
		create_tween().tween_property($Button/PanelContainer, "position", Vector2(104, -515), 3).set_trans(Tween.TRANS_BACK)     
	else:
		$Button/PanelContainer.visible = false
		$Button/PanelContainer.position.y = 104


func _on_check_button_3_pressed() -> void:
	if $Button/PanelContainer/VBoxContainer/Label3/CheckButton3.button_pressed == false:
		#var dd = AudioStreamPlayer.new()
		AudioManager
	else:
		pass
