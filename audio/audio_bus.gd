extends Node

const FADE_LENGTH: float = 6.0
var audio_path: String = "res://audio"
var audio_players: Dictionary = {}

@onready var game = get_node("/root/Game")

func _ready() -> void:
	# var distortion = AudioEffectDistortion.new()
	# distortion.drive = 2
	# distortion.mode = AudioEffectDistortion.MODE_LOFI
	# var bus = AudioServer.get_bus_index("Master")
	# AudioServer.add_bus_effect(bus, distortion)
	for element in ResourceLoader.list_directory(audio_path + "/sounds"): add_new_player(audio_path + "/sounds", element)
		
func play_audio(type: String) -> void:
	if GlobalScript.current_data.game.muted: return
	if audio_players[type].is_playing(): audio_players[type].stop()
	audio_players[type].play()
	
func play_audio_from_dict(dict: Dictionary) -> void:
	if GlobalScript.current_data.game.muted: return
	var pitch_variation: float = 1.0 - (1.0 - dict["pitch_percent_variation"])
	audio_players[dict["name"]].pitch_scale = dict["pitch"] + randf_range(pitch_variation * -1.0, pitch_variation)
	audio_players[dict["name"]].volume_db = dict["volume_gain"]
	play_audio(dict["name"])
	
func cancel(type: String) -> void:
	if !audio_players.has(type): return
	var time_left: float = audio_players[type].stream.get_length() - audio_players[type].get_playback_position()
	if time_left > 2:
		var new_fade = create_tween()
		new_fade.tween_property(audio_players[type], "volume_db", -70, FADE_LENGTH)
		await game.create_delay_timer(FADE_LENGTH)
	else:
		await game.create_delay_timer(time_left)
	audio_players[type].stop()

# Wszystkie dźwięki ładują się od razu ale konkretny soundtrack przy konkretnym dniu dlatego \/
func add_new_player(path: String, file_name: String) -> void:
	var new_audio_stream: AudioStream = load(path + "/" + file_name)
	var new_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	new_stream_player.stream = new_audio_stream
	audio_players[file_name.get_basename()] = new_stream_player
	add_child(new_stream_player)
