extends Node2D
const DEFAULT_CURSOR = preload("res://cursor.png")
const RELOAD_CURSOR = preload("res://cursor_reload.png")
const EVENT_MESSAGE = preload("res://event_message.tscn")
const TOOLTIP_SCENE = preload("res://tooltip_ingame.tscn")
const FIREWORK = preload("res://firework.tscn")
const STRUCTURE_BAR = preload("res://structures/structure_bar.tscn")

const DISPLAY_HIERARCHY: Dictionary = {
	"projectiles": [10], 
	"explosions": [11],
	"asteroids": [10],
	"asteroid_shields": [12],
	"visual_effects": [10],
	"clouds": [9, 12],
	"gods_eyes": [13]
}

var debug: Dictionary = {
	"enabled": false,
	"cant_lose": false,
	"asteroids_stopped": false,
	"all_cds_disabled": true,
	"keep_pressing_hotkey_to_spawn_asteroids": true,
	"buildings_are_repaired": false,
	"debug_values": true,
	"day": 13,
	"basic_attack_damage": 200,
	"basic_attack_reload_time": 1,
	"basic_attack_attack_speed": 5,
	"basic_attack_capacity": 50,
	"basic_attack_area_of_effect": 200,
	"basic_attack_critical_hit_damage_thresholds": [1.2, 1.4],
	"basic_attack_critical_hit_chance": 0.1,
	"projectile_speed": 700
}

var statistics_data: Dictionary = {
	"mass_destructions": {
		"count": 0,
		"cumulated_rewards": 0,
		"highscore": 0,
		"display_new_highscore_ticks": 0
	},
	
	"chain_reactions": {
		"count": 0,
		"cumulated_rewards": 0,
		"highscore": 0,
		"display_new_highscore_ticks": 0
	},
	
	"accuracy_streaks": {
		"count": 0,
		"progress": 0,
		"cumulated_rewards": 0,
		"highscore": 0,
		"display_new_highscore_ticks": 0
	},
	
	"hyper_asteroids": {
		"count": 0,
		"destroyed_count": 0,
	},
	
	"basic_attack": {
		"shots_fired": 0,
		"shots_missed": 0,
	},
}

var buildings_data: Dictionary = {
	"active": 0,
	"destroyed_count": 0,
	"destroyed_count_this_day": 0,
	"destroyed_count_threshold": 0,
}

var rngs: Dictionary = {
	"general": RandomNumberGenerator.new(),
	"asteroid_type": RandomNumberGenerator.new(),
	"asteroid_rarity": RandomNumberGenerator.new(),
	"shield_chance": RandomNumberGenerator.new(),
	"common_shard": RandomNumberGenerator.new(),
	"celestial_shard": RandomNumberGenerator.new(),
	"astral_shard": RandomNumberGenerator.new(),
	"ethereal_shard": RandomNumberGenerator.new(),
}

var structures_list: Array[Area2D]
var cannon_upgrades: Array = []
var plasma_barrage_upgrades: Array = []
var stasis_field_upgrades: Array = []
var gravity_well_upgrades: Array = []
var orbital_strike_upgrades: Array = []
var game_ended: bool = false
var game_stopped: bool = false
var last_tooltip_id: int
var against_all_odds_buildings_count = 0
var against_all_odds_reward_pending = false
var hyper_cleaner_asteroids_count = 0
var hyper_cleaner_reward = 20
var hyper_cleaner_duration = 5 #seconds
var event_message_1: RichTextLabel = null
var event_message_2: RichTextLabel = null
var event_message_3: RichTextLabel = null
var current_soundtrack: String
var game_pausable: bool = true
signal game_ready

func _ready():
	if GlobalScript.initial_config.new_game:
		GlobalScript.prepare_for_new_game()
		save_game()
	load_game()
	if FileAccess.file_exists(GlobalScript.get_save_path("config")): load_config()
	if debug.enabled && debug.debug_values: set_debug_values()
	GlobalScript.init()
	$TimeAndWeather.init()
	init_structures()
	for key in rngs: rngs[key].randomize()
	refresh_shards()
	refresh_nano_cores_label()
	refresh_resource_credits_label()
	get_window().grab_focus()
	assign_values_to_resources()
	emit_signal("game_ready")
	
func _process(delta):
	check_if_any_button_is_pressed()
	progress_pending_highscore_ticks()

func init_structures() -> void:
	structures_list = get_structures_list()
	disable_inactive_structures()
	var bars_and_backgrounds: Node2D = Node2D.new()
	bars_and_backgrounds.name = "StructureBarsAndBackgrounds"
	add_child(bars_and_backgrounds)
	create_durability_bars()
	create_bonus_and_attack_readiness_bars()
	buildings_data.active = 0
	for structure in structures_list:
		$FabricatedScenesManager.apply_audio_visual_effects(structure, GlobalScript.get_data_source_dictionary(structure.get_name().to_snake_case(), "current"), GlobalScript.current_data.structures.general.audio_visual_effects, Color(1, 1, 1, 1))
		var data_dict: Dictionary = GlobalScript.get_data_source_dictionary(structure.get_name().to_snake_case(), "current")
		if data_dict.active: buildings_data.active += 1
	buildings_data.destroyed_count_threshold = 10 + floor(GlobalScript.current_data.game.day / 15)
	update_buildings_label()
	
func _on_asteroid_spawn_delay_timeout():
	if debug.enabled and debug.asteroids_stopped: return
	add_object(true, $FabricatedScenesManager.get_asteroid_scene("random", 0, 0.0, 0, Vector2.ZERO, Vector2.ZERO, true, 0))
	var spawn_delay_variation_multiplier: float = randf_range((1.0 - (GlobalScript.current_data.asteroids.general.spawn_delay_percent_variation / 2) / 100.0), 1.0 + ((GlobalScript.current_data.asteroids.general.spawn_delay_percent_variation / 2) / 100.0))
	var spawn_delay: float = spawn_delay_variation_multiplier * GlobalScript.current_data.asteroids.general.spawn_delay
	if GlobalScript.current_data.asteroids.general.asteroids_left > 0: $Timers/AsteroidSpawnDelay.start(spawn_delay)

