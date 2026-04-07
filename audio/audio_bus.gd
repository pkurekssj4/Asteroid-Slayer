extends Node

const FADE_LENGTH: float = 6.0
const audio_streams: Dictionary = {
	"blessings_music": preload("res://audio/sounds/blessings_music.wav"),
	"critical_hit": preload("res://audio/sounds/critical_hit.mp3"),
	"asteroids_flashing": preload("res://audio/sounds/asteroids_flashing.mp3"),
	"asteroids_finished_flashing": preload("res://audio/sounds/asteroids_finished_flashing.mp3"),
	"laser_attack": preload("res://audio/sounds/laser_attack.wav"),
	"pulse_barrier_attack": preload("res://audio/sounds/pulse_barrier_attack.wav"),
	"cannon_reload_finished": preload("res://audio/sounds/cannon_reload_finished.mp3"),
	"ordinary_projectile_launch": preload("res://audio/sounds/ordinary_projectile_launch.mp3"),
	"trigger_jam": preload("res://audio/sounds/trigger_jam.mp3"),
	"barrel_cooldown": preload("res://audio/sounds/barrel_cooldown.mp3"),
	"ability_ready": preload("res://audio/sounds/ability_ready.mp3"),
	"gravity_well_projectile_launch": preload("res://audio/sounds/gravity_well_projectile_launch.mp3"),
	"orbital_strike_projectile_launch": preload("res://audio/sounds/orbital_strike_projectile_launch.mp3"),
	"ordinary_projectile_explosion": preload("res://audio/sounds/ordinary_projectile_explosion.wav"),
	"orbital_strike_projectile_explosion": preload("res://audio/sounds/orbital_strike_projectile_explosion.mp3"),
	"asteroid_damaged": preload("res://audio/sounds/asteroid_damaged.mp3"),
	"plasma_asteroid_destroyed": preload("res://audio/sounds/plasma_asteroid_destroyed.mp3"),
	"asteroid_destroyed": preload("res://audio/sounds/asteroid_destroyed.mp3"),
	"electric_discharge": preload("res://audio/sounds/electric_discharge.mp3"),
	"reload_finished": preload("res://audio/sounds/cannon_reload_finished.mp3"),
	"power_influx": preload("res://audio/sounds/power_influx.wav"),
	"day_5_soundtrack": preload("res://audio/sounds/day_5_soundtrack.mp3"),
	"day_15_soundtrack": preload("res://audio/sounds/day_15_soundtrack.mp3"),
	"fever": preload("res://audio/sounds/fever.mp3"),
	"structure_damaged": preload("res://audio/sounds/structure_damaged.mp3"),
	"shield_damaged": preload("res://audio/sounds/shield_damaged.mp3")
}

var audio_players: Dictionary = {}

@onready var game = get_node("/root/Game")

func _ready() -> void:
	# var distortion = AudioEffectDistortion.new()
	# distortion.drive = 2
	# distortion.mode = AudioEffectDistortion.MODE_LOFI
	# var bus = AudioServer.get_bus_index("Master")
	# AudioServer.add_bus_effect(bus, distortion)
	for stream in audio_streams:
		var new_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
		new_stream_player.stream = audio_streams[stream]
		audio_players[stream] = new_stream_player
		add_child(new_stream_player)
		
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
