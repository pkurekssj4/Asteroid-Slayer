extends Node
var critical_chance_rngs: Dictionary = {}

@onready var game: Node2D = get_node("/root/Game")
@onready var audio_bus: Node = get_node("/root/Game/AudioBus")
@onready var fever: Node = get_node("/root/Game/Fever")
@onready var event_manager: Node = get_node("/root/Game/EventManager")

func explode_object(object: Area2D) -> void:
	# Zewnetrzna obsluga eksplozji pociskow i asteroid. Po ich stronie jest tylko wywolanie resolve_collision
	# Tylko te 2 typy obiektów + eksplozje wykrywają kolizje w całej grze
	# Exploded to zabezpieczneie przeciw wielu eksplozjom na tym samym obiekcie podczas wielu kolizji jednocześnie
	# Obiekty zglaszaja kolizje tylko jesli ich exploded = false
	if object.explosion_scene != null:
		object.explosion_scene.source = object.source
		object.explosion_scene.position = object.position
		game.add_new_object(true, object.explosion_scene)
		object.exploded = true
	
func execute_fx(event_type: String, object: Area2D) -> void:
	for category in object.audio_visual_effects:
		if event_type == "launch":
			match category:
				"sound_when_launched":
					audio_bus.play_audio_from_dict(object.audio_visual_effects[category])
				"visuals_when_launched":
					await object.ready_to_process # <- swiezy start / ukonczenie flashowania / ukonczenie trasnformacji
					adjust_visuals_to_scale_reference(object, object.audio_visual_effects.visuals_when_launched)
					for effect in object.audio_visual_effects.visuals_when_launched:
						# aby dostosowac modulacje zamiast usuwac w locie podczas transformacji
						if !object.audio_visual_effects.visuals_when_launched[effect].has("added"):
							game.add_new_object(true, object.audio_visual_effects.visuals_when_launched[effect]["scene"])
							object.audio_visual_effects.visuals_when_launched[effect]["added"] = true
							object.audio_visual_effects.visuals_when_launched[effect]["scene"].global_position = object.global_position
		elif event_type == "damaged":
			if object.audio_visual_effects.has("visuals_when_launched"): adjust_visuals_to_scale_reference(object, object.audio_visual_effects.visuals_when_launched) # update followersow
			match category:
				"sound_when_damaged":
					audio_bus.play_audio_from_dict(object.audio_visual_effects[category])
				"visuals_when_damaged":
					adjust_visuals_to_scale_reference(object, object.audio_visual_effects.visuals_when_damaged)
					for visual in object.audio_visual_effects[category]:
						var new_particles: GPUParticles2D = object.audio_visual_effects[category][visual]["scene"].duplicate()
						new_particles.global_position = object.global_position
						game.add_new_object(true, new_particles)
		elif event_type == "destroyed":
			match category:
				"sound_when_destroyed":
					audio_bus.play_audio_from_dict(object.audio_visual_effects[category])
				"visuals_when_destroyed":
					adjust_visuals_to_scale_reference(object, object.audio_visual_effects.visuals_when_destroyed)
					for visual in object.audio_visual_effects[category]:
						object.audio_visual_effects[category][visual]["scene"].global_position = object.global_position
						# print ("object destroyed: " + str(object.exploded) + " / new destroyed visual: " + str((object.audio_visual_effects[category][visual]["scene"])))
						game.add_new_object(true, object.audio_visual_effects[category][visual]["scene"])
	
func add_applied_modules(object: Area2D) -> void:
	# sprawdzenie czy object odpalił funkcje ready - jesli tak to jest dodany - potrzebne do zmiany typu w locie
	await object.ready_to_process
	for module in object.modules:
		if object["modules"][module].has("scene"):
			if object["modules"][module]["scene"].parent == null: object.add_child(object["modules"][module]["scene"])
	
func adjust_visuals_to_scale_reference(object: Area2D, dict: Dictionary) -> void:
	for visual in dict:
		if dict[visual].has("scaling_reference"):
			var scale_factor: float
			match dict[visual]["scaling_reference"]:
				"area_of_effect":
					scale_factor = dict[visual]["area_of_effect_scale_factor"]
				"parent_scale":
					scale_factor = object.scale.x
			if dict[visual].has("adjust_amount_ratio_to_scale_factor"):
				var amount_ratio: float = 1.0
				if dict[visual].has("initial_amount_ratio_variation"): amount_ratio -= dict[visual]["initial_amount_ratio_variation"]
				dict[visual]["scene"].amount_ratio = scale_factor * amount_ratio
			dict[visual]["scene"].scale = Vector2(scale_factor, scale_factor)
	
