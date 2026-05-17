class_name SettingsMenu
extends CanvasLayer

const CLICK_SFX = preload("res://assets/sound/فشردن دکمه های سنگی.mp3")
const PANEL_OPEN_POS = Vector2(0, 0)
const PANEL_CLOSED_POS = Vector2(0, 300)
const ANIM_DURATION = 0.6

@onready var content_panel: PanelContainer = $PanelContainer

@onready var master_btn: VolumeSlider = $PanelContainer/VBoxContainer/MasterMute
@onready var music_btn: VolumeSlider = $PanelContainer/VBoxContainer/MusicMute
@onready var sfx_btn: VolumeSlider = $PanelContainer/VBoxContainer/SFXMute

@onready var lang_menu: LanguagePicker = $PanelContainer/VBoxContainer/LanguagePicker

var is_animating: bool = false

func _ready() -> void:
	hide()
	content_panel.position = PANEL_CLOSED_POS
	_sync_ui_with_settings()

func _sync_ui_with_settings() -> void:
	master_btn.check_button.button_pressed = not SettingsManager.data.master_muted
	music_btn.check_button.button_pressed = not SettingsManager.data.music_muted
	sfx_btn.check_button.button_pressed = not SettingsManager.data.sfx_muted

func open() -> void:
	show()
	content_panel.modulate.a = 0
	content_panel.position = PANEL_CLOSED_POS
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(content_panel, "position", PANEL_OPEN_POS, ANIM_DURATION)
	tween.tween_property(content_panel, "modulate:a", 1.0, ANIM_DURATION)

func close() -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(content_panel, "position", PANEL_CLOSED_POS, ANIM_DURATION)
	tween.tween_property(content_panel, "modulate:a", 0.0, ANIM_DURATION)
	
	tween.chain().finished.connect(func(): hide())

func _on_mute_toggled(toggled_on: bool, bus_name: String) -> void:
	SettingsManager.set_muted(bus_name, toggled_on)

func _on_language_pressed(locale: String) -> void:
	SettingsManager.set_locale(locale)
	_sync_ui_with_settings()
