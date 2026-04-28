class_name SettingsMenu
extends CanvasLayer

signal closed

@onready var btn_apply : Button = $PanelContainer/VBoxContainer/Buttons/ApplyButton
@onready var btn_reset : Button = $PanelContainer/VBoxContainer/Buttons/ResetButton
@onready var btn_back  : Button = $PanelContainer/VBoxContainer/Buttons/BackButton

func _ready() -> void:
	#print(get_tree_string_pretty())
	btn_apply.pressed.connect(_on_apply)
	btn_reset.pressed.connect(_on_reset)
	btn_back.pressed.connect(_on_back)

func _on_apply() -> void:
	SettingsManager.save_settings()

func _on_reset() -> void:
	SettingsManager.reset_to_defaults()
	get_tree().reload_current_scene()

func _on_back() -> void:
	SettingsManager.save_settings()
	closed.emit()
	queue_free()