func resolve_collision(area_entered: bool, area_owner: Area2D, intruder: Area2D) -> void:
	if intruder.is_in_group("floor"):
		if area_owner.is_in_group("explosive"): game.add_new_object(false, area_owner)
		return
	elif area_owner.is_in_group("ghosts"):
		return
	elif intruder.is_in_group("shields") and area_owner.explosion_scene != null:
		if area_owner.explosion_scene.collision_parameters.has("damage"):
			area_owner.collision_parameters.damage = area_owner.explosion_scene.collision_parameters.damage
		if area_owner.explosion_scene.collision_parameters.has("critical_hit_chance"):
			area_owner.collision_parameters.critical_hit_chance = area_owner.explosion_scene.collision_parameters.critical_hit_chance
			area_owner.collision_parameters.critical_hit_damage_thresholds = area_owner.explosion_scene.collision_parameters.critical_hit_damage_thresholds
		area_owner.explosion_scene = null
		for visual in area_owner.audio_visual_effects.visuals_when_destroyed:
			area_owner.audio_visual_effects.visuals_when_destroyed[visual]["scene"].queue_free()
		area_owner.audio_visual_effects.visuals_when_destroyed.clear()
	# kolizje sa ustawione w inspektorze, wiec to musi byc pocisk jesli spotkal tarcze
	# mozna przerobic na grupe absorb explosion i zastosowac do nowych obiektów
	# podwojny warunek na wypadek gdy pocisk uderzy jednocześnie w wiele tarcz, tak samo jak przy eksplozji
	
	for parameter in area_owner.collision_parameters:
		if area_entered:
			if !intruder.is_in_group("ghosts"):
				match parameter:
					"damage": 
						var damage: float = resolve_damage(area_owner, intruder)
						damage_object(damage, area_owner, intruder)
					"shockwave_force":
						if intruder.has_method("apply_shockwave_force"):
							intruder.apply_shockwave_force(area_owner.global_position, area_owner.collision_parameters.shockwave_force)
					"transform_asteroids_to_parent_type":
						if intruder.is_in_group("asteroids"):
						# gdy rodzic zniknie to nie bedzie dostępu do typu dlatego zmienna w parametrach
							intruder.change_type(area_owner.collision_parameters.transform_asteroids_to_parent_type)
			if intruder.is_in_group("asteroids"): 
				match parameter:
					"pull_force":
						intruder.apply_pull_force(area_owner.global_position, area_owner.collision_parameters.pull_force, area_owner.collision_parameters.pull_slow)
					"slow_by_asteroid":
						intruder.apply_slow_by_asteroid(true, area_owner.collision_parameters.slow_by_asteroid_power, area_owner.collision_parameters.slow_by_asteroid_extra_power)
		else:
			if intruder.is_in_group("asteroids"):
				match parameter:
					"pull_force":
						intruder.reset_pull_force()
					"slow_by_asteroid_power":
						intruder.apply_slow_by_asteroid(false, 0.0, 0.0)
	
	if !intruder.is_in_group("ghosts") and area_owner.is_in_group("explosive"): game.add_new_object(false, area_owner)

func resolve_damage(area_owner: Area2D, intruder: Area2D) -> float:
	if area_owner.collision_parameters.has("critical_hit_chance"):
		var critical_hit_damage: float
		if !critical_chance_rngs.has(area_owner.type):
			var new_rng: RandomNumberGenerator = RandomNumberGenerator.new()
			new_rng.randomize()
			critical_chance_rngs[area_owner.type] = new_rng
		var critical_hit_chance: float = critical_chance_rngs[area_owner.type].randf_range(0.0, 1.0)
		if area_owner.collision_parameters.critical_hit_chance > critical_hit_chance:
			var critical_damage_multiplier: float = randf_range(area_owner.collision_parameters.critical_hit_damage_thresholds[0], area_owner.collision_parameters.critical_hit_damage_thresholds[1])
			critical_hit_damage = critical_damage_multiplier * area_owner.collision_parameters.damage
			var range_between_thresholds: float = (area_owner.collision_parameters.critical_hit_damage_thresholds[1] - area_owner.collision_parameters.critical_hit_damage_thresholds[0])
			var critical_damage_percent_power: float = (range_between_thresholds - (area_owner.collision_parameters.critical_hit_damage_thresholds[1] - critical_damage_multiplier)) / (range_between_thresholds)
			#print ("-------------------------")
			#print ("Szansa na kryt: " + str(area_owner.collision_parameters.critical_hit.chance))
			#print ("Zwykly damage: " + str(area_owner.collision_parameters.damage) + " / Critical Damage: " + str(critical_hit_damage))
			#print ("Mnoznik kryta: " + str(critical_damage_multiplier) + " / Procentowa sila kryta: " + str(critical_damage_percent_power))
			#print ("-------------------------")
			audio_bus.play_audio("critical_hit")
			var text: String = "Critical Hit"
			var color_bbcode: String = "crimson"
			var size: String
			if critical_damage_percent_power < 0.33: size = "small"
			elif critical_damage_percent_power < 0.66: size = "medium"
			else: size = "big"
			var speed: String = "fast"
			var display_position: Vector2
			if area_owner.is_in_group("explosions"): display_position = intruder.global_position
			else: display_position = area_owner.global_position
			var icon: String = "none"
			game.create_small_text_event(text, color_bbcode, size, speed, display_position, icon)
			return critical_hit_damage
	return area_owner.collision_parameters.damage

func damage_object(damage: float, attacker: Area2D, victim: Area2D) -> void:
	if game.is_player(attacker.source) and !game.is_player(victim):
		var fever_progress: float
		if victim.durability_points - damage <= 0.0: fever_progress = victim.durability_points
		else: fever_progress = damage
		fever.progress(fever_progress)
	victim.take_damage(damage, attacker)
