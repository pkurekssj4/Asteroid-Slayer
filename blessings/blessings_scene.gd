extends Node2D
const BLESSING_HIGHLIGHT_PARTICLES = preload("res://blessings/blessing_highlight_particles.tscn")
const BLESSING_HIGHLIGHT_PARTICLES_2 = preload("res://blessings/blessing_highlight_particles_2.tscn")
const POWER_INFLUX_PARTICLES = preload("res://blessings/power_flux_particles.tscn")
const INFLUX_LIGHT = preload("res://blessings/power_flux_light.tscn")
var can_pick_blessing: bool = false
var blessing_picked: bool = false
var progress_bar: ProgressBar
var duration: int = 60
var config: Dictionary
@onready var game = get_node("/root/Game")
@onready var cannon = get_node("/root/Game/Cannon")
@onready var vfx_scenes_container = get_node("/root/Game/ScenesContainer/VFX")
@onready var progress_bar_manager = game.get_node("ProgressBarManager")
@onready var event_manager = get_node("/root/Game/EventManager")

func _ready():
	z_index = game.get_display_index("gods_eyes")
	fade_gods_eyes_animation("in")
	config = GlobalScript.current_data.next_blessings_config
	for cloud in config:
		$Clouds.get_node(cloud.to_pascal_case() + "Label").text = "[color=" + GlobalScript.COLOR_PALETTE.object_color + "]" + config[cloud].bonus_receiver.capitalize()
		var stat_name: String = config[cloud].statistic_structure[config[cloud].statistic_structure.size() - 1]
		var dict_to_take_value_from: Dictionary = GlobalScript.BLESSING_BONUSES
		if GlobalScript.current_data.next_blessings_config[cloud].bonus_receiver == "cannon": dict_to_take_value_from = dict_to_take_value_from["cannon"]
		elif GlobalScript.current_data.next_blessings_config[cloud].bonus_receiver.contains("laser"): dict_to_take_value_from = dict_to_take_value_from["laser_turret"]
		elif GlobalScript.current_data.next_blessings_config[cloud].bonus_receiver.contains("barrier"): dict_to_take_value_from = dict_to_take_value_from["pulse_barrier"]
		$Clouds.get_node(cloud.to_pascal_case() + "Description").text = GlobalScript.get_statistic_verb(stat_name) + " " + stat_name.capitalize() + " by " + str(GlobalScript.get_value_from_dict(config[cloud].statistic_structure, dict_to_take_value_from) * 100.0) + "% of base value"
		
func fade_gods_eyes_animation(type: String) -> void:
	if type == "in":
		if !GlobalScript.current_data.game.muted: $GodsEyesAppearingSound.play()
		$AnimationPlayer.play("gods_eyes_in")
	if type =="out":
		$AnimationPlayer.play("gods_eyes_out")

func present_upgrades() -> void:
	game.game_pausable = false
	$AnimationPlayer.play("gods_blessings_in")
	await game.create_delay_timer(2)
	AudioBus.play("blessings_music")
	progress_bar = progress_bar_manager.create_progress_bar("God's patience", "blue", duration)
	$Timer.start(duration)
	can_pick_blessing = true
	
