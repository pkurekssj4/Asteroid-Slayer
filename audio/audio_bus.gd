extends Node
var audio_path: String = "res://audio"
var audio_players: Dictionary = {}
const FADE_LENGTH: float = 6.0
const PRE_CONFIG: Dictionary = {
	"rain": {
		"volume_db" = -12
	}
}

func _ready() -> void:
	# var distortion = AudioEffectDistortion.new()
	# distortion.drive = 2
	# distortion.mode = AudioEffectDistortion.MODE_LOFI
	# var bus = AudioServer.get_bus_index("Master")
	# AudioServer.add_bus_effect(bus, distortion)
	for element in ResourceLoader.list_directory(audio_path + "/sounds"): add_new_player(audio_path + "/sounds", element)
		
func play(type: String) -> void:
	if GlobalScript.settings.game_muted: return
	if audio_players[type].is_playing(): audio_players[type].stop()
	audio_players[type].play()

func play_from_dict(dict: Dictionary) -> void:
	if GlobalScript.settings.game_muted: return
	var pitch_variation: float = 1.0 - (1.0 - dict["pitch_percent_variation"])
	audio_players[dict["name"]].pitch_scale = dict["pitch"] + randf_range(pitch_variation * -1.0, pitch_variation)
	audio_players[dict["name"]].volume_db = dict["volume_gain"]
	play(dict["name"])

func stop(type: String) -> void:
	audio_players[type].stop()

func stop_all() -> void:
	for player in audio_players: 
		audio_players[player].stop()
	
func cancel(type: String) -> void:
	# Liczniki muszą należeć do węzła który może zastopować grę, może to robić tylko Game.tscn
	# AudioBus jest autoloadem więc nie może z góry podstawić Game pod zmienną
	var game: Node2D = get_node("/root/Game")
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
	var base_file_name: String = file_name.get_basename()
	audio_players[base_file_name] = new_stream_player
	if base_file_name in PRE_CONFIG:
		for parameter in PRE_CONFIG[base_file_name]:
			audio_players[base_file_name][parameter] = PRE_CONFIG[base_file_name][parameter]
	add_child(new_stream_player)