func create_chain_reaction_counter():
	var new_chain_reaction_counter = Node.new()
	new_chain_reaction_counter.set_script(preload("res://chain_reaction_counter.gd"))
	get_tree().current_scene.call_deferred("add_child", new_chain_reaction_counter)
	return new_chain_reaction_counter

func end_game() -> void:
	$EndingBlackSolid.show()
	$AnimationPlayer.play("default/ending_fade_out")
	await create_delay_timer(2.0)
	GlobalScript.current_data.game.day += 1
	progress_all_structures()
	save_game()
	GlobalScript.load_scene("upgrade console")

func summary() -> void:
	await create_delay_timer(1)
	$Summary.show()
	var percent
	var delay = 0.15
	$Summary/MainLabel.show()
	await create_delay_timer(delay)
	$Summary/DestroyedAsteroidsLabel.show()
	$Summary/DestroyedAsteroidsCount.text = str(GlobalScript.current_data.asteroids.general.asteroids_destroyed) + "/" + str(GlobalScript.current_data.asteroids.general.asteroids_total)
	$Summary/DestroyedAsteroidsCount.show()
	if !GlobalScript.current_data.game.muted: $Sounds/Summary.play()
	await create_delay_timer(delay)
	$Summary/LostBuildingsLabel.show()
	$Summary/LostBuildingsCount.text = str(buildings_data.destroyed_count_this_day)
	$Summary/LostBuildingsCount.show()
	if !GlobalScript.current_data.game.muted: $Sounds/Summary.play()
	await create_delay_timer(delay)
	$Summary/AccuracyLabel.show()
	var accuracy_shots = statistics_data.basic_attack.shots_fired - statistics_data.basic_attack.shots_missed
	if statistics_data.basic_attack.shots_fired != 0: percent = floor(accuracy_shots * 100.0 / statistics_data.basic_attack.shots_fired)
	else: percent = 0
	$Summary/AccuracyNumber.text = str(accuracy_shots) + "/" + str(statistics_data.basic_attack.shots_fired) + " (" + str(percent) + "%)"
	$Summary/AccuracyNumber.show()
	if !GlobalScript.current_data.game.muted: $Sounds/Summary.play()
	await create_delay_timer(delay)
	$Summary/HyperLabel.show()
	if statistics_data.hyper_asteroids.count != 0: percent = floor(statistics_data.hyper_asteroids.destroyed_count * 100.0 / statistics_data.hyper_asteroids.count)
	else: percent = 0
	$Summary/HyperCount.text = str(statistics_data.hyper_asteroids.destroyed_count) + "/" + str(statistics_data.hyper_asteroids.count) + " (" + str(percent) +"%)"
	$Summary/HyperCount.show()
	if !GlobalScript.current_data.game.muted: $Sounds/Summary.play()
	await create_delay_timer(delay)
	$Summary/MassDestructionsLabel.show()
	$Summary/MassDestructionsCount.text = str(statistics_data.mass_destructions.count) + " (" + str(statistics_data.mass_destructions.cumulated_rewards) + " Resource Credits)"
	$Summary/MassDestructionsCount.show()
	if !GlobalScript.current_data.game.muted: $Sounds/Summary.play()
	await create_delay_timer(delay)
	$Summary/ChainReactionsLabel.show()
	$Summary/ChainReactionsCount.text = str(statistics_data.chain_reactions.count) + " (" + str(statistics_data.chain_reactions.cumulated_rewards) + " Resource Credits)"
	$Summary/ChainReactionsCount.show()
	if !GlobalScript.current_data.game.muted: $Sounds/Summary.play()
	await create_delay_timer(delay)
	$Summary/AccuracyStreaksLabel.show()
	$Summary/AccuracyStreaksCount.text = str(statistics_data.accuracy_streaks.count) + " (" + str(statistics_data.accuracy_streaks.cumulated_rewards) + " Resource Credits)"
	$Summary/AccuracyStreaksCount.show()
	if !GlobalScript.current_data.game.muted: $Sounds/Summary.play()
	await create_delay_timer(delay)
	$Summary/ContinueButton.show()

func progress_accuracy_streak(add: bool):
	if add: statistics_data.accuracy_streaks.progress += 1
	else:
		statistics_data.basic_attack.shots_missed += 1
		if statistics_data.accuracy_streaks.progress > 20: display_event_message("Accuracy streak broken after " + str(statistics_data.accuracy_streaks.progress) + " shots", 2, "accuracy streak failed", 1, "purple", "normal", "none", 0)
		if statistics_data.accuracy_streaks.progress > statistics_data.accuracy_streaks.highscore:
			new_highscore("accuracy streak", statistics_data.accuracy_streaks.progress)
		statistics_data.accuracy_streaks.progress = 0
		return 0
	if statistics_data.accuracy_streaks.progress % 10 != 0 || statistics_data.accuracy_streaks.progress == 0: return 0
	statistics_data.accuracy_streaks.count += 1
	var pitch: float = 0.97 + statistics_data.accuracy_streaks.progress / 260.00
	var reward = int(GlobalScript.current_data.rewards.accuracy_streak * statistics_data.accuracy_streaks.progress / 10.0)
	statistics_data.accuracy_streaks.cumulated_rewards += reward
	display_event_message("Accuracy streak (" + str(statistics_data.accuracy_streaks.progress) + ") ", 2, "accuracy streak", pitch, "purple", "normal", "resource credit", reward)
	return reward

func new_highscore(type: String, highscore: int) -> void:
	if type == "accuracy streak":
		statistics_data.accuracy_streaks.highscore = highscore
		statistics_data.accuracy_streaks.display_new_highscore_ticks = 1
	if type == "mass destruction":
		statistics_data.mass_destructions.highscore = highscore
		statistics_data.mass_destructions.display_new_highscore_ticks = 1
	if type == "chain reaction":
		statistics_data.chain_reactions.highscore = highscore
		statistics_data.chain_reactions.display_new_highscore_ticks = 1

