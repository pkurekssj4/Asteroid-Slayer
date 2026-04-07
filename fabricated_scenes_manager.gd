extends Node

var rngs: Dictionary = {
	"asteroid_type": RandomNumberGenerator.new(),
	"asteroid_size": RandomNumberGenerator.new(),
	"asteroid_speed": RandomNumberGenerator.new(),
	"asteroid_shield": RandomNumberGenerator.new(),
	"asteroid_rarity": RandomNumberGenerator.new(),
	"shield_durability_points": RandomNumberGenerator.new(),
	"side_spawn": RandomNumberGenerator.new(),
	"side_destination": RandomNumberGenerator.new()
}

var side_spawn: Dictionary = {
	"enabled": false,
	"chance_tested_every_asteroid": 6.5,
	"percent_thresholds_from_total_number_of_asteroids": [0.15, 0.17],
	"days_interval_to_reduce_thresholds": 10,
	"value_to_reduce_thresholds_by": 0.015,
	"side": 0,
	"asteroids_left": 0,
}

var side_destination: Dictionary = {
	"enabled": false,
	"chance_tested_every_asteroid": 6.5,
	"percent_thresholds_from_total_number_of_asteroids": [0.15, 0.17],
	"days_interval_to_reduce_thresholds": 10,
	"value_to_reduce_thresholds_by": 0.015,
	"side": 0,
	"asteroids_left": 0,
}

@onready var object_events_hub: Node = get_node("/root/Game/ObjectEventsHub")
@onready var resource_loader: Node = get_node("/root/Game/ResourceLoader")
@onready var game: Node2D = get_node("/root/Game")
@onready var left_asteroid_destination_path_follower: PathFollow2D = get_node("/root/Game/LeftAsteroidDestinationPath/PathFollower")
@onready var middle_asteroid_destination_path_follower: PathFollow2D = get_node("/root/Game/MiddleAsteroidDestinationPath/PathFollower")
@onready var right_asteroid_destination_path_follower: PathFollow2D = get_node("/root/Game/RightAsteroidDestinationPath/PathFollower")
@onready var left_asteroid_spawn_path_follower: PathFollow2D = get_node("/root/Game/LeftAsteroidSpawnPath/PathFollower")
@onready var right_asteroid_spawn_path_follower: PathFollow2D = get_node("/root/Game/RightAsteroidSpawnPath/PathFollower")

func _ready() -> void:
	await game.game_ready
	var value_to_reduce_thresholds_by: float = floor(GlobalScript.current_data.game.day / side_spawn.days_interval_to_reduce_thresholds) * side_spawn.value_to_reduce_thresholds_by
	side_spawn.percent_thresholds_from_total_number_of_asteroids[0] -= value_to_reduce_thresholds_by
	side_spawn.percent_thresholds_from_total_number_of_asteroids[1] -= value_to_reduce_thresholds_by
	value_to_reduce_thresholds_by = floor(GlobalScript.current_data.game.day / side_destination.days_interval_to_reduce_thresholds) * side_destination.value_to_reduce_thresholds_by
	side_destination.percent_thresholds_from_total_number_of_asteroids[0] -= value_to_reduce_thresholds_by
	side_destination.percent_thresholds_from_total_number_of_asteroids[1] -= value_to_reduce_thresholds_by
	
func get_projectile_scene(data_source: String, data_dict: Dictionary, pos: Vector2, dest: Vector2, rot: float, projectile_source: Area2D) -> Area2D:
	var new_projectile: Area2D = resource_loader.get_resource("projectile").instantiate()
	var comp_color: Color = GlobalScript.get_composition_color(data_dict)
	new_projectile.speed = GlobalScript.current_data.structures.cannon.projectile_speed
	new_projectile.type = data_source
	new_projectile.global_position = pos
	new_projectile.destination = dest
	new_projectile.source = projectile_source
	new_projectile.rotation = rot
	new_projectile.z_index = game.get_display_index("projectiles") # wstępnie tylko on ma z_index ustawiony bo wszystkie jego dzieci wyświetlają się od razu nad nim bez względu na z_index
	new_projectile.get_node("Sprite2D").modulate = comp_color
	new_projectile.get_node("PointLight2D").color = comp_color
	new_projectile.explosion_scene = get_explosion_scene(data_source, data_dict, comp_color)
	new_projectile.add_to_group("projectiles")
	new_projectile.add_to_group("explosive")
	apply_parameters(new_projectile, data_dict["projectile"])
	if data_dict["projectile"].has("modules"): apply_modules(new_projectile, data_dict["projectile"]["modules"])
	apply_audio_visual_effects(new_projectile, data_dict, data_dict["projectile"]["audio_visual_effects"], comp_color)
	return new_projectile
	
