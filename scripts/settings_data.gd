class_name SettingsData
extends Resource

const DEFAULT_MASTER_VOLUME := 1.0
const DEFAULT_MUSIC_VOLUME := 0.8
const DEFAULT_SFX_VOLUME := 0.8
const DEFAULT_LOCALE := "en"

@export var master_volume: float  = DEFAULT_MASTER_VOLUME
@export var music_volume: float  = DEFAULT_MUSIC_VOLUME
@export var sfx_volume: float  = DEFAULT_SFX_VOLUME
@export var locale: String = DEFAULT_LOCALE
