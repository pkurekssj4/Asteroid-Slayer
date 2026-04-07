extends Node

var blessings_scene: Node2D
var game_state: int = -1
var delay: int = 0
var events_schedule: Array[String]
var current_schedule_slot: int = 0
var previous_schedule_slot: int = 0
var percent_of_asteroids_spawned: int = 0

var events_data: Dictionary = {
	"schedule_range_low": 0,
	"schedule_range_high": 25,
	"event_trigger_percent_interval": 4,
	"inactive_last_slots": 4,
	"inactive_first_slots": 6,
	"minimum_inactive_first_slots": 1,
	"minimum_inactive_last_slots": 2,
	"days_to_reduce_inactive_first_slots": 8,
	"days_to_reduce_inactive_last_slots": 40,
	
	"events": {
		"fast_spawn": {
			"initial_day": 6,
			"occurences": 1,
			"occurences_increase_rate": 1,
			"event_interval": 8,
			"interval_decrease_rate": 1,
			"days_to_increase_occurences_and_reduce_interval": 30,
			"asteroids_number": 3,
			"days_to_increase_asteroids_number": 15
		},
		"hyper_velocity_wave": {
			"initial_day": 8,
			"occurences": 1,
			"occurences_increase_rate": 1,
			"event_interval": 8,
			"interval_decrease_rate": 2,
			"days_to_increase_occurences_and_reduce_interval": 30,
			"days_to_increase_asteroids_number": 25,
			"asteroids_number": 3
		},
		"flash_wave": {
			"initial_day": 12,
			"occurences": 2,
			"occurences_increase_rate": 1,
			"event_interval": 9,
			"interval_decrease_rate": 2,
			"days_to_increase_occurences_and_reduce_interval": 30,
			"days_to_increase_asteroids_number": 8,
			"asteroids_number": 5
		},
		"force_asteroid_type_spawn_on_initial_day": {
			"initial_day": 2,
			"occurences": 2,
			"asteroids_number": 1,
			"event_interval": 2
		},
		"meteor_shower": {
			"days_to_launch": [3, 7, 13, 15],
			"duration_sec": 10,
			"initial_day": 3,
		},
		
		"huge_asteroid": {
			"initial_day": 101,
		},
		"toxic_rain": {
			"initial_day": 101,
		},
		"intensified_cosmic_radiation": {
			# zaklocenie celowania
			"initial_day": 101,
		},
		"ion_storm_blackout": {
			# wylaczenie / paraliz AA
			"initial_day": 101,
		},
		"ufo": {
			"initial_day": 101,
		}
	}
}

@onready var game: Node2D = get_node("/root/Game")
@onready var audio_bus: Node = get_node("/root/Game/AudioBus")
@onready var fabricated_scenes_manager: Node = get_node("/root/Game/FabricatedScenesManager")


func _ready() -> void:
	await game.game_ready
	prepare_events_schedule()
	advance_game_state()

func _process(_delta: float) -> void:
	if GlobalScript.current_data.game.day % 5 == 0 and GlobalScript.current_data.game.day % 10 != 0: set_process(false)
	supervise_event_schedule()

