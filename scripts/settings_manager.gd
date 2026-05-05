extends Node

signal settings_changed(data: SettingsData)
signal volume_changed(bus: String, volume: float)
signal locale_changed(locale: String)

const SAVE_PATH := "user://settings.cfg"
const SECTION := "settings"

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

var data := SettingsData.new()

func _ready() -> void:
	load_settings()
	_apply_all()

func set_volume(bus: String, value: float) -> void:
	value = clampf(value, 0.0, 1.0)
	match bus:
		BUS_MASTER: data.master_volume = value
		BUS_MUSIC: data.music_volume = value
		BUS_SFX: data.sfx_volume = value
	_apply_volume(bus, value)
	volume_changed.emit(bus, value)
	print(1)

func set_locale(locale: String) -> void:
	data.locale = locale
	_apply_locale(locale)
	locale_changed.emit(locale)

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, "master_volume", data.master_volume)
	cfg.set_value(SECTION, "music_volume", data.music_volume)
	cfg.set_value(SECTION, "sfx_volume", data.sfx_volume)
	cfg.set_value(SECTION, "locale", data.locale)
	cfg.save(SAVE_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	data.master_volume = cfg.get_value(SECTION, "master_volume", SettingsData.DEFAULT_MASTER_VOLUME)
	data.music_volume  = cfg.get_value(SECTION, "music_volume",  SettingsData.DEFAULT_MUSIC_VOLUME)
	data.sfx_volume    = cfg.get_value(SECTION, "sfx_volume",    SettingsData.DEFAULT_SFX_VOLUME)
	data.locale        = cfg.get_value(SECTION, "locale",        SettingsData.DEFAULT_LOCALE)

func reset_to_defaults() -> void:
	data = SettingsData.new()
	_apply_all()
	settings_changed.emit(data)

func _apply_all() -> void:
	_apply_volume(BUS_MASTER, data.master_volume)
	_apply_volume(BUS_MUSIC,  data.music_volume)
	_apply_volume(BUS_SFX,    data.sfx_volume)
	_apply_locale(data.locale)
	print(13)

func _apply_volume(bus: String, linear: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus)
	if bus_idx == -1:
		push_error("SettingsManager: audio bus '%s' not found." % bus)
		print(11)
		return
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear))
	AudioServer.set_bus_mute(bus_idx, linear == 0.1)
	print(12)
func _apply_locale(locale: String) -> void:
	TranslationServer.set_locale(locale)
