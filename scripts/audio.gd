extends Node

var music_player := AudioStreamPlayer.new()
var sfx_players: Array = []

const SFX_PLAYER_COUNT := 8

func _ready():
	music_player.name = "MusicPlayer"
	add_child(music_player)

	for i in SFX_PLAYER_COUNT:
		var p := AudioStreamPlayer.new()
		p.name = "SFXPlayer_%d" % i
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)

func play_music(sound: AudioStream, bus: String = "Music", loop: bool = true):
	if loop and sound is AudioStreamOggVorbis:
		sound.loop = true

	music_player.bus = bus
	music_player.stream = sound
	music_player.play()

func play_sfx(sound: AudioStream, bus: String = "SFX"):
	for p in sfx_players:
		if not p.playing:
			p.bus = bus
			p.stream = sound
			p.play()
			return

	sfx_players[0].stop()
	sfx_players[0].bus = bus
	sfx_players[0].stream = sound
	sfx_players[0].play()

func stop_music():
	music_player.stop()
	music_player.stream = null

func stop_all_sfx():
	for p in sfx_players:
		p.stop()
		p.stream = null
