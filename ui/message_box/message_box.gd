extends Control
var current_part = 1
var character_actual_unveil_ticks = 0
var character_target_unveil_ticks = 1
var fade_duration = 0.3
var current_waving_phase: float = 0.0
var shader_phase_thresholds: Array[int] = [195, 213]
var waving_phase_per_sec: float = 2.0
var waving_multiplier: float = 1.0
var sender: String
var place: String
var message_source: Dictionary
signal ready_to_continue

func _ready() -> void:
	$Place.text = place
	$Sender.text = "Send from: " + sender
	reset_box_to_new_message("part_1")
	$Message.visible_ratio = 0
	if !GlobalScript.current_data.game.muted: $MessageSound.play()
	global_position = get_viewport_rect().size / 2
	global_position -= $Borders.size / 2
	current_waving_phase = shader_phase_thresholds[0]
	$Borders.material.set("shader_parameter/phase", current_waving_phase)
	modulate.a = 0
	set_process(false)
	await fade_scene(1)
	set_process(true)
	
func _process(delta: float) -> void:
	if current_waving_phase >= shader_phase_thresholds[1]: waving_multiplier = -1.0
	elif current_waving_phase <= shader_phase_thresholds[0]: waving_multiplier = 1.0
	current_waving_phase += (waving_phase_per_sec * delta) * waving_multiplier
	$Borders.material.set("shader_parameter/phase", current_waving_phase)
	if $Message.visible_ratio < 1:
		character_actual_unveil_ticks += 1
		if character_actual_unveil_ticks != character_target_unveil_ticks:
			return
		character_actual_unveil_ticks = 0
		if Input.is_action_pressed("fire"):
			$Message.visible_characters += 15
			$MessageUnveiling.pitch_scale = 5.5
		else:
			$Message.visible_characters += 3
			$MessageUnveiling.pitch_scale = 4
		if !GlobalScript.current_data.game.muted: $MessageUnveiling.play()
		if $Message.visible_ratio >= 1:
			$ContinueButton.show()
			
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