func advance_game_state() -> void:
	# delay ustawiany przez niektore eventy typu highscore accuracy streak
	if delay > 1:
		await game.create_delay_timer(delay)
		delay = 0
	
	game_state += 1
		
	if game_state == 0: #msg box przed akcją
		if GlobalScript.current_data.game.day == 1: game.display_message_box("intro")
		elif GlobalScript.current_data.game.day == 3: game.display_message_box("day_3")
		elif GlobalScript.current_data.game.day == 5: game.display_message_box("day_5")
		elif GlobalScript.current_data.game.day == 6: game.display_message_box("day_6")
		elif GlobalScript.current_data.game.day == 8: game.display_message_box("hyper_velocity_alert")
		elif GlobalScript.current_data.game.day == 15: game.display_message_box("day_15")
		elif GlobalScript.current_data.game.day == 22: game.display_message_box("ufo_warning")
		else:
			advance_game_state()
		
	elif game_state == 1:# intro
		if GlobalScript.current_data.game.day == 1:
			var camera = game.get_node("Camera2D")
			if !GlobalScript.skip_intro:
				if !GlobalScript.current_data.game.muted: game.get_node("Sounds/IntroMusic").play()
				var tween = get_tree().create_tween()
				tween.set_ease(Tween.EASE_IN_OUT)
				tween.set_trans(Tween.TRANS_QUAD)
				tween.tween_property(camera, "position", Vector2(960,540), 18)
				await game.create_delay_timer(18)
			else:
				camera.position = Vector2(960,540)
			advance_game_state()
		else: advance_game_state()
		
	elif game_state == 2: # start spawnu asteroid
		await game.create_delay_timer(1)
		game.stop_game(false)
		var minute: String = str(GlobalScript.current_data.game.time[1])
		if GlobalScript.current_data.game.time[1] < 10: minute = "0" + minute
		game.display_event_message("Day " + str(GlobalScript.current_data.game.day) + "\n" + GlobalScript.current_data.game.month_literally + " " + str(GlobalScript.current_data.game.month_day) + " \n" + str(GlobalScript.current_data.game.time[0]) + ":" + minute, 3, "nosound", 0, "white", "normal", "none", 0)
		if GlobalScript.current_data.game.day % 5 == 0 and GlobalScript.current_data.game.day % 10 != 0:
			game.launch_special_asteroid_wave("day_" + str(GlobalScript.current_data.game.day))
		else:
			game.get_node("Timers/AsteroidSpawnDelay").start(0.5)
		
	elif game_state == 3: # stop gdy nie ma wiecej akcji
		if game.debug.enabled: get_tree().call_group("asteroids", "explode")
		audio_bus.cancel(game.current_soundtrack)
		game.game_ended = true
		game.stop_game(true)
		await game.create_delay_timer(1)
		advance_game_state()
		
	elif game_state == 4: # pojaw oczy boga
		if GlobalScript.current_data.game.day % 5 == 0 and GlobalScript.current_data.game.day % 10 != 0:
			var preloaded_blessings_scene = preload("res://blessings/blessings_scene.tscn")
			await game.create_delay_timer(2)
			var new_blessings_scene = preloaded_blessings_scene.instantiate()
			new_blessings_scene.global_position = Vector2(game.get_viewport_rect().size.x/2, (game.get_viewport_rect().size.y / 2) - 300)
			get_parent().add_child(new_blessings_scene)
			blessings_scene = new_blessings_scene
			await game.create_delay_timer(3)
		advance_game_state()
		
	elif game_state == 5: #wyswietl msg box gdy oczy sie pojawily po raz pierwszy
		if GlobalScript.current_data.game.day == 5:
			game.display_message_box("first god encounter")
		else:
			advance_game_state()
			
	elif game_state == 6: #wyswietl blessingi
		if GlobalScript.current_data.game.day % 5 == 0 and GlobalScript.current_data.game.day % 10 != 0:
			await game.create_delay_timer(2)
			blessings_scene.present_upgrades()
		else: advance_game_state()
		
		
	elif game_state == 7: #wyswietl msg box na koniec dnia
		if GlobalScript.current_data.game.day == 5:
			game.display_message_box("after god encounter")
		elif GlobalScript.current_data.game.day == 1:
			game.display_message_box("ending of day 1")
		else:
			advance_game_state()
			
	elif game_state == 8: # koncowa ceremonia
		await game.create_delay_timer(1)
		game.display_ending_ceremony_event()
	
	elif game_state == 9: # daj nano core
		if !GlobalScript.current_data.game.muted: game.get_node("Sounds/NanoCore").play()
		game.play_new_score_animation("nano_core")
		game.display_event_message("You received 1 Nano Core", 1, "no_sound", 0, "white", "normal", "none", 0)
		GlobalScript.current_data.resources.nano_cores += 1
		game.refresh_nano_cores_label()
		await game.create_delay_timer(1)
		advance_game_state()
		
	elif game_state == 10: # daj extra creditsy
		if GlobalScript.current_data.game.player_specialisation == "collectioner":
			var extra_credits = int((GlobalScript.current_data.resources.credits - GlobalScript.current_data.resources.credits_snapshot) * GlobalScript.SPECIALISATION_BONUSES.collectioner.extra_resource_credits_earned_that_day)
			if extra_credits >= 0:
				if !GlobalScript.current_data.game.muted: game.get_node("Sounds/ExtraCredits").play()
				game.display_event_message("You earn extra " + str(int(GlobalScript.SPECIALISATION_BONUSES.collectioner.extra_resource_credits_earned_that_day * 100)) + "% (" + str(extra_credits) + ") Resource Credits because of your specialisation", 4, "none", 0, "white", "normal", "none", 0)
				await game.create_delay_timer(5)
				#game.update_resource_credits(extra_credits, game, game.cannon.global_position)
			advance_game_state()
		else: advance_game_state()
			
	elif game_state == 11: # wyswietl last stand event
		var actual_buildings = 13 - game.buildings_data.destroyed_count
		if actual_buildings - game.buildings_data.destroyed_count_threshold == 1:
			await game.create_delay_timer(1)
			game.display_event_message("You held on the brink of destruction, maintaining only a one-building advantage – you earn 50 Resource Credits for your remarkable perseverance!", 5, "last stand", 0, "white", "normal", "none", 0)
			await game.create_delay_timer(6)
			game.update_resource_credits(GlobalScript.current_data.rewards.last_stand, game, game.get_node("Cannon").global_position)
			advance_game_state()
		else: advance_game_state()
		
	elif game_state == 12: # podsumowanie
		game.summary()
		
	elif game_state == 13:
		game.end_game()

