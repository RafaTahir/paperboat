extends Node
## File-based, web-safe original soundtrack. Call begin() from the Begin gesture.
## Web export packages an audio-clock ramp adapter for SampleNodeBus gains.
## Preserve these gradual mix targets; lowering the update frequency alone
## would create larger audible steps in the unpatched browser backend.

const AUDIO_PATH := "res://assets/audio/"
const LOOP_NAMES := ["music_calm", "music_motion", "music_arrival", "courtyard_ambience", "water_lap", "rain_chain"]
const EFFECT_NAMES := ["gust", "paper_flutter", "hull_bump_1", "hull_bump_2", "petal_brush", "leaf_drip_1", "leaf_drip_2", "leaf_drip_3", "wind_chime", "arrival_accent"]

var started := false
var music_level := 0.7
var effects_level := 0.8
var muted := false
var arrived := false
var _loops: Dictionary = {}
var _streams: Dictionary = {}
var _gains: Dictionary = {}
var _voices: Array[AudioStreamPlayer] = []
var _voice_index := 0
var _rng := RandomNumberGenerator.new()
var _gust_was_held := false
var _drip_time := 3.8
var _chime_time := 24.0
var _flutter_time := 0.0
var _bump_time := 0.0
var _brush_time := 0.0


func _ready() -> void:
	_rng.seed = 171126
	for sound_name in LOOP_NAMES:
		var stream := load(AUDIO_PATH + sound_name + ".ogg") as AudioStreamOggVorbis
		if stream == null:
			push_error("Missing original audio: " + sound_name)
			continue
		stream.loop = true
		var player := AudioStreamPlayer.new()
		player.name = sound_name
		player.stream = stream
		if OS.has_feature("web"):
			player.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE
		player.volume_db = -80.0
		add_child(player)
		_loops[sound_name] = player
		_gains[sound_name] = 0.0
	for sound_name in EFFECT_NAMES:
		_streams[sound_name] = load(AUDIO_PATH + sound_name + ".ogg")
	for i in range(8):
		var voice := AudioStreamPlayer.new()
		if OS.has_feature("web"):
			voice.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE
		voice.name = "DetailVoice%d" % i
		add_child(voice)
		_voices.append(voice)


func begin() -> void:
	if started:
		return
	started = true
	# Each aligned stem is started in this frame, without timers or stream effects.
	for sound_name in LOOP_NAMES:
		if _loops.has(sound_name):
			(_loops[sound_name] as AudioStreamPlayer).play(0.0)
	_apply_levels()


func reset_audio() -> void:
	for player in _loops.values():
		(player as AudioStreamPlayer).stop()
	for voice in _voices:
		voice.stop()
	started = false
	arrived = false
	_gust_was_held = false
	_rng.seed = 171126
	_drip_time = 3.8
	_chime_time = 24.0
	_flutter_time = 0.0
	for sound_name in _gains:
		_gains[sound_name] = 0.0
	begin()


func update_mix(speed: float, gust: bool, progress: float, position: Vector3, delta: float) -> void:
	if not started:
		return
	var movement := clampf(speed / 0.23, 0.0, 1.0)
	var shelter := 1.0 - clampf(position.distance_to(Vector3(2.7, 0, 2.5)) / 1.25, 0.0, 1.0)
	_blend_gain("music_calm", 0.48, delta, 2.0)
	_blend_gain("music_motion", 0.07 + movement * 0.24, delta, 2.6)
	_blend_gain("music_arrival", (0.43 if arrived else smoothstep(0.65, 1.0, progress) * 0.30), delta, 4.0)
	_blend_gain("courtyard_ambience", lerpf(0.42, 0.29, shelter), delta, 1.8)
	_blend_gain("water_lap", 0.13 + movement * 0.32, delta, 0.6)
	var chain_distance := position.distance_to(Vector3(-3.35, 0, -1.6))
	_blend_gain("rain_chain", clampf(1.0 - chain_distance / 3.5, 0.0, 1.0) * 0.34, delta, 1.4)
	_flutter_time = maxf(0.0, _flutter_time - delta)
	_bump_time = maxf(0.0, _bump_time - delta)
	_brush_time = maxf(0.0, _brush_time - delta)
	if gust and not _gust_was_held:
		_play("gust", 0.48)
	if gust and movement > 0.15 and _flutter_time <= 0:
		_play("paper_flutter", 0.30)
		_flutter_time = _rng.randf_range(1.3, 2.5)
	_gust_was_held = gust
	_drip_time -= delta
	if _drip_time <= 0:
		_play("leaf_drip_%d" % _rng.randi_range(1, 3), 0.26, _rng.randf_range(0.94, 1.06))
		_drip_time = _rng.randf_range(4.0, 9.5)
	_chime_time -= delta
	if _chime_time <= 0:
		_play("wind_chime", 0.20)
		_chime_time = _rng.randf_range(28.0, 45.0)
	_apply_levels()


func arrive() -> void:
	if arrived:
		return
	arrived = true
	_play("arrival_accent", 0.62)


func play_bump() -> void:
	if _bump_time > 0:
		return
	_bump_time = 0.5
	_play("hull_bump_%d" % _rng.randi_range(1, 2), 0.36)


func play_brush() -> void:
	if _brush_time > 0:
		return
	_brush_time = 0.7
	_play("petal_brush", 0.40)


func set_levels(music: float, effects: float, is_muted: bool) -> void:
	music_level = clampf(music, 0.0, 1.0)
	effects_level = clampf(effects, 0.0, 1.0)
	muted = is_muted
	_apply_levels()
	# Re-apply to playing details, so mute covers every layer immediately.
	for voice in _voices:
		var base_gain := float(voice.get_meta("base_gain", 0.0))
		voice.volume_db = _db(base_gain * effects_level)


func _blend_gain(sound_name: String, target_gain: float, delta: float, seconds: float) -> void:
	_gains[sound_name] = lerpf(float(_gains.get(sound_name, 0.0)), target_gain, 1.0 - exp(-delta / seconds))


func _apply_levels() -> void:
	for sound_name in _loops:
		var level := music_level if str(sound_name).begins_with("music_") else effects_level
		(_loops[sound_name] as AudioStreamPlayer).volume_db = _db(float(_gains.get(sound_name, 0.0)) * level)


func _play(sound_name: String, gain: float, pitch: float = 1.0) -> void:
	if not started or _voices.is_empty() or not _streams.has(sound_name):
		return
	var voice := _voices[_voice_index]
	_voice_index = (_voice_index + 1) % _voices.size()
	voice.stop()
	voice.stream = _streams[sound_name] as AudioStream
	voice.pitch_scale = pitch
	voice.set_meta("base_gain", gain)
	voice.volume_db = _db(gain * effects_level)
	voice.play()


func _db(gain: float) -> float:
	return -80.0 if muted or gain < 0.0001 else linear_to_db(gain)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_UNPAUSED:
		var should_pause := what == NOTIFICATION_PAUSED
		for player in _loops.values():
			(player as AudioStreamPlayer).stream_paused = should_pause
		for voice in _voices:
			voice.stream_paused = should_pause
