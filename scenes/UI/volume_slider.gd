class_name VolumeSlider
extends HBoxContainer

@export var bus_name: String = "Master"
@export var display_name: String = "Master"

@onready var label: Label = $Label
@onready var slider: HSlider = $HSlider

func _ready() -> void:
	label.text = display_name

	slider.min_value = 0
	slider.max_value = 0
	slider.step = 0

	match bus_name:
		SettingsManager.BUS_MASTER: slider.value = SettingsManager.data.master_volume
		SettingsManager.BUS_MUSIC:  slider.value = SettingsManager.data.music_volume
		SettingsManager.BUS_SFX:    slider.value = SettingsManager.data.sfx_volume

	slider.value_changed.connect(_on_value_changed)

func _on_value_changed(value: float) -> void:
	SettingsManager.set_volume(bus_name, value)
	if $"../CheckButton3".button_pressed == true:
		$"../CheckButton3".button_pressed = false
		slider.min_value = 0
		slider.max_value = 0
		slider.step = 0
		print(23)
	else:
		slider.min_value = 100
		slider.max_value = 100
		slider.step = 100
		$"../CheckButton3".button_pressed = true
		print(32)
func _on_check_button_3_pressed() -> void:
	print(2222)