func progress_pending_highscore_ticks() -> void:
	if game_ended:
		if statistics_data.accuracy_streaks.progress > statistics_data.accuracy_streaks.highscore:
			new_highscore("accuracy streak", statistics_data.accuracy_streaks.progress)
			$EventManager.delay += 2
	if statistics_data.accuracy_streaks.display_new_highscore_ticks == 100:
		statistics_data.accuracy_streaks.display_new_highscore_ticks = 0
		display_event_message("New accuracy streak highscore " + "(" + str(statistics_data.accuracy_streaks.highscore) + ")!", 3, "new highscore", 0, "white", "normal", "none", 0)
	elif statistics_data.accuracy_streaks.display_new_highscore_ticks !=0: statistics_data.accuracy_streaks.display_new_highscore_ticks += 1
	
	if statistics_data.mass_destructions.display_new_highscore_ticks == 100:
		statistics_data.mass_destructions.display_new_highscore_ticks = 0
		display_event_message("New mass destruction highscore " + "(" + str(statistics_data.mass_destructions.highscore) + ")!", 3, "new highscore", 0, "white", "normal", "none", 0)
	elif statistics_data.mass_destructions.display_new_highscore_ticks !=0: statistics_data.mass_destructions.display_new_highscore_ticks += 1
	
	if statistics_data.chain_reactions.display_new_highscore_ticks == 100:
		statistics_data.chain_reactions.display_new_highscore_ticks = 0
		display_event_message("New chain reaction highscore " + "(" + str(statistics_data.chain_reactions.highscore) + ")!", 3, "new highscore", 0, "white", "normal", "none", 0)
	elif statistics_data.chain_reactions.display_new_highscore_ticks !=0: statistics_data.chain_reactions.display_new_highscore_ticks += 1
	
func display_event_message(msg: String, time: int, sound: String, pitch: float, color: String, font_size: String, icon: String, points: int):
	var new_event_message = EVENT_MESSAGE.instantiate()
	new_event_message.color = color
	new_event_message.message = msg
	new_event_message.lasting_time = time
	if font_size == "big": new_event_message.font_size = 25
	push_new_event_message()
	event_message_1 = new_event_message
	new_event_message.points = points
	new_event_message.icon = icon
	new_event_message.size = get_viewport_rect().size
	
	if sound == "mass destruction": 
		if pitch >= 3: pitch = 3
		$Sounds/MassDestruction.pitch_scale = pitch
		if !GlobalScript.current_data.game.muted: $Sounds/MassDestruction.play()
	elif sound == "accuracy streak": 
		if pitch >= 2.7: pitch = 2.7
		$Sounds/AccuracyStreak.pitch_scale = pitch
		if !GlobalScript.current_data.game.muted: $Sounds/AccuracyStreak.play()
	elif sound == "new highscore": $Sounds/NewHighscore.play()
	elif sound == "accuracy streak failed": $Sounds/AccuracyStreakFailed.play()
	elif sound == "building hit": $Sounds/BuildingHit.play()
	elif sound == "fever": $Sounds/Fever.play() 
	elif sound == "hyper": $Sounds/HyperDestroyed.play()
	elif sound == "last stand": $Sounds/LastStand.play()
	elif sound == "against all odds": $Sounds/AgainstAllOdds.play()
	elif sound == "ending message":
		new_event_message.waving = true
		if !GlobalScript.current_data.game.muted: $Sounds/EndingMessage.play()
			
	add_child(new_event_message)

func push_new_event_message():
	if is_instance_valid(event_message_3):
		event_message_3.queue_free()
		
	if is_instance_valid(event_message_2):
		event_message_2.position.y += 25
		event_message_3 = event_message_2
		event_message_3.add_theme_font_size_override("normal_font_size", 10)
		
	if is_instance_valid(event_message_1):
		event_message_1.position.y += 25
		event_message_2 = event_message_1
		event_message_2.add_theme_font_size_override("normal_font_size", 13)

func _on_event_timer_timeout():
	$EventText.hide()
	
func refresh_resource_credits_label() -> void:
	$GUI/Score/ResourceCredits/Count.text = str(GlobalScript.current_data.resources.credits)

func refresh_nano_cores_label() -> void:
	$GUI/Score/NanoCores/Count.text = str(GlobalScript.current_data.resources.nano_cores)

func display_small_text_event(type: String, amount: int, display_position: Vector2) -> void:
	var new_label: RichTextLabel = RichTextLabel.new()
	new_label.set_script($ResourceLoader.get_scriptt("small_text_event"))
	var font_size: int = 12
	var outline_size: String = "1"
	var color_bbcode: String
	var text: String
	var icon: String = ""
	var icon_size: int = 15
	var pixels_move_per_second: int = 15
	var fading_out_duration: float = 1.0
	var duration_time: float = 1.3
	match type:
		"resource_credits":
			text = "+" + str(amount)
			icon = "resource_credit_icon"
			color_bbcode = "green"
		"common_shard", "celestial_shard", "astral_shard", "etherel_shard", "divine_shard":
			text = "+1"
			pixels_move_per_second = 6
			duration_time = 4.0
			icon = type + "_icon"
			color_bbcode = "white"
		"weak_critical_hit", "medium_critical_hit", "strong_critical_hit":
			text = "Critical Hit"
			pixels_move_per_second = -8
			color_bbcode = "crimson"
			if type == "medium_critical_hit":
				font_size = 13
			if type == "strong_critical_hit":
				font_size = 14
				outline_size = "2"
	new_label.add_theme_font_size_override("normal_font_size", font_size)
	new_label.bbcode_enabled = true
	new_label.text = "[color=" + color_bbcode + "][outline_size=" + outline_size + "][outline_color=" + color_bbcode + "]" + text + "[/outline_color][/outline_size][/color]"
	if icon != "": new_label.add_image($ResourceLoader.get_resource(icon), icon_size)
	new_label.size = Vector2(150, 30)
	new_label.pixels_move_per_second = pixels_move_per_second
	new_label.fading_out_duration = fading_out_duration
	new_label.duration_time = duration_time
	if display_position.y < 50: display_position.y = 50
	if display_position.x < 50: display_position.x = 50
	elif display_position.x > 1850: display_position.x = 1850
	new_label.global_position = display_position
	$UILayer.add_child(new_label)

