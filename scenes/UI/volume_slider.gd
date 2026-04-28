class_name VolumeSlider
extends HBoxContainer

@export var bus_name: String = "Master"
@export var display_name: String = "Master"

@onready var label: Label = $Label
@onready var slider: HSlider = $HSlider

func _ready() -> void:
	label.text = display_name

	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01

	match bus_name:
		SettingsManager.BUS_MASTER: slider.value = SettingsManager.data.master_volume
		SettingsManager.BUS_MUSIC:  slider.value = SettingsManager.data.music_volume
		SettingsManager.BUS_SFX:    slider.value = SettingsManager.data.sfx_volume

	slider.value_changed.connect(_on_value_changed)

func _on_value_changed(value: float) -> void:
	SettingsManager.set_volume(bus_name, value)