func finalize_blessings(blessing_number: String) -> void:
	game.game_pausable = true
	if !blessing_picked:
		blessing_picked = true
	else: return
	if !GlobalScript.current_data.game.muted: $BlessingHighlightSound.play()
	$AnimationPlayer.play("gods_blessings_out")
	if !$Timer.is_stopped(): $Timer.stop()
	var sound_cfg: Dictionary = {
		"name": "power_influx",
		"pitch_percent_variation": 0.0,
		"volume_gain": 3.0,
		"pitch": 1.0
	}
	AudioBus.cancel("blessings_music")
	if is_instance_valid(progress_bar): progress_bar.cancel(false)
	var blessing_position = Vector2()
	blessing_position = $Clouds.get_node("Cloud" + blessing_number).global_position
	var bonus_receiver: Area2D
	if config["cloud_" + blessing_number]["bonus_receiver"] == "cannon": bonus_receiver = game.get_node("Cannon")
	else: bonus_receiver = game.get_node("SupportUnits").get_node(config["cloud_" + blessing_number]["bonus_receiver"].to_pascal_case())
	var highlight_particles: Array[GPUParticles2D] = []
	highlight_particles.append(BLESSING_HIGHLIGHT_PARTICLES.instantiate())
	highlight_particles.append(BLESSING_HIGHLIGHT_PARTICLES_2.instantiate())
	for particles in highlight_particles:
		particles.z_index = z_index - 1
		particles.global_position = blessing_position
		vfx_scenes_container.add_child(particles)
		var scale_tween: Tween = create_tween()
		scale_tween.tween_property(particles, "scale", Vector2(0.1, 0.1), 3.0)
		var relocate_tween: Tween = create_tween()
		relocate_tween.set_trans(Tween.TRANS_QUAD)
		relocate_tween.set_ease(Tween.EASE_IN_OUT)
		relocate_tween.tween_property(particles, "global_position", bonus_receiver.global_position, 6)
	await game.create_delay_timer(5)
	for particles in highlight_particles: particles.emitting = false
	var new_power_influx_particles: GPUParticles2D = POWER_INFLUX_PARTICLES.instantiate()
	new_power_influx_particles.z_index = game.get_display_index("visual_effects")
	new_power_influx_particles.global_position = bonus_receiver.global_position
	vfx_scenes_container.add_child(new_power_influx_particles)
	sound_cfg = {
		"name": "power_influx",
		"pitch_percent_variation": 0.0,
		"volume_gain": 5.5,
		"pitch": 1.35
	}
	AudioBus.play_from_dict(sound_cfg)
	var current_modulation: Color = bonus_receiver.modulate
	var new_modulation_raise_tween: Tween = create_tween()
	new_modulation_raise_tween.tween_property(bonus_receiver, "modulate", Color(9, 9, 9), 5.0)
	var influx_light: PointLight2D = INFLUX_LIGHT.instantiate()
	influx_light.global_position = new_power_influx_particles.global_position
	influx_light.scale = Vector2(0.0, 0.0)
	vfx_scenes_container.add_child(influx_light)
	var light_scale_tween: Tween = create_tween()
	light_scale_tween.tween_property(influx_light, "scale", Vector2(7.0, 7.0), 3.5)
	light_scale_tween.tween_property(influx_light, "scale", Vector2(0.0, 0.0), 5.5)
	await game.create_delay_timer(5)
	var new_modulation_normalize_tween: Tween = create_tween()
	new_modulation_normalize_tween.tween_property(bonus_receiver, "modulate", current_modulation, 4.0)
	await game.create_delay_timer(2)
	fade_gods_eyes_animation("out")
	await game.create_delay_timer(2.5)
	influx_light.queue_free()
	light_scale_tween.kill()
	grant_blessing(blessing_number)
	GlobalScript.prepare_next_blessings_config()
	event_manager.advance_game_state()
	
func grant_blessing(blessing_number: String) -> void:
	var day: String = "day_" + str(GlobalScript.current_data.game.day)
	GlobalScript.current_data.blessings[day] = {}
	GlobalScript.current_data.blessings[day] = GlobalScript.current_data.next_blessings_config["cloud_" + blessing_number].duplicate(true)
	var data_dict: Dictionary = GlobalScript.get_data_source_dictionary(GlobalScript.current_data.blessings[day]["bonus_receiver"], "current")
	if !data_dict["additive_statistics"].has("blessings"):
		data_dict["additive_statistics"]["blessings"] = {}
	GlobalScript.include_additive_stats(false, "blessings")
	GlobalScript.add_stat_to_object(true, GlobalScript.current_data.blessings[day]["statistic_value"], GlobalScript.current_data.blessings[day]["statistic_structure"], data_dict["additive_statistics"]["blessings"])
	GlobalScript.include_additive_stats(true, "blessings")
	
func _on_timer_timeout() -> void:
	finalize_blessings(str(randi_range(1,3)))

func _on_cloud_1_button_pressed() -> void:
	if can_pick_blessing: finalize_blessings("1")

func _on_cloud_2_button_pressed() -> void:
	if can_pick_blessing: finalize_blessings("2")

func _on_cloud_3_button_pressed() -> void:
	if can_pick_blessing: finalize_blessings("3")