func get_explosion_scene(data_source: String, data_dict: Dictionary, comp_color: Color) -> Area2D:
	# Source jest określany dopiero przy wybuchu gdy wiadomo co zniszczyło
	# W domysle to ma być dla chain reaction counter i mass destruction
	var new_explosion: Area2D = resource_loader.get_resource(data_dict.explosion.shape + "_explosion").instantiate()
	new_explosion.modulate = comp_color
	new_explosion.type = data_source
	new_explosion.z_index = game.get_display_index("explosions")
	new_explosion.add_to_group("explosions")
	for parameter in data_dict["explosion"]:
		match parameter:
			"rise_and_decay_time":
				new_explosion.rise_and_decay_time = data_dict.explosion.rise_and_decay_time
			"duration":
				new_explosion.duration = data_dict.explosion.duration
			"alpha_channel":
				new_explosion.modulate.a = data_dict.explosion.alpha_channel
			"shape":
				var diameter: float = data_dict.explosion.area_of_effect
				var objects_to_scale: Array = []
				var scale_factor: float
				objects_to_scale.append(new_explosion.get_node("PointLight2D"))
				if data_dict.explosion.shape == "round":
					var explosion_sprite: Sprite2D = new_explosion.get_node("Sprite2D")
					var collision_shape: CollisionShape2D = new_explosion.get_node("CollisionShape2D")
					scale_factor = diameter / explosion_sprite.texture.width
					objects_to_scale.append(explosion_sprite)
					objects_to_scale.append(collision_shape)
				elif data_dict.explosion.shape == "cross":
					var explosion_sprite_vertical: Sprite2D = new_explosion.get_node("Sprite2DVertical")
					var explosion_sprite_horizontal: Sprite2D = new_explosion.get_node("Sprite2DHorizontal")
					var collision_shape_vertical: CollisionShape2D = new_explosion.get_node("CollisionShape2DVertical")
					var collision_shape_horizontal: CollisionShape2D = new_explosion.get_node("CollisionShape2DHorizontal")
					scale_factor = diameter / explosion_sprite_vertical.texture.height
					for object in [explosion_sprite_vertical, explosion_sprite_horizontal, collision_shape_vertical, collision_shape_horizontal]: objects_to_scale.append(object)
				for object in objects_to_scale: object.scale = Vector2(scale_factor, scale_factor)
	apply_parameters(new_explosion, data_dict["explosion"])
	if data_dict["explosion"].has("modules"): apply_modules(new_explosion, data_dict["explosion"]["modules"])
	return new_explosion
	
func apply_parameters(scene: Area2D, data_dict: Dictionary) -> void:
	for parameter in data_dict:
		match parameter:
			### PARAMETRY KOLIZYJNE ###
			"damage":
				scene.collision_parameters.damage = data_dict.damage
			"critical_hit_chance":
				scene.collision_parameters.critical_hit_chance = data_dict.critical_hit_chance
				scene.collision_parameters.critical_hit_damage_thresholds = data_dict.critical_hit_damage_thresholds
			"pull_force":
				scene.collision_parameters.pull_force = data_dict.pull_force
				scene.collision_parameters.pull_slow = data_dict.pull_slow
			"slow_by_asteroid_power":
				scene.collision_parameters.slow_by_asteroid_power = data_dict.slow_by_asteroid_power
				scene.collision_parameters.slow_by_asteroid_extra_power = data_dict.slow_by_asteroid_extra_power
			"shockwave_force":
				scene.collision_parameters.shockwave_force = data_dict.shockwave_force
			"transform_asteroids_to_parent_type":
				scene.collision_parameters.transform_asteroids_to_parent_type = true
			### STANY / FLAGI ###
			"ghost":
				if data_dict[parameter]: scene.add_to_group("ghosts")
				