func add_credits(receiver: Area2D, credits: int, target_position: Vector2) -> void:
	if is_instance_valid(receiver):
		if is_player(receiver):
			GlobalScript.current_data.resources.credits += credits
			refresh_resource_credits_label()
			play_new_score_animation("credits")
			display_small_text_event("resource_credits", credits, target_position)
		else:
			receiver.resource_credits += credits

func play_new_score_animation(animation) -> void:
	var new_animation_player = AnimationPlayer.new()
	var new_library = AnimationLibrary.new()
	new_library.add_animation(animation, $AnimationPlayer.get_animation_library("default").get_animation(animation))
	new_animation_player.add_animation_library("default", new_library)
	add_child(new_animation_player)
	new_animation_player.play("default/" + animation)
	new_animation_player.animation_finished.connect(func(_animation): new_animation_player.queue_free())

func save_game() -> void:
	print ("Saving game")
	$TimeAndWeather.set_config_for_next_day()
	var file = FileAccess.open(GlobalScript.get_save_path("game"), FileAccess.WRITE)
	if GlobalScript.initial_config.new_game: GlobalScript.initial_config.new_game = false
	GlobalScript.current_data.game.last_save_date = GlobalScript.get_current_date()
	file.store_var(GlobalScript.current_data)
	file.store_var(GlobalScript.initial_data)
	file.store_var(cannon_upgrades)
	file.store_var(plasma_barrage_upgrades)
	file.store_var(stasis_field_upgrades)
	file.store_var(gravity_well_upgrades)
	file.store_var(orbital_strike_upgrades)
	file.store_var(statistics_data.mass_destructions.highscore)
	file.store_var(statistics_data.accuracy_streaks.highscore)
	file.store_var(statistics_data.chain_reactions.highscore)
	file.close()
	
func load_game() -> void:
	print ("Loading game")
	var file = FileAccess.open(GlobalScript.get_save_path("game"), FileAccess.READ)
	GlobalScript.current_data = file.get_var()
	GlobalScript.initial_data = file.get_var()
	GlobalScript.current_data.resources.credits_snapshot = GlobalScript.current_data.resources.credits
	cannon_upgrades = file.get_var()
	plasma_barrage_upgrades = file.get_var()
	stasis_field_upgrades = file.get_var()
	gravity_well_upgrades = file.get_var()
	orbital_strike_upgrades = file.get_var()
	statistics_data.mass_destructions.highscore = file.get_var()
	statistics_data.accuracy_streaks.highscore = file.get_var()
	statistics_data.chain_reactions.highscore = file.get_var()
	file.close()
	
func save_config() -> void:
	var file = FileAccess.open(GlobalScript.get_save_path("config"), FileAccess.WRITE)
	file.store_var(debug.enabled)
	file.close()
	
func load_config() -> void:
	var file = FileAccess.open(GlobalScript.get_save_path("config"), FileAccess.READ)
	debug.enabled = file.get_var()
	file.close()
		
func set_debug_values() -> void:
	print ("Setting debug cannon values")
	GlobalScript.current_data.game.day = debug.day
	return
	GlobalScript.current_data.structures.cannon.explosion.damage = debug.basic_attack_damage
	GlobalScript.current_data.structures.cannon.reload_time = debug.basic_attack_reload_time
	GlobalScript.current_data.structures.cannon.attack_speed = debug.basic_attack_attack_speed
	GlobalScript.current_data.structures.cannon.capacity = debug.basic_attack_capacity
	GlobalScript.current_data.structures.cannon.projectile_speed = debug.projectile_speed
	GlobalScript.current_data.structures.cannon.explosion.area_of_effect = debug.basic_attack_area_of_effect
	GlobalScript.current_data.structures.cannon.explosion.critical_hit_damage_thresholds = debug.basic_attack_critical_hit_damage_thresholds
	GlobalScript.current_data.structures.cannon.explosion.critical_hit_chance = debug.basic_attack_critical_hit_chance
	
func update_buildings_label() -> void:
	$GUI/BuildingsThresholdCount.text = str(buildings_data.active) + "/" + str(buildings_data.destroyed_count_threshold)
	var structures_initial_number_that_can_be_destroyed: int = structures_list.size() - buildings_data.destroyed_count_threshold
	var structures_current_number_that_can_be_destroyed: int = buildings_data.active - buildings_data.destroyed_count_threshold
	var percent: float = (structures_current_number_that_can_be_destroyed * 1.0) / (structures_initial_number_that_can_be_destroyed * 1.0)
	if percent > 0.70: $GUI/BuildingsThresholdCount.modulate = Color (0.3, 1, 0.3, 1)
	elif percent > 0.35: $GUI/BuildingsThresholdCount.modulate = Color (0.8, 0.7, 0, 1)
	else: $GUI/BuildingsThresholdCount.modulate = Color (1, 0.3, 0.3, 1)

func _on_continue_button_button_down() -> void:
	$EventManager.advance_game_state()

func change_cursor(cursor: String) -> void:
	if cursor == "default": Input.set_custom_mouse_cursor(DEFAULT_CURSOR, Input.CURSOR_ARROW, Vector2(20,20))
	elif cursor == "reload": Input.set_custom_mouse_cursor(RELOAD_CURSOR, Input.CURSOR_ARROW, Vector2(20,20))
	
func refresh_shards() -> void:
	$GUI/Score/CommonShards/Count.text = str(GlobalScript.current_data.resources.common_shards)
	$GUI/Score/CelestialShards/Count.text = str(GlobalScript.current_data.resources.celestial_shards)
	$GUI/Score/AstralShards/Count.text = str(GlobalScript.current_data.resources.astral_shards)
	$GUI/Score/EtherealShards/Count.text = str(GlobalScript.current_data.resources.ethereal_shards)
	$GUI/Score/DivineShards/Count.text = str(GlobalScript.current_data.resources.divine_shards)
	
