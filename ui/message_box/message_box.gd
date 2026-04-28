extends Control
var current_part = 1
var fade_duration = 0.3
var current_waving_phase: float = 0.0
var shader_phase_thresholds: Array[int] = [195, 213]
var waving_phase_per_sec: float = 2.0
var waving_multiplier: float = 1.0
# Do prawidlowego odtwarzania dzwieku niezaleznie od FPS. Np na 30 FPS dzwiek odpala sie z lagiem ale to naturalna kolejnosc rzeczy w tym przypadku.
var unveiling_sound_playback_interval_sec: float = 0.015
var time_left_to_play_unveiling_sound: float
var sender: String
var place: String
var message_source: Dictionary
var characters_unveiling_per_sec: int = 300
var quick_characters_unveiling_per_sec: int = 900
var unveiling_sound_cfg: Dictionary
signal ready_to_continue

@onready var audio_bus: Node = get_node("/root/Game/AudioBus")

func _ready() -> void:
	time_left_to_play_unveiling_sound = unveiling_sound_playback_interval_sec
	audio_bus.play_audio("message")
	$Place.text = place
	$Sender.text = "Send from: " + sender
	reset_box_to_new_message("part_1")
	$Message.visible_ratio = 0
	global_position = get_viewport_rect().size / 2
	global_position -= $Borders.size / 2
	current_waving_phase = shader_phase_thresholds[0]
	$Borders.material.set("shader_parameter/phase", current_waving_phase)
	modulate.a = 0
	set_process(false)
	await fade_scene(1)
	set_process(true)
	unveiling_sound_cfg = {
		"pitch_percent_variation" = 0.0,
		"volume_gain" = 0,
		"name" = "message_unveiling",
		"pitch" = 1.0
	}
	
func _process(delta: float) -> void:
	if current_waving_phase >= shader_phase_thresholds[1]: waving_multiplier = -1.0
	elif current_waving_phase <= shader_phase_thresholds[0]: waving_multiplier = 1.0
	current_waving_phase += (waving_phase_per_sec * delta) * waving_multiplier
	$Borders.material.set("shader_parameter/phase", current_waving_phase)
	if $Message.visible_ratio < 1:
		var characters_to_unveil: int
		if Input.is_action_pressed("fire"):
			characters_to_unveil = floor(quick_characters_unveiling_per_sec * delta)
			unveiling_sound_cfg.pitch = 5.5
		else:
			characters_to_unveil = floor(characters_unveiling_per_sec * delta)
			unveiling_sound_cfg.pitch = 4.0
		if characters_to_unveil < 1: characters_to_unveil = 1
		$Message.visible_characters += characters_to_unveil
		time_left_to_play_unveiling_sound -= delta
		if time_left_to_play_unveiling_sound < 0:
			time_left_to_play_unveiling_sound = unveiling_sound_playback_interval_sec
			audio_bus.play_audio_from_dict(unveiling_sound_cfg)
		if $Message.visible_ratio >= 1: $ContinueButton.show()
			
func reset_box_to_new_message(part_string: String) -> void:
	$ContinueButton.hide()
	$Message.visible_characters = 0
	$Message.text = message_source[part_string]
 
func _on_continue_button_pressed() -> void:
	current_part += 1
	var part_string: String =  "part_" + str(current_part)
	if message_source.has(part_string): reset_box_to_new_message(part_string)
	else:
		$ContinueButton.hide()
		await fade_scene(0)
		emit_signal("ready_to_continue")
		queue_free()

func fade_scene(alpha_channel: float) -> void:
	var scene_tween = get_tree().create_tween()
	var borders_tween = get_tree().create_tween()
	scene_tween.tween_property(self, "modulate", Color(1, 1, 1, alpha_channel), fade_duration)
	borders_tween.tween_property($Borders.material, "shader_parameter/alpha_channel", alpha_channel, fade_duration)
	await get_tree().create_timer(fade_duration).timeout