func apply_modules(scene: Area2D, data_dict: Dictionary) -> void:
	for module in data_dict:
		scene.modules[module] = {}
		match module:
			"trajectory_tweak":
				var new_module: Node = Node.new()
				new_module.set_script(preload("res://modules/trajectory_tweak.gd"))
				scene.modules[module]["scene"] = new_module
			"acceleration":
				var new_module: Node = Node.new()
				new_module.set_script(preload("res://modules/acceleration.gd"))
				new_module.speed_per_second = data_dict.acceleration.speed_per_second
				scene.modules[module]["scene"] = new_module
			"deacceleration":
				var new_module: Node = Node.new()
				new_module.set_script(preload("res://modules/deacceleration.gd"))
				new_module.speed_per_second = data_dict.deacceleration.speed_per_second
				scene.modules[module]["scene"] = new_module
			"explode_on_achieved_speed":
				var new_module: Node = Node.new()
				new_module.set_script(preload("res://modules/explode_on_achieved_speed.gd"))
				new_module.trigger_speed = data_dict.explode_on_achieved_speed.trigger_speed
				scene.modules[module]["scene"] = new_module
			"overbright_and_normalize_on_achieved_speed":
				var new_module: Node = Node.new()
				new_module.set_script(preload("res://modules/overbright_and_normalize_on_achieved_speed.gd"))
				new_module.current_modulation = data_dict.overbright_and_normalize_on_achieved_speed.initial_modulation
				new_module.sprite_name_to_modulate = data_dict.overbright_and_normalize_on_achieved_speed.sprite_name_to_modulate
				scene.modules[module]["scene"] = new_module
			"create_split_up_asteroids_when_destroyed":
				var new_module: Node = Node.new()
				new_module.set_script(preload("res://modules/create_split_up_asteroids_when_destroyed.gd"))
				new_module.number = data_dict.create_split_up_asteroids_when_destroyed.number
				scene.modules[module]["scene"] = new_module
			"electric_discharge":
				var new_module: Node = Node.new()
				new_module.set_script(preload("res://modules/electric_discharge.gd"))
				new_module.cooldown = data_dict.electric_discharge.cooldown
				new_module.damage = data_dict.electric_discharge.damage
				new_module.attack_range = data_dict.electric_discharge.range
				new_module.maximum_number_of_targets = data_dict.electric_discharge.maximum_number_of_targets
				scene.modules[module]["scene"] = new_module
			"type_shifting":
				var new_module: Node = Node.new()
				new_module.set_script(preload("res://modules/type_shifting.gd"))
				new_module.shift_duration = data_dict.type_shifting.shift_duration
				scene.modules[module]["scene"] = new_module
			"resource_credits_label":
				var new_module: Node2D = preload("res://modules/resource_credits_label.tscn").instantiate()
				scene.modules[module]["scene"] = new_module

func get_asteroid_scene(type: String, rarity: int, size: float, speed: float, pos: Vector2, destination: Vector2, can_have_shield: bool, shield_rarity: int) -> Area2D:
	var new_asteroid: Area2D = resource_loader.get_resource("asteroid_" + str(randi_range(1,15))).instantiate()
	if type == "random": type = get_asteroid_type()
	if !type.contains("asteroid"): type += "_asteroid"
	if size == 0: size = get_asteroid_size()
	if rarity == 0: rarity = get_asteroid_rarity()
	if pos == Vector2.ZERO: pos = get_asteroid_spawn_position()
	if rarity > 1: size += 0.03
	if speed == 0.0:
		var speed_multiplier: float = randf_range(GlobalScript.current_data.asteroids.general.base_speed_multipliers_thresholds[0], GlobalScript.current_data.asteroids.general.base_speed_multipliers_thresholds[1])
		speed = GlobalScript.current_data.asteroids.general.base_speed * speed_multiplier
	if can_have_shield and shield_rarity == 0: shield_rarity = test_shield_chance_and_get_tier()
	if shield_rarity >= 1: grant_shield_scene(shield_rarity, new_asteroid)
	new_asteroid.global_position = pos
	new_asteroid.scale = Vector2(size, size)
	new_asteroid.rarity = rarity
	new_asteroid.get_node("Asteroid").modulate = GlobalScript["current_data"]["asteroids"]["tiers"][rarity]["modulation"]
	new_asteroid.base_speed = speed
	if destination == Vector2.ZERO: destination = get_asteroid_destination_position()
	new_asteroid.destination = destination
	new_asteroid.direction = new_asteroid.global_position.direction_to(new_asteroid.destination)
	new_asteroid.z_index = game.get_display_index("asteroids")
	new_asteroid.type = type
	new_asteroid.add_to_group("asteroids")
	new_asteroid.add_to_group("explosive")
	var data_dict: Dictionary = GlobalScript["current_data"]["asteroids"][type]
	if data_dict.has("is_regular"):
		new_asteroid.is_regular = true
		new_asteroid.credits_reward = GlobalScript.current_data.rewards.regular_asteroid
	var comp_color: Color = GlobalScript.get_composition_color(data_dict)
	if data_dict.has("explosion"):
		var new_explosion: Area2D = get_explosion_scene(type, data_dict, comp_color)
		new_asteroid.explosion_scene = new_explosion
	apply_parameters(new_asteroid, data_dict)
	if data_dict.has("modules"): apply_modules(new_asteroid, data_dict["modules"])
	apply_audio_visual_effects(new_asteroid, data_dict, GlobalScript.current_data.asteroids.general.audio_visual_effects, comp_color)
	apply_audio_visual_effects(new_asteroid, data_dict, data_dict.audio_visual_effects, comp_color)
	return new_asteroid
	