func draw_shard(object: Area2D) -> void:
	var shard: String
	match object.rarity:
		1: shard = "common"
		2: shard = "celestial"
		3: shard = "astral"
		4: shard = "ethereal"
		5: shard = "divine"
	
	var shard_string: String = shard + "_shard"
	
	if rngs[shard_string].randi_range(1, 1000) <= GlobalScript.current_data.resources.shard_drop_chance * 1000.0:
		var pitch_scale: float = 0.9 + (object.rarity * 0.1)
		var sound_cfg: Dictionary = {
			"pitch_percent_variation" = 0.0,
			"volume_gain" = 0.0,
			"name" = "shard_collected",
			"pitch" = pitch_scale
		}
		$AudioBus.play_audio_from_dict(sound_cfg)
		play_new_score_animation(shard_string)
		display_small_text_event(shard_string, 1, object.global_position)
		refresh_shards()
		GlobalScript.current_data.resources[shard_string + "s"] += 1

func check_if_any_button_is_pressed() -> void:
	#debugging
	if Input.is_action_just_pressed(&"enable_debugging"):
			if debug.enabled:
				debug.enabled = false
			else:
				debug.enabled = true
			display_event_message("debugging: " + str(debug.enabled), 2, "no_sound", 0, "white", "normal", "none", 0)
			save_config()
	#mute
	if Input.is_action_just_pressed(&"mute"):
		if !GlobalScript.current_data.game.muted: 
			GlobalScript.current_data.game.muted = true
			$Sounds/Ambient.stop()
			$Sounds/Rain.stop()
		else: GlobalScript.current_data.game.muted = false
		save_config()
	if game_ended || game_stopped: return
	if debug.enabled:
		var asteroid_1 = "splitting"
		var asteroid_2 = "electric"
		var asteroid_3 = "plasma"
		if debug.keep_pressing_hotkey_to_spawn_asteroids:
			if Input.is_action_just_pressed(&"spawn_asteroid"):
				add_object(true, $FabricatedScenesManager.get_asteroid_scene(asteroid_1, 0, 0.15, 1, get_global_mouse_position(), Vector2.ZERO, false, 0))
			elif Input.is_action_just_pressed(&"spawn_asteroid_2"):
				add_object(true, $FabricatedScenesManager.get_asteroid_scene(asteroid_2, 0, 0.25, 1, get_global_mouse_position(), Vector2.ZERO, false, 0))
			elif Input.is_action_just_pressed(&"spawn_asteroid_3"):
				add_object(true, $FabricatedScenesManager.get_asteroid_scene(asteroid_3, 0, 0.35, 1, get_global_mouse_position(), Vector2.ZERO, false, 0))
		else:
			if Input.is_action_pressed(&"spawn_asteroid"):
				add_object(true, $FabricatedScenesManager.get_asteroid_scene(asteroid_1, 0, 0.15, 1, get_global_mouse_position(), Vector2.ZERO, false, 0))
			elif Input.is_action_pressed(&"spawn_asteroid_2"):
				add_object(true, $FabricatedScenesManager.get_asteroid_scene(asteroid_2, 0, 0.15, 1, get_global_mouse_position(), Vector2.ZERO, false, 0))
			elif Input.is_action_pressed(&"spawn_asteroid_3"):
				add_object(true, $FabricatedScenesManager.get_asteroid_scene(asteroid_3, 0, 0.35, 1, get_global_mouse_position(), Vector2.ZERO, false, 0))
				
		if Input.is_action_just_pressed(&"do_anything"):
			$EventManager.trigger_meteor_shower()

		if Input.is_action_just_pressed(&"do_anything_2"):
			save_game()
			display_event_message("game saved", 1, "no_sound", 1.0, "white", "normal", "no_icon", 0)
			
		elif Input.is_action_just_pressed(&"keep_pressing_hotkey_to_spawn_asteroids"):
			if debug.keep_pressing_hotkey_to_spawn_asteroids:
				debug.keep_pressing_hotkey_to_spawn_asteroids = false
			else: debug.keep_pressing_hotkey_to_spawn_asteroids = true
			display_event_message("keep_pressing_hotkey_to_spawn_asteroids: " + str(debug.keep_pressing_hotkey_to_spawn_asteroids), 2, "no_sound", 0, "white", "normal", "none", 0)
			
		elif Input.is_action_just_pressed(&"stop_asteroids"):
			if debug.asteroids_stopped:
				debug.asteroids_stopped = false
				$EventManager.set_process(true)
			else: 
				debug.asteroids_stopped = true
				$EventManager.set_process(false)
			display_event_message("asteroids stoppped: " + str(debug.asteroids_stopped), 2, "no_sound", 0, "white", "normal", "none", 0)
		elif Input.is_action_just_pressed(&"instant_end"):
			GlobalScript.current_data.asteroids.general.asteroids_left = 0
			GlobalScript.current_data.asteroids.general.asteroids_alive = 0
			game_ended = true
			$EventManager.advance_game_state()
		elif Input.is_action_just_pressed(&"cant_lose"):
			if debug.cant_lose:
				debug.cant_lose = false
			else: debug.cant_lose = true
			display_event_message("cant lose: " + str(debug.cant_lose), 2, "no_sound", 0, "white", "normal", "none", 0)

func _on_against_all_odds_timer_timeout() -> void:
	if against_all_odds_buildings_count >= 3:
		against_all_odds_reward_pending = true
		$Timers/AgainstAllOddsTimer.start(10)
	elif against_all_odds_reward_pending:
		# update_resource_credits(50, self, $Cannon.global_position)
		display_event_message("Against all odds! You lost many buildings and didn't quit ", 6, "against all odds", 1, "white", "normal", "resource credit", 50)
		against_all_odds_reward_pending = false
	against_all_odds_buildings_count = 0

func display_message_box(msg_box: Control, resume_game: bool) -> void:
	stop_game(true)
	$UILayer.add_child(msg_box)
	await msg_box.ready_to_continue
	if resume_game: stop_game(false)

func stop_game(type: bool) -> void:
	game_stopped = type