func prepare_events_schedule() -> void:
	var inactive_first_slots_threshold: int = events_data["inactive_first_slots"] - floor(GlobalScript.current_data.game.day / events_data["days_to_reduce_inactive_first_slots"])
	var inactive_last_slots_threshold: int = events_data["schedule_range_high"] - (events_data["inactive_last_slots"] - floor(GlobalScript.current_data.game.day / events_data["days_to_reduce_inactive_last_slots"]))
	if inactive_first_slots_threshold < events_data["minimum_inactive_first_slots"]: inactive_first_slots_threshold = events_data["minimum_inactive_first_slots"]
	if inactive_last_slots_threshold > events_data["schedule_range_high"] - events_data["minimum_inactive_last_slots"]: inactive_last_slots_threshold = events_data["schedule_range_high"] - events_data["minimum_inactive_last_slots"]
	for i in range(events_data["schedule_range_low"], events_data["schedule_range_high"] + 1):
		if i < inactive_first_slots_threshold or i > inactive_last_slots_threshold: events_schedule.append("inactive")
		else: events_schedule.append("")
	for event in events_data["events"]:
		var slots_to_add: Array[int]
		if events_data["events"][event]["initial_day"] <= GlobalScript.current_data.game.day:
			match event:
				"fast_spawn", "hyper_velocity_wave", "flash_wave":
					var occurences: int = events_data["events"][event]["occurences"] + (floor(GlobalScript.current_data.game.day / events_data["events"][event]["days_to_increase_occurences_and_reduce_interval"]) * events_data["events"][event]["occurences_increase_rate"])
					var actual_interval: int = events_data["events"][event]["event_interval"] - floor(GlobalScript.current_data.game.day / events_data["events"][event]["days_to_increase_occurences_and_reduce_interval"] * events_data["events"][event]["interval_decrease_rate"])
					slots_to_add = get_slots_to_add(occurences, actual_interval)
					for i in slots_to_add: events_schedule[i] = event
				"force_asteroid_type_spawn_on_initial_day":
					for asteroid in GlobalScript.current_data.asteroids:
						if GlobalScript["current_data"]["asteroids"][asteroid].has("spawn"):
							if GlobalScript["current_data"]["asteroids"][asteroid]["spawn"]["unlock_day"] == GlobalScript.current_data.game.day:
								slots_to_add = get_slots_to_add(events_data["events"]["force_asteroid_type_spawn_on_initial_day"]["occurences"], events_data["events"]["force_asteroid_type_spawn_on_initial_day"]["event_interval"])
								for i in slots_to_add: events_schedule[i] = "force_spawn_" + asteroid
								break
				"meteor_shower":
					if GlobalScript.current_data.game.day in events_data["events"][event]["days_to_launch"]:
						slots_to_add = get_slots_to_add(1, 1)
						for i in slots_to_add: events_schedule[i] = event
	print (events_schedule)