func get_asteroid_type() -> String:
	var asteroid_type_to_return: String
	var threshold_chance_number: int = rngs.asteroid_type.randi_range(1, 10000)
	for dict in GlobalScript.current_data.asteroids:
		if GlobalScript["current_data"]["asteroids"][dict].has("spawn"):
			if threshold_chance_number in range (GlobalScript["current_data"]["asteroids"][dict]["spawn"]["chance_thresholds"][0], GlobalScript["current_data"]["asteroids"][dict]["spawn"]["chance_thresholds"][1] + 1):
				asteroid_type_to_return = dict
				break
	return asteroid_type_to_return
				
func get_asteroid_size() -> float:
	var size: float
	var rng_asteroid_size: int = rngs.asteroid_size.randi_range(-20,21) + GlobalScript.current_data.game.day
	if rng_asteroid_size > 100: size = 0.39
	elif rng_asteroid_size > 90: size = 0.36
	elif rng_asteroid_size > 75: size = 0.33
	elif rng_asteroid_size > 60: size = 0.30
	elif rng_asteroid_size > 50: size = 0.27
	elif rng_asteroid_size > 35: size = 0.25
	elif rng_asteroid_size > 20: size = 0.23
	elif rng_asteroid_size > 16: size = 0.19
	else: size = 0.17
	return size
	
func get_asteroid_rarity() -> int:
	var tier_to_return: int
	var threshold_chance_number: int = rngs.asteroid_rarity.randi_range(1, 10000)
	for tier in range (1, 6):
		if threshold_chance_number in range (GlobalScript["current_data"]["asteroids"]["tiers"][tier]["spawn_chance_thresholds"][0], GlobalScript["current_data"]["asteroids"]["tiers"][tier]["spawn_chance_thresholds"][1] + 1):
			tier_to_return = tier
			break
	return tier_to_return
			
func get_asteroid_spawn_position() -> Vector2:
	var side: int
	if !side_spawn.enabled:
		if rngs.side_spawn.randi_range(0,100) <= side_spawn.chance_tested_every_asteroid:
			side_spawn.enabled = true
			side_spawn.asteroids_left = randi_range(floor(GlobalScript.current_data.asteroids.general.asteroids_total * side_spawn.percent_thresholds_from_total_number_of_asteroids[0]), floor(GlobalScript.current_data.asteroids.general.asteroids_total * side_spawn.percent_thresholds_from_total_number_of_asteroids[1]))
			side_spawn.side = randi_range(1, 2)

	if side_spawn.enabled:
		side = side_spawn.side
		side_spawn.asteroids_left -= 1
		if side_spawn.asteroids_left == 0: side_spawn.enabled = false
	else:
		side = randi_range(1,2)
	
	var path_follower: PathFollow2D
	if side == 1:
		path_follower = left_asteroid_spawn_path_follower
	else: 
		path_follower = right_asteroid_spawn_path_follower
	path_follower.progress_ratio = randf()
		
	return path_follower.global_position

func get_asteroid_destination_position() -> Vector2:
	var side: int
	if !side_destination.enabled:
		if rngs.side_destination.randi_range(0,100) <= side_destination.chance_tested_every_asteroid:
			side_destination.enabled = true
			side_destination.asteroids_left = randi_range(floor(GlobalScript.current_data.asteroids.general.asteroids_total * side_destination.percent_thresholds_from_total_number_of_asteroids[0]), floor(GlobalScript.current_data.asteroids.general.asteroids_total * side_destination.percent_thresholds_from_total_number_of_asteroids[1]))
			side_destination.side = randi_range(1, 3)

	if side_destination.enabled:
		side = side_destination.side
		side_destination.asteroids_left -= 1
		if side_destination.asteroids_left == 0: side_destination.enabled = false
	else:
		side = randi_range(1,3)
	
	var path_follower: PathFollow2D
	if side == 1:
		path_follower = left_asteroid_destination_path_follower
	elif side == 2:
		path_follower = middle_asteroid_destination_path_follower
	else: 
		path_follower = right_asteroid_destination_path_follower
	path_follower.progress_ratio = randf()
		
	return path_follower.global_position