func launch_special_asteroid_wave(day: int) -> void:
	var soundtrack_path: String = $AudioBus.audio_path + "/soundtrack"
	match day:
		5:
			var music_cfg: Dictionary = {
				"pitch_percent_variation" = 0.0,
				"volume_gain" = -9,
				"name" = "day_5_soundtrack",
				"pitch" = 1.0
			}
			$AudioBus.add_new_player(soundtrack_path, music_cfg.name + ".mp3")
			$AudioBus.play_audio_from_dict(music_cfg)
			current_soundtrack = music_cfg.name
			var asteroids_in_wave: int = 59
			GlobalScript.current_data.asteroids.general.asteroids_total = asteroids_in_wave
			GlobalScript.current_data.asteroids.general.asteroids_left = asteroids_in_wave
			GlobalScript.current_data.asteroids.general.asteroids_alive = 0
			for i in range (1, asteroids_in_wave + 1):
				if game_ended: break
				await create_delay_timer(randf_range(1.5, 1.8))
				add_object(true, $FabricatedScenesManager.get_asteroid_scene("common", 0, randf_range(0.20, 0.33), 0, Vector2.ZERO, Vector2.ZERO, false, 0))
		15:
			var music_cfg: Dictionary = {
				"pitch_percent_variation" = 0.0,
				"volume_gain" = -9,
				"name" = "day_15_soundtrack",
				"pitch" = 1.0
			}
			$AudioBus.add_new_player(soundtrack_path, music_cfg.name + ".mp3")
			$AudioBus.play_audio_from_dict(music_cfg)
			current_soundtrack = music_cfg.name
			var asteroids_in_wave: int = 85
			GlobalScript.current_data.asteroids.general.asteroids_total = asteroids_in_wave
			GlobalScript.current_data.asteroids.general.asteroids_left = asteroids_in_wave
			GlobalScript.current_data.asteroids.general.asteroids_alive = 0
			var available_types: Array[String] = ["toxic", "splitting"]
			for i in range (1, asteroids_in_wave + 1):
				if game_ended: break
				await create_delay_timer(randf_range(0.70, 1.15))
				add_object(true, $FabricatedScenesManager.get_asteroid_scene(available_types.pick_random(), 0, randf_range(0.23, 0.3), 0, Vector2.ZERO, Vector2.ZERO, true, 0))
		25:
			var music_cfg: Dictionary = {
			"pitch_percent_variation" = 0.0,
			"volume_gain" = -9,
			"name" = "A.K.K. - Unreleased 1",
			"pitch" = 1.0
			}
			$AudioBus.add_new_player(soundtrack_path, music_cfg.name + ".mp3")
			$AudioBus.play_audio_from_dict(music_cfg)
			current_soundtrack = music_cfg.name
			var asteroids_in_wave: int = 90
			GlobalScript.current_data.asteroids.general.asteroids_total = asteroids_in_wave
			GlobalScript.current_data.asteroids.general.asteroids_left = asteroids_in_wave
			GlobalScript.current_data.asteroids.general.asteroids_alive = 0
			var launch_delay: float = 1.8
			for i in range (1, asteroids_in_wave + 1):
				launch_delay -= 0.01
				if game_ended: break
				await create_delay_timer(launch_delay)
				add_object(true, $FabricatedScenesManager.get_asteroid_scene("hyper_velocity", 1, randf_range(0.20, 0.27), 0, Vector2.ZERO, Vector2.ZERO, false, 0))
			
func trigger_game_over_sequence() -> void:
	if (debug.enabled && debug.cant_lose) or game_ended: return
	$Sounds/GameOver.play()
	game_ended = true
	$PauseAndGameOverMenu.switch_to_game_over()
	var duration: float = 5.1
	var new_timer: Timer = Timer.new()
	new_timer.ignore_time_scale = true
	new_timer.one_shot = true
	add_child(new_timer)
	var new_tween: Tween = create_tween()
	new_tween.set_ignore_time_scale(true)
	new_tween.tween_property(Engine, "time_scale", 0.01, duration)
	new_timer.start(duration)
	await new_timer.timeout
	new_timer.queue_free()
	new_tween.kill()
	$PauseAndGameOverMenu.show()
	Engine.time_scale = 1
	get_tree().paused = true

func assign_values_to_resources() -> void:
	$GUI/Score/ResourceCredits.object_name = "Resource Credits"
	$GUI/Score/ResourceCredits.function = "Granted for destryoing asteroids. Used to change specialisation and upgrade cannon or base infrastructure."
	var shards_function = "Occasionally found in asteroid remains. Used to change properties and behaviors of asteroids."
	$GUI/Score/CommonShards.object_name = "Common Shards"
	$GUI/Score/CommonShards.function = shards_function
	$GUI/Score/CommonShards.drop_chance = GlobalScript.current_data.resources.shard_drop_chance
	$GUI/Score/CelestialShards.object_name = "Celestial Shards"
	$GUI/Score/CelestialShards.function = shards_function
	$GUI/Score/CelestialShards.drop_chance = GlobalScript.current_data.resources.shard_drop_chance
	$GUI/Score/AstralShards.object_name = "Astral Shards"
	$GUI/Score/AstralShards.function = shards_function
	$GUI/Score/AstralShards.drop_chance = GlobalScript.current_data.resources.shard_drop_chance
	$GUI/Score/EtherealShards.object_name = "Ethereal Shards"
	$GUI/Score/EtherealShards.function = shards_function
	$GUI/Score/EtherealShards.drop_chance = GlobalScript.current_data.resources.shard_drop_chance
	$GUI/Score/NanoCores.object_name = "Nano Cores"
	$GUI/Score/NanoCores.function = "Produced by scientists in laboratories. Used to implement and enhance cannon abilities."

func progress_hyper_cleaner() -> void:
	hyper_cleaner_asteroids_count += 1
	if hyper_cleaner_asteroids_count == 5:
		await create_delay_timer(1)
		display_event_message("Hyper Cleaner! You destroyed 5 or more Hyper Asteroids in short time ", 2, "hyper cleaner", 0, "red", "normal", "resource credit", 20)
		# update_resource_credits(20, self, $Cannon.global_position)
		hyper_cleaner_asteroids_count = 0
		$Sounds/HyperCleaner.play()
		$Timers/HyperCleanerTimer.stop()
	else: $Timers/HyperCleanerTimer.start(hyper_cleaner_duration)