func get_slots_to_add(occurences: int, interval: int):
	var free_slots: Array[int] = get_free_slots()
	var slots_to_add: Array[int]
	var random_slot: int
	while slots_to_add.size() < occurences and !free_slots.is_empty():
		random_slot = free_slots.pick_random()
		if slot_can_be_added(slots_to_add, random_slot, interval) or slots_to_add.is_empty():
			slots_to_add.append(random_slot)
		free_slots.erase(random_slot)
	return slots_to_add
	
func get_free_slots():
	var free_slots: Array[int]
	for i in range (events_data["schedule_range_low"], events_data["schedule_range_high"] + 1):
		if events_schedule[i] == "": free_slots.append(i)
	return free_slots
	
func slot_can_be_added(slots: Array, random_slot: int, interval: int):
	var can_be_added: bool = true
	for i in slots:
		if abs(random_slot - i) < interval: can_be_added = false
	return can_be_added

func trigger_fast_spawn_event() -> void:
	var asteroids_number_to_spawn: int = events_data["events"]["fast_spawn"]["asteroids_number"] + floor(GlobalScript.current_data.game.day / events_data["events"]["fast_spawn"]["days_to_increase_asteroids_number"])
	for i in range (1, asteroids_number_to_spawn + 1):
		game.add_new_object(true, fabricated_scenes_manager.get_asteroid_scene("random", 0, 0.0, 0, Vector2.ZERO, Vector2.ZERO, false, 0))
		await game.create_delay_timer(randf_range(0.15, 0.25))

func trigger_hyper_velocity_wave_event() -> void:
	#print(current_schedule_slot)
	var asteroids_number_to_spawn: int = events_data["events"]["hyper_velocity_wave"]["asteroids_number"] + floor(GlobalScript.current_data.game.day / events_data["events"]["hyper_velocity_wave"]["days_to_increase_asteroids_number"])
	for i in range (1, asteroids_number_to_spawn + 1):
		game.add_new_object(true, fabricated_scenes_manager.get_asteroid_scene("hyper_velocity", 0, 0.0, 0, Vector2.ZERO, Vector2.ZERO, false, 0))
		await game.create_delay_timer(randf_range(0.2, 0.6))
		
func trigger_flash_wave_event(real_trigger: bool) -> void:
	#print(current_schedule_slot)
	var asteroids_number_to_spawn: int = events_data["events"]["flash_wave"]["asteroids_number"] + floor(GlobalScript.current_data.game.day / events_data["events"]["flash_wave"]["days_to_increase_asteroids_number"])
	var asteroid_types_to_spawn: Array[String]
	var spawn_x: int = randi_range(150, 1600)
	var spawn_y: int = randi_range(200, 450)
	var flashing_time: float = 3.5
	var distance_variation = 25 + (asteroids_number_to_spawn * 4)
	for type in GlobalScript.current_data.asteroids:
		if type.contains("asteroid"):
			if type not in ["hyper_velocity_asteroid", "electric_asteroid", "split_up_asteroid"]: asteroid_types_to_spawn.append(type)
	for i in range (1, asteroids_number_to_spawn + 1):
		var pos_x: int = spawn_x + randi_range(distance_variation * -1, distance_variation)
		var pos_y: int = spawn_y + randi_range(distance_variation * -1, distance_variation)
		var new_asteroid: Area2D = fabricated_scenes_manager.get_asteroid_scene(asteroid_types_to_spawn.pick_random(), 0, 0.0, 0, Vector2(pos_x, pos_y), Vector2.ZERO, false, 0)
		new_asteroid.is_flashing = true
		new_asteroid.flashing_duration = flashing_time
		game.add_new_object(true, new_asteroid)
	audio_bus.play_audio("asteroids_flashing")
	await game.create_delay_timer(flashing_time - 0.3)
	audio_bus.play_audio("asteroids_finished_flashing")
	#print ("flash wave launched")
	