func test_shield_chance_and_get_tier() -> int:
	var tier_to_return: int = 0
	var threshold_chance_number: int = rngs.asteroid_shield.randi_range(1, 10000)
	for tier in range (1, 6):
		if threshold_chance_number in range (GlobalScript["current_data"]["asteroids"]["tiers"][tier]["shield_chance_thresholds"][0], GlobalScript["current_data"]["asteroids"]["tiers"][tier]["shield_chance_thresholds"][1] + 1):
			tier_to_return = tier
			break
	return tier_to_return
	
func grant_shield_scene(tier: int, asteroid: Area2D) -> void:
	var new_asteroid_shield: Area2D = resource_loader.get_resource("asteroid_shield").instantiate()
	new_asteroid_shield.rarity = tier
	var shield_scale: float = randf_range(0.75, 1.0)
	new_asteroid_shield.scale = Vector2(shield_scale, shield_scale)
	new_asteroid_shield.parent = asteroid
	new_asteroid_shield.z_index = game.get_display_index("asteroid_shields")
	if tier == 2: new_asteroid_shield.modulate = Color(0.5, 1, 0.5)
	elif tier == 3: new_asteroid_shield.modulate = Color(0.5, 0.5, 1)
	elif tier == 4: new_asteroid_shield.modulate = Color(1, 0.5, 0.5)
	elif tier == 5: new_asteroid_shield.modulate = Color(1, 0.8, 0.2)
	await asteroid.ready_to_process
	new_asteroid_shield.global_position = asteroid.global_position
	apply_audio_visual_effects(new_asteroid_shield,  GlobalScript.current_data.asteroids.shields, GlobalScript.current_data.asteroids.shields.audio_visual_effects, new_asteroid_shield.modulate)
	get_parent().add_child(new_asteroid_shield)
	
func apply_audio_visual_effects(scene: Area2D, data_dict: Dictionary, data_avfx: Dictionary, comp_color: Color) -> void:
	var scene_avfx: Dictionary = scene["audio_visual_effects"]
	var vfx_data: Dictionary
	for category in data_avfx:
		if !scene_avfx.has(category): scene_avfx[category] = {}
		match category:
			"sound_when_damaged", "sound_when_launched", "sound_when_destroyed":
				scene_avfx[category] = data_avfx[category].duplicate(true)
			"visuals_when_launched", "visuals_when_destroyed", "visuals_when_damaged":
				for visual in data_avfx[category]: # <- array -> dictionary
					var new_vfx_scene # celowo bez typu, dict i tak jest dynamiczny gdy sluzy jako wieksza baza danych
					new_vfx_scene = resource_loader.get_resource(visual).instantiate()
					new_vfx_scene.add_to_group("vfx")
					new_vfx_scene.z_index = game.get_display_index("visual_effects")
					vfx_data = GlobalScript.VFX_DATA[visual]
					var dict_slot: int = scene_avfx[category].size() + 1
					scene_avfx[category][dict_slot] = {}
					for parameter in vfx_data: match parameter:
						"modulate_to_comp_color":
							new_vfx_scene.modulate = comp_color
							scene_avfx[category][dict_slot]["modulate_to_comp_color"] = true
						"follow_parent":
							new_vfx_scene.follow_parent = true
						"not_removable":
							scene_avfx[category][dict_slot]["not_removable"] = true
						"adjust_amount_ratio_to_scale_factor":
							scene_avfx[category][dict_slot]["adjust_amount_ratio_to_scale_factor"] = true
						"initial_amount_ratio_variation":
							scene_avfx[category][dict_slot]["initial_amount_ratio_variation"] = randf_range(0.0, vfx_data["initial_amount_ratio_variation"])
						"assign_as_child_of":
							match vfx_data["assign_as_child_of"]:
								"explosion":
									new_vfx_scene.parent = scene.explosion_scene
								"object":
									new_vfx_scene.parent = scene
						"modulate_to_tier":
							new_vfx_scene.modulate = GlobalScript["current_data"]["asteroids"]["tiers"][scene.rarity]["modulation"]
						"scaling_reference":
							scene_avfx[category][dict_slot]["scaling_reference"] = vfx_data["scaling_reference"]
							if vfx_data["scaling_reference"] == "area_of_effect":
								scene_avfx[category][dict_slot]["area_of_effect_scale_factor"] = data_dict.explosion.area_of_effect / vfx_data["area_of_effect"]
					scene_avfx[category][dict_slot]["scene"] = new_vfx_scene