func _on_hyper_cleaner_timer_timeout() -> void:
	hyper_cleaner_asteroids_count = 0

func display_ending_ceremony_event() -> void:
	display_event_message("Day " + str(GlobalScript.current_data.game.day) + " survived, congratulations!", 100, "ending message", 0, "white", "big", "none", 0)
	for i in range(1, GlobalScript.current_data.game.day + 1):
		var new_firework = FIREWORK.instantiate()
		new_firework.position.y = 958
		new_firework.position.x = randi_range(200, 1800)
		new_firework.destination_y = randi_range(600, 450)
		new_firework.z_index = get_display_index("visual_effects")
		add_child(new_firework)
		await create_delay_timer(randf_range(0.05, 0.08))
	await create_delay_timer(2.5)
	event_message_1.fading_off = true
	await create_delay_timer(2)
	$EventManager.advance_game_state()

func create_delay_timer(time_sec: float):
	var new_timer: Timer = Timer.new()
	add_child(new_timer)
	new_timer.start(time_sec)
	await new_timer.timeout
	new_timer.queue_free()

func create_durability_bars() -> void:
	var durability_bar_y_offset: int = 10
	var durability_bar_z_index: int = 20
	var main_durability_bar: ProgressBar
	
	for object in structures_list:
		for i in range (1, 4):
			var new_durability_bar = STRUCTURE_BAR.instantiate()
			var tooltip_trigger_collision_shape: CollisionShape2D = object.get_node("TooltipTrigger/CollisionShape2D")
			$StructureBarsAndBackgrounds.add_child(new_durability_bar)
			new_durability_bar.global_position = tooltip_trigger_collision_shape.global_position
			new_durability_bar.global_position.x -= new_durability_bar.size.x / 2
			new_durability_bar.position.y -= tooltip_trigger_collision_shape.shape.size.y / 2 + durability_bar_y_offset
			if i == 1:
				# czarne tło + glowny pasek
				var background: ColorRect = ColorRect.new()
				$StructureBarsAndBackgrounds.add_child(background)
				background.color = Color(0, 0, 0, 1)
				background.size = new_durability_bar.size
				background.z_index = durability_bar_z_index - 3
				background.global_position = new_durability_bar.global_position
				object.durability_bar = new_durability_bar
				main_durability_bar = new_durability_bar
				new_durability_bar.z_index = durability_bar_z_index
			elif i == 2:
				# biały pasek (damage taken)
				new_durability_bar.set_script(null)
				main_durability_bar.damage_taken_bar = new_durability_bar
				new_durability_bar.z_index = durability_bar_z_index - 1
			elif i == 3:
				# ciemny czerwony (damage taken this day)
				new_durability_bar.set_script(null)
				new_durability_bar.modulate = Color(0.25, 0.25, 0.25)
				main_durability_bar.damage_taken_this_day_bar = new_durability_bar
				new_durability_bar.z_index = durability_bar_z_index - 2
	
		var data_dict: Dictionary = GlobalScript.current_data.structures[object.get_name().to_snake_case()]
		var damage_taken: bool = false
		update_durability_bar(object, data_dict, damage_taken)
		main_durability_bar.damage_taken_this_day_bar.value = main_durability_bar.value

func create_bonus_and_attack_readiness_bars() -> void:
	var durability_bar_y_offset: int = 17
	var durability_bar_z_index: int = 20
	var structures: Array[Area2D]
	for structure in structures_list:
		var snake_name: String = structure.get_name().to_snake_case()
		var data_dict: Dictionary = GlobalScript.get_data_source_dictionary(snake_name, "current")
		if snake_name.contains("cannon") or snake_name.contains("laser") or snake_name.contains("barrier") or data_dict.has("bonuses_for_other_objects"): 
			structures.append(structure)
		
	for structure in structures:
		var new_bar = STRUCTURE_BAR.instantiate()
		new_bar.set_script(null)
		var tooltip_trigger_collision_shape: CollisionShape2D = structure.get_node("TooltipTrigger/CollisionShape2D")
		$StructureBarsAndBackgrounds.add_child(new_bar)
		new_bar.global_position = tooltip_trigger_collision_shape.global_position
		new_bar.global_position.x -= new_bar.size.x / 2
		new_bar.position.y -= tooltip_trigger_collision_shape.shape.size.y / 2 + durability_bar_y_offset
		# czarne tło + glowny pasek
		var background: ColorRect = ColorRect.new()
		$StructureBarsAndBackgrounds.add_child(background)
		background.color = Color(0, 0, 0, 1)
		background.size = new_bar.size
		background.z_index = durability_bar_z_index - 2
		background.global_position = new_bar.global_position
		var structure_name: String = structure.get_name()
		if structure_name.contains("Cannon") or structure_name.contains("Laser") or structure_name.contains("Barrier"): 
			structure.attack_readiness_bar = new_bar
		else: 
			new_bar.modulate = Color(0.5, 0.2, 0.8)
			structure.bonus_progress_bar = new_bar
		new_bar.z_index = durability_bar_z_index
		
func get_display_index(object: String) -> int:
	var index_to_return: int
	if DISPLAY_HIERARCHY[object].size() > 1:
		index_to_return = randi_range(DISPLAY_HIERARCHY[object][0], DISPLAY_HIERARCHY[object][1])
	else: index_to_return = DISPLAY_HIERARCHY[object][0]
	return index_to_return

func get_structures_list() -> Array[Area2D]:
	var structures: Array[Area2D]
	for object in $Structures.get_children():
		structures.append(object)
	for object in $SupportUnits.get_children():
		structures.append(object)
	structures.append($Cannon)
	return structures

func progress_all_structures() -> void:
	var data_dict: Dictionary
	for structure in structures_list:
		data_dict = GlobalScript.current_data.structures[structure.get_name().to_snake_case()]
		if data_dict.durability.current_repair_days > 0:
			data_dict.durability.current_repair_days -= 1
			if data_dict.durability.current_repair_days == 0:
				data_dict.durability.current_points = data_dict.durability.max_points
				data_dict.active = true
			else:
				disable_structure(structure, data_dict)
		else:
			data_dict.active_days += 1
			data_dict.durability.current_points += int((data_dict.durability.daily_percent_recovery_rate / 100.0) * data_dict.durability.max_points)
			if data_dict.durability.current_points > data_dict.durability.max_points: data_dict.durability.current_points = data_dict.durability.max_points

