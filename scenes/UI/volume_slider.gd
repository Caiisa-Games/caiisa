class_name VolumeSlider
extends HBoxContainer

@export var bus_name: String = "Master"
@export var display_name: String = "Master"

@onready var label: Label = $Label
@onready var check_button: CheckButton = $CheckButton

func _ready() -> void:
	label.text = display_name

	match bus_name:
		SettingsManager.BUS_MASTER: check_button.button_pressed = not SettingsManager.data.master_muted
		SettingsManager.BUS_MUSIC: check_button.button_pressed = not SettingsManager.data.music_muted
		SettingsManager.BUS_SFX: check_button.button_pressed = not SettingsManager.data.sfx_muted

func _on_check_button_toggled(toggled_on: bool) -> void:
	SettingsManager.set_muted(bus_name, not toggled_on)