func trigger_force_asteroid_type_spawn_event(event: String) -> void:
	var asteroid_type: String
	for case in GlobalScript.current_data.asteroids:
		if event.contains(case):
			asteroid_type = case
			break
	for i in range (1, events_data["events"]["force_asteroid_type_spawn_on_initial_day"]["asteroids_number"] + 1):
		game.add_new_object(true, fabricated_scenes_manager.get_asteroid_scene(asteroid_type, 0, 0.0, 0, Vector2.ZERO, Vector2.ZERO, false, 0))
		await game.create_delay_timer(randf_range(0.5, 1.0))
	#print ("Launching asteroid: " + asteroid_type +" at slot: " + str(current_schedule_slot))

func trigger_meteor_shower() -> void:
	var duration_timer: Timer = Timer.new()
	duration_timer.one_shot = true
	game.get_node("ProgressBarManager").create_progress_bar("Meteor shower", "red", events_data.events.meteor_shower.duration_sec)
	add_child(duration_timer)
	duration_timer.start(events_data.events.meteor_shower.duration_sec)
	while !duration_timer.is_stopped():
		var asteroid: Area2D = fabricated_scenes_manager.get_asteroid_scene("common", 0, 0.1, 160, Vector2.ZERO, Vector2.ZERO, false, 0)
		asteroid.credits_reward = GlobalScript.current_data.rewards.meteor_shower_asteroid
		asteroid.is_regular = false
		game.add_new_object(true, asteroid)
		var delay_time: float = randf_range(0.4, 0.7)
		if delay_time > duration_timer.time_left: delay_time = duration_timer.time_left + 0.1
		await game.create_delay_timer(delay_time)
	duration_timer.queue_free()
	
func supervise_event_schedule() -> void:
	if current_schedule_slot == events_schedule.size() - 1 or game.game_ended:
		set_process(false)
		return
	percent_of_asteroids_spawned = 100 - (GlobalScript.current_data.asteroids.general.asteroids_left * 100 / GlobalScript.current_data.asteroids.general.asteroids_total * 100) / 100
	if percent_of_asteroids_spawned < events_data["event_trigger_percent_interval"]: return
	if percent_of_asteroids_spawned >= current_schedule_slot * events_data["event_trigger_percent_interval"]:
		#print ("Schedule +1 / " + str(game.asteroids_data.left) + "/" + str(game.asteroids_data.total) + "/ percent spawned: " + str(percent_of_asteroids_spawned))
		current_schedule_slot += 1
		if previous_schedule_slot != current_schedule_slot:
			previous_schedule_slot = current_schedule_slot
			#print ("Current schedule slot: " + str(current_schedule_slot))
		if events_schedule[current_schedule_slot] != "":
			if events_schedule[current_schedule_slot] == "fast_spawn": trigger_fast_spawn_event()
			elif events_schedule[current_schedule_slot] == "hyper_velocity_wave": trigger_hyper_velocity_wave_event()
			elif events_schedule[current_schedule_slot] == "flash_wave": trigger_flash_wave_event(true)
			elif events_schedule[current_schedule_slot] == "meteor_shower": trigger_meteor_shower()
			elif events_schedule[current_schedule_slot].contains("force_spawn"): trigger_force_asteroid_type_spawn_event(events_schedule[current_schedule_slot])
		events_schedule[current_schedule_slot] = ""