func damage_structure(structure: Area2D, damage: float) -> void:
	var data_dict: Dictionary = GlobalScript.current_data.structures[structure.get_name().to_snake_case()]
	if data_dict.active: data_dict.durability.current_points -= damage
	else:
		data_dict.durability.current_repair_days = data_dict.durability.repair_days
		return
	var damage_taken: bool = true
	update_durability_bar(structure, data_dict, damage_taken)
	if data_dict.durability.current_points <= 0:
		destroy_structure(structure, data_dict)
		$ObjectEventsHub.execute_fx("destroyed", structure)
	else:
		$ObjectEventsHub.execute_fx("damaged", structure)
	
func damage_structure_by_toxic_rain(structure: Area2D, damage: float) -> void:
	var data_dict: Dictionary = GlobalScript.current_data.structures[structure.get_name().to_snake_case()]
	if data_dict.active: data_dict.durability.current_points -= damage
	else:
		data_dict.durability.current_repair_days = data_dict.durability.repair_days
		return
	var damage_taken: bool = true
	update_durability_bar(structure, data_dict, damage_taken)
	if data_dict.durability.current_points <= 0: data_dict.durability.current_points = 0
	
func destroy_structure(structure: Area2D, data_dict: Dictionary) -> void:
	if data_dict.has("bonuses_for_other_objects"):
		data_dict.bonuses_for_other_objects.base_bonus = 0
		data_dict.bonuses_for_other_objects.growth_rate_bonus = 0
		data_dict.bonuses_for_other_objects.total_bonus = 0
		data_dict.bonuses_for_other_objects.total_growth_rate_multiplier = 0
		structure.bonus_progress_bar.value = 0.0
	if data_dict.has("dish"):
		data_dict.dish.rotation = structure.get_node("RadarDish").rotation
	data_dict.active_days = 0
	data_dict.durability.current_points = 0
	data_dict.durability.current_repair_days = data_dict.durability.repair_days
	GlobalScript.include_additive_stats(false, "structures")
	disable_structure(structure, data_dict)
	GlobalScript.clear_and_set_new_structure_bonuses()
	GlobalScript.include_additive_stats(true, "structures")
	buildings_data.active -= 1
	update_buildings_label()
	if buildings_data.active == buildings_data.destroyed_count_threshold: trigger_game_over_sequence()
	
func disable_structure(structure: Area2D, data_dict: Dictionary) -> void:
	structure.modulate = Color (1, 0.5, 0.5, 1)
	if data_dict.has("dish"):
		structure.get_node("AnimationPlayer").pause()
		structure.get_node("RadarDish").rotation = data_dict.dish.rotation
	elif structure.has_node("AnimatedSprite2D"): structure.get_node("AnimatedSprite2D").stop()
	data_dict.active = false

func disable_inactive_structures() -> void:
	var data_dict: Dictionary
	for structure in structures_list:
		data_dict = GlobalScript.current_data.structures[structure.get_name().to_snake_case()]
		if !data_dict.active: disable_structure(structure, data_dict)

func update_durability_bar(structure: Area2D, data_dict: Dictionary, damage_taken: bool) -> void:
	var new_value: int = (data_dict.durability.current_points / data_dict.durability.max_points) * 100
	structure.durability_bar.update_value(new_value, damage_taken)

func is_player(object: Area2D) -> bool:
	# W przypadku gracza źrodłem zawsze jest ktoraś ze struktur, więc to nie moze byc grac jesli obiekt nie istnieje.
	# Inne obiekty np asteroidy same dla siebie są źródłami.
	if object.source in structures_list: return true
	else: return false

func add_object(add: bool, object: Variant) -> void:
	# Jeśli obiekt został zniszczony i ma odpalone queue_free() to zniknie dopiero w kolejnej klatce, ale jesli zostal zaatakowany dwukrotnie do zniszczenia
	# to musi miec zabezpieczenie aby nie wykonywać dwukrotnie instrukcji zniszczenia \/
	if !add: if object.is_queued_for_deletion(): return
	var group: String
	if object.is_in_group("asteroids"): group = "Asteroids"
	if object.is_in_group("asteroid_shields"): group = "AsteroidShields"
	elif object.is_in_group("projectiles"): group = "Projectiles"
	elif object.is_in_group("explosions"): group = "Explosions"
	elif object.is_in_group("vfx"): group = "VFX"
	
	match group:
		"Asteroids":
			if add:
				$ObjectEventsHub.execute_fx("launch", object)
				$ObjectEventsHub.add_applied_modules(object)
				GlobalScript.current_data.asteroids.general.asteroids_alive += 1
				if object.is_regular: GlobalScript.current_data.asteroids.general.asteroids_left -= 1
			else:
				$ObjectEventsHub.execute_fx("destroyed", object)
				$ObjectEventsHub.explode_object(object)
				if object.is_regular: draw_shard(object)
				GlobalScript.current_data.asteroids.general.asteroids_alive -= 1
			get_node("GUI/AsteroidsLeftCount").text = str(GlobalScript.current_data.asteroids.general.asteroids_left)
			# jeśli splitting wybuchnie jako ostatnia to...
			if GlobalScript.current_data.asteroids.general.asteroids_alive == 0 and GlobalScript.current_data.asteroids.general.asteroids_left == 0:
				$EventManager.advance_game_state()
		"AsteroidShields":
			if !add:
				$ObjectEventsHub.execute_fx("destroyed", object)
		"Projectiles":
			if add:
				$ObjectEventsHub.execute_fx("launch", object)
				$ObjectEventsHub.add_applied_modules(object)
			else:
				$ObjectEventsHub.execute_fx("destroyed", object)
				$ObjectEventsHub.explode_object(object)
			
	if add:
		$ScenesContainer.get_node(group).call_deferred("add_child", object)
	else:
		object.queue_free()
