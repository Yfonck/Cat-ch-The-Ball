extends Node

const SFX := {
	&"click": preload("res://assets/audio/ui_click.wav"),
	&"jump": preload("res://assets/audio/cat_jump.wav"),
	&"bounce": preload("res://assets/audio/ball_bounce.wav"),
	&"game_over": preload("res://assets/audio/game_over.wav"),
}

const MUSIC := {
	&"menu": preload("res://assets/audio/music_menu.wav"),
	&"game": preload("res://assets/audio/music_game.wav"),
}

const SFX_VOLUME_DB := -4.0
const MUSIC_VOLUME_DB := -11.0
const SFX_POOL_SIZE := 8

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0
var _music: AudioStreamPlayer
var _current_track: StringName = &""
var _music_token: int = 0

func _ready() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.volume_db = SFX_VOLUME_DB
		add_child(player)
		_sfx_players.append(player)

	_music = AudioStreamPlayer.new()
	_music.volume_db = MUSIC_VOLUME_DB
	_music.finished.connect(_on_music_finished)
	add_child(_music)

func play_sfx(sound: StringName, pitch_variation: float = 0.0) -> void:
	if not SFX.has(sound):
		return
	var player: AudioStreamPlayer = _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()
	player.stream = SFX[sound]
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()

func play_music(track: StringName) -> void:
	if not MUSIC.has(track):
		return
	if track == _current_track and _music.playing and _music.stream == MUSIC[track]:
		return

	_current_track = track
	_music_token += 1
	var token := _music_token

	if _music.playing:
		var tween := create_tween()
		tween.tween_property(_music, "volume_db", -40.0, 0.15)
		await tween.finished
		if token != _music_token:
			return

	_music.stream = MUSIC[track]
	_music.volume_db = MUSIC_VOLUME_DB
	_music.play()

func stop_music(fade: bool = true) -> void:
	_current_track = &""
	_music_token += 1
	if not fade or not _music.playing:
		_music.stop()
		return
	var token := _music_token
	var tween := create_tween()
	tween.tween_property(_music, "volume_db", -40.0, 0.15)
	await tween.finished
	if token == _music_token:
		_music.stop()

func _on_music_finished() -> void:
	if _music.stream != null:
		_music.play()
