extends Area2D
const TOOLTIP_SCENE = preload('res://upgrade_console/tooltip_upgrade_console.tscn')
const HIGHLIGHT_PARTICLES_SCENE = preload('res://upgrade_console/upgrade_highlight_particles.tscn')
const SELECTION_EFFECT_PARTICLES = preload('res://upgrade_console/upgrade_selection_effect_particles.tscn')
var upgrade_type_snake_name: String
var upgrade_type_display_name: String
var upgrade_destination_snake_name: String
var upgrade_destination_display_name: String
var connection_lines_to_sources: Array
var tree_name: String
var branch_name: String
var upgrade_size: String
var id: int = 0
var IsPreBought: bool = false
var IsBought: bool = false
var sources: Array = []
var highlight_particles = null

@onready var upgrade_console = get_node("/root/UpgradeMenu")
@onready var trees_data = get_node("/root/UpgradeMenu").trees_data

func _ready() -> void:
	await get_tree().process_frame
	assign_data_to_upgrade()
	assign_sources_to_upgrade()
	instantiate_particles_emitter()
	draw_connection_lines_to_sources()
	adjust_modulation()

func assign_data_to_upgrade() -> void:
		
	for destination in upgrade_console.destination_pascal_names:
		if self.get_name().contains(destination):
			upgrade_destination_snake_name = destination.to_snake_case()
			upgrade_destination_display_name = destination.capitalize()
			break

	var upgrade_pascal_names: Array
	for upgrade in upgrade_console.regular_upgrades_pascal_names: upgrade_pascal_names.append(upgrade)
	for upgrade in upgrade_console.other_upgrades_pascal_names: upgrade_pascal_names.append(upgrade)
	
	for upgrade in upgrade_pascal_names:
		if self.get_name().contains(upgrade):
			upgrade_type_snake_name = upgrade.to_snake_case()
			upgrade_type_display_name = upgrade.capitalize()
			for i in range(0, get_parent().get_child_count() + 1):
				var upgrade_string = "Upgrade" + str(i) + upgrade
				if str(self).contains(upgrade_string):
					id = i
					break
			break
	
	for size in ["Small", "Medium", "Big"]:
		if self.get_name().contains(size):
			upgrade_size = size.to_snake_case()
			break

func assign_sources_to_upgrade() -> void:
	var upgrade_sources := []
	if upgrade_destination_snake_name in trees_data["abilities"]["upgrade_destinations"]:
		tree_name = "abilities"
		branch_name = get_parent().get_name().to_snake_case()
		if upgrade_destination_snake_name == "plasma_barrage":
			# has only one source with only one lower id number
			if id in [1, 2, 3, 6, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32, 33]:
				upgrade_sources = [id - 1]
				# other cases
			elif id == 4: upgrade_sources = [3, 6, 8]
			elif id == 5 || id == 7: upgrade_sources = [2]
			elif id == 9: upgrade_sources = [4]
			elif id == 21: upgrade_sources = [16]
			elif id == 25: upgrade_sources = [20, 24]
			elif id == 34 || id == 35: upgrade_sources = [32]
			elif id == 36: upgrade_sources = [33, 34, 35]
			
		elif upgrade_destination_snake_name == "stasis_field":
			if id in [1, 2, 3, 4, 5, 7, 8, 10, 11, 12, 13, 15, 16, 18]:
				upgrade_sources = [id - 1]
			elif id == 6: upgrade_sources = [2]
			elif id == 9: upgrade_sources = [5, 8]
			elif id == 14: upgrade_sources = [10]
			elif id == 17: upgrade_sources = [13, 16]
				
		elif upgrade_destination_snake_name == "gravity_well":
			if id in [1, 2, 3, 4, 6, 7, 9, 10, 12, 13, 14, 15, 17, 18, 20, 21, 23, 27]:
				upgrade_sources = [id - 1]
			elif id == 5 || id == 8: upgrade_sources = [1]
			elif id == 11: upgrade_sources = [7, 4, 10]
			elif id == 16 || id == 19: upgrade_sources = [12]
			elif id == 22: upgrade_sources = [18, 15, 21]
			elif id == 24 || id == 25: upgrade_sources = [22]
			elif id == 26: upgrade_sources = [24, 23, 25]
				
		elif upgrade_destination_snake_name == "orbital_strike":
			if id in [1, 2, 3, 4, 5, 6, 9, 10, 12, 13, 15, 16, 17, 18, 19, 20, 22, 23, 24, 25, 27, 28, 29, 30, 32]:
				upgrade_sources = [id - 1]
			elif id == 8 || id == 11: upgrade_sources = [4]
			elif id == 7: upgrade_sources = [10, 6, 13]
			elif id == 14: upgrade_sources = [7]
			elif id == 21: upgrade_sources = [15]
			elif id == 26: upgrade_sources = [20, 25]
			elif id == 31: upgrade_sources = [28]
			elif id == 33: upgrade_sources = [30, 32]
					
	elif upgrade_destination_snake_name == "cannon":
		tree_name = "cannon"
		branch_name = get_parent().get_name().to_snake_case()
		if branch_name == "damage":
			if id in [1, 3, 4, 6, 7, 9, 16, 17, 24, 27, 29, 30, 34, 35, 36, 38, 39, 42, 43, 44]: upgrade_sources = [id - 1]
			elif id in [2, 5]: upgrade_sources = [1]
			elif id == 8: upgrade_sources = [7, 4]
			elif id in [10, 11]: upgrade_sources = [9]
			elif id in [14, 13, 12]: upgrade_sources = [11]
			elif id == 15: upgrade_sources = [14, 13, 12]
			elif id in [18, 19]: upgrade_sources = [17]
			elif id in [20, 21, 22]: upgrade_sources = [19]
			elif id == 23: upgrade_sources = [20, 21, 22]
			elif id in [25, 26]: upgrade_sources = [24]
			elif id in [37, 28]: upgrade_sources = [27]
			elif id == 31: upgrade_sources = [30, 39]
			elif id in [32, 33]: upgrade_sources = [30]
			elif id in [40, 41]: upgrade_sources = [39]
			
		if branch_name == "critical":
			if id in [1, 6, 12, 13, 14, 18, 19, 25, 26, 28, 33, 36, 41, 44, 46, 49, 51]: upgrade_sources = [id - 1]
			elif id in [3, 2, 4]: upgrade_sources = [1]
			elif id == 5: upgrade_sources = [3, 2, 4]
			elif id in [27, 8, 7]: upgrade_sources = [6]
			elif id in [9, 10]: upgrade_sources = [8]
			elif id == 11: upgrade_sources = [9, 10]
			elif id in [15, 21]: upgrade_sources = [14]
			elif id == 22: upgrade_sources = [15, 21]
			elif id in [16, 17]: upgrade_sources = [15]
			elif id == 20: upgrade_sources = [19, 26]
			elif id in [23, 24]: upgrade_sources = [21]
			elif id in [29, 30, 31]: upgrade_sources = [28]
			elif id == 32: upgrade_sources = [29, 30, 31]
			elif id in [34, 35]: upgrade_sources = [33]
			elif id in [37, 38, 39]: upgrade_sources = [36]
			elif id == 40: upgrade_sources = [37, 38, 39]
			elif id in [43, 42]: upgrade_sources = [41]
			elif id in [48, 45, 50]: upgrade_sources = [44]
			elif id == 47: upgrade_sources = [49, 46, 51]
		
		if branch_name == "capacity":
			if id in [2, 4, 6, 10, 15, 20, 21, 22, 24, 25, 28, 32, 36, 37, 38]: upgrade_sources = [id - 1]
			elif id in [3, 1]: upgrade_sources = [0]
			elif id == 5: upgrade_sources = [2, 4]
			elif id in [7, 8]: upgrade_sources = [6]
			elif id == 9: upgrade_sources = [7, 8]
			elif id in [11, 12]: upgrade_sources = [10]
			elif id == 13: upgrade_sources = [12, 29]
			elif id == 14: upgrade_sources = [11, 12]
			elif id in [16, 17]: upgrade_sources = [15]
			elif id == 18: upgrade_sources = [17, 33]
			elif id == 19: upgrade_sources = [16, 17]
			elif id == 23: upgrade_sources = [8]
			elif id in [27, 26]: upgrade_sources = [25]
			elif id in [29, 30]: upgrade_sources = [28]
			elif id == 31: upgrade_sources = [29, 30]
			elif id in [33, 34]: upgrade_sources = [32]
			elif id == 35: upgrade_sources = [33, 34]
			
		if branch_name == "speed":
			if id in [6, 2, 4, 13, 14, 15, 16, 19, 22, 23, 26, 29, 30, 34, 35, 37, 38, 42, 43]: upgrade_sources = [id - 1]
			elif id in [1, 3]: upgrade_sources = [0]
			elif id == 5: upgrade_sources = [2, 4]
			elif id in [7, 8]: upgrade_sources = [6]
			elif id in [9, 10, 11]: upgrade_sources = [8]
			elif id == 12: upgrade_sources = [9, 10, 11]
			elif id in [14, 21]: upgrade_sources = [13]
			elif id in [17, 18]: upgrade_sources = [16]
			elif id == 20: upgrade_sources = [19, 26]
			elif id in [24, 25]: upgrade_sources = [23]
			elif id == 27: upgrade_sources = [20]
			elif id in [28, 36]: upgrade_sources = [27]
			elif id in [31, 32, 33]: upgrade_sources = [30]
			elif id in [39, 40, 41]: upgrade_sources = [38]
			
	for source in upgrade_sources: sources.append(trees_data[tree_name]["branches"][branch_name]["upgrade_references"][source])

func instantiate_particles_emitter() -> void:
	var new_highlight_particles = HIGHLIGHT_PARTICLES_SCENE.instantiate()
	new_highlight_particles.z_index = z_index - 1
	add_child(new_highlight_particles)
	highlight_particles = new_highlight_particles
	if upgrade_size == "medium": new_highlight_particles.scale = Vector2(1.25, 1.25)
	elif upgrade_size == "big": new_highlight_particles.scale = Vector2(1.54, 1.54)
	
func adjust_modulation() -> void:
	if any_source_is_bought():
		modulate = Color (1, 1, 1, 1)
		highlight_particles.emitting = true
		if IsBought:
			highlight_particles.self_modulate = Color(0.45, 1, 0.45, 1)
		else:
			if player_can_afford():
				highlight_particles.self_modulate = Color(1, 0.55, 0.4, 1)
			else:
				highlight_particles.self_modulate = Color(1, 0.1, 0.1, 1)
	else:
		modulate = Color (0.25, 0.25, 0.25, 1)
		highlight_particles.emitting = false
		
	
	for line in connection_lines_to_sources:
		if line.target_node.IsBought:
			if IsBought:
				line.modulate = Color (0.05, 0.55, 0.05, 1)
			else:
				if player_can_afford():
					line.modulate = Color (0.3, 0.2, 0.05, 1)
				else:
					line.modulate = Color (0.3, 0.05, 0.05, 1)
		else:
			line.modulate = Color (0.05, 0.05, 0.15, 1)

func draw_connection_lines_to_sources() -> void:
	var line_color = Color(1, 1, 1, 1)
	var line_width = 0.5
	for source in sources:
		var upgrade_connection_line = Node2D.new()
		upgrade_connection_line.set_script(preload("res://upgrade_console/upgrade_connection_line.gd"))
		upgrade_connection_line.width = line_width
		upgrade_connection_line.color = line_color
		upgrade_connection_line.z_index = 2 #upgrade + particles
		get_tree().current_scene.add_child(upgrade_connection_line)
		upgrade_connection_line.point_a = global_position
		upgrade_connection_line.point_b = source.global_position
		upgrade_connection_line.target_node = source
		if !tree_name == "cannon": upgrade_connection_line.hide()
		trees_data[tree_name]["branches"][branch_name]["connection_line_references"].append(upgrade_connection_line)
		connection_lines_to_sources.append(upgrade_connection_line)
		
func _on_mouse_entered() -> void:
	return
	if !upgrade_console.activated: return
	create_tooltip()
	
func create_tooltip() -> void:
	var description: String
	if upgrade_type_snake_name in ["area_of_effect", "capacity", "cooldown", "critical_hit_chance", "critical_hit_damage", "damage", "duration", "pull_force", "projectile_speed", "rate_of_fire", "reload_time", "slow"]:
		var verb: String
		if upgrade_type_snake_name in ["cooldown", "reload_time"]: verb = "Decreases"
		else: verb = "Increases"
		description = verb + " [color=" + upgrade_console.statistic_name_color + "]" + upgrade_type_display_name + "[/color] of [color=" + upgrade_console.ability_name_color + "]" + upgrade_destination_display_name + "[/color] by [color=" + upgrade_console.statistic_value_color + "]" + str(trees_data[tree_name]["upgrade_destinations"][upgrade_destination_snake_name]["upgrades"][upgrade_size][upgrade_type_snake_name]["value"]) + "%[/color] of base value."
	elif upgrade_type_snake_name in ["projectiles", "fragments"]: description = "Increases [color=" + upgrade_console.statistic_name_color + "]" + upgrade_type_display_name + " Number[/color] of [color=" + upgrade_console.ability_name_color + "]Plasma Barrage[/color] by [color=" + upgrade_console.statistic_value_color + "]1[/color]."
	else:
		var display_name: String
		if upgrade_type_snake_name == "initial":
			display_name = upgrade_destination_display_name
		else: display_name = upgrade_type_display_name
		description = "[color=" + upgrade_console.ability_name_color + "]" + display_name + "[/color]\n" + trees_data[tree_name]["upgrade_destinations"][upgrade_destination_snake_name]["upgrades"][upgrade_size][upgrade_type_snake_name]["description"]
	
	var new_tooltip = TOOLTIP_SCENE.instantiate()
	new_tooltip.global_position = get_global_mouse_position()
	
	var description_label = new_tooltip.get_node("UpperLabel")
	description_label.text = description
	
	var cost_label = new_tooltip.get_node("LowerLabel")
	cost_label.text += "Cost: [color=ORANGE]"
	
	for currency in trees_data[tree_name]["upgrade_destinations"][upgrade_destination_snake_name]["upgrades"][upgrade_size][upgrade_type_snake_name]["cost"]:
		var new_cost_icon: Resource
		if currency.contains("credit"): new_cost_icon = preload('res://resource_icons/resource_credit.png')
		elif currency.contains("nano"): new_cost_icon = preload('res://resource_icons/nano_core.png')
		elif currency.contains("common"): new_cost_icon = preload ('res://resource_icons/common_shard.png')
		elif currency.contains("celestial"): new_cost_icon = preload('res://resource_icons/celestial_shard.png')
		elif currency.contains("astral"): new_cost_icon = preload('res://resource_icons/astral_shard.png')
		elif currency.contains("ethereal"): new_cost_icon = preload ('res://resource_icons/ethereal_shard.png')
		cost_label.add_text((str(trees_data[tree_name]["upgrade_destinations"][upgrade_destination_snake_name]["upgrades"][upgrade_size][upgrade_type_snake_name]["cost"][currency])))
		cost_label.add_image(new_cost_icon, 0, 14)
		cost_label.add_text(" ")
		
	get_tree().root.add_child(new_tooltip)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton: if event.button_index == 1 and event.pressed:
		if !upgrade_console.activated: return
		
		if !any_source_is_bought(): 
			upgrade_console.get_node("Sounds/Nok").play()
			return
		
		if !IsBought:
			if player_can_afford():
				pay(true)
				add_statistic(true)
				IsBought = true
				upgrade_console.get_node("Sounds/Ok").play()
				instantiate_upgrade_selection_effect_partilces()
			else:
				upgrade_console.get_node("Sounds/Nok").play()
		else:
			if bought_receivers_have_more_sources():
				pay(false)
				add_statistic(false)
				IsBought = false
		
		var trees_array: Array = []
		if tree_name in ["cannon", "base"]: trees_array = ["Cannon", "Base"]
		else: trees_array.append(tree_name.capitalize())
		upgrade_console.update_upgrades(trees_array)

func any_source_is_bought():
	if id == 0: return true
	for source in sources: if source.IsBought: return true

func bought_receivers_have_more_sources():
	var bought_sources: int
	for upgrade in get_parent().get_children():
		if upgrade != self && upgrade.IsBought && upgrade.sources.has(self):
			bought_sources = 0
			for source in upgrade.sources:
				if source.IsBought: bought_sources += 1
			if bought_sources < 2: return false
	return true

func player_can_afford():
	for currency in trees_data[tree_name]["upgrade_destinations"][upgrade_destination_snake_name]["upgrades"][upgrade_size][upgrade_type_snake_name]["cost"]:
		if GlobalScript.current_data.resources[currency] < trees_data[tree_name]["upgrade_destinations"][upgrade_destination_snake_name]["upgrades"][upgrade_size][upgrade_type_snake_name]["cost"][currency]: return false
	return true

func add_statistic(add: bool) -> void:
	if upgrade_type_snake_name.to_pascal_case() in upgrade_console.regular_upgrades_pascal_names:
		var stat_structure: Array[String]
		match upgrade_type_snake_name:
			"damage":
				stat_structure = ["explosion", "damage"]
			"area_of_effect":
				stat_structure = ["explosion", "area_of_effect"]
			"reload_time":
				stat_structure = ["reload_time"]
			"cooldown":
				stat_structure = ["cooldown"]
			"capacity":
				stat_structure = ["capacity"]
			"critical_hit_chance":
				stat_structure = ["explosion", "critical_hit_chance"]
			"critical_hit_damage":
				stat_structure = ["explosion", "critical_hit_damage_thresholds"]
			"projectile_speed":
				stat_structure = ["projectile_speed"]
			"rate_of_fire":
				stat_structure = ["rate_of_fire"]
			"projectiles":
				stat_structure = ["projectiles"]
			"duration":
				stat_structure = ["duration"]
			"explosion_duration":
				stat_structure = ["explosion", "duration"]
			"slow":
				stat_structure = ["slow_power"]
			"slow_during_pull_force":
				stat_structure = ["explosion", "pull_slow"]
			"pull_force":
				stat_structure = ["explosion", "pull_force"]
				
		var upgrade_value: float = trees_data[tree_name]["upgrade_destinations"][upgrade_destination_snake_name]["upgrades"][upgrade_size][upgrade_type_snake_name]["value"]
		var initial_data_dict: Dictionary = GlobalScript.get_data_source_dictionary(upgrade_destination_snake_name, "initial")
		var initial_value: Variant = GlobalScript.get_value_from_dict(stat_structure, initial_data_dict)
		var data_dict: Dictionary = GlobalScript.get_data_source_dictionary(upgrade_destination_snake_name, "current")
		if !data_dict["additive_statistics"].has("tree_upgrades"):
			data_dict["additive_statistics"]["tree_upgrades"] = {}
		data_dict = data_dict["additive_statistics"]["tree_upgrades"]
		var stat_value: Variant
		if initial_value is Array:
			stat_value = [0.0, 0.0]
			stat_value[0] = initial_value[0] * upgrade_value
			stat_value[1] = initial_value[1] * upgrade_value
			#print ("Upgrade.gd Operation: " + str(add) + "Adding array stat: " + str(stat_value))
		else:
			if upgrade_type_snake_name in ["projectiles", "fragments"]:
				stat_value = upgrade_value
			else:
				stat_value = initial_value * upgrade_value
		GlobalScript.include_additive_stats(false, "tree_upgrades")
		GlobalScript.add_stat_to_object(add, stat_value, stat_structure, data_dict)
		GlobalScript.include_additive_stats(true, "tree_upgrades")
		
	else:
		match upgrade_type_snake_name:
			"critical_gambit":
				pass
			"holistic_imbalance":
				pass
				
				
	upgrade_console.calculate_and_set_statistics_labels(upgrade_destination_snake_name)
	
func pay(add) -> void:
	if add: add = false
	else: add = true
	for currency in trees_data[tree_name]["upgrade_destinations"][upgrade_destination_snake_name]["upgrades"][upgrade_size][upgrade_type_snake_name]["cost"]:
		upgrade_console.add_resources(currency, trees_data[tree_name]["upgrade_destinations"][upgrade_destination_snake_name]["upgrades"][upgrade_size][upgrade_type_snake_name]["cost"][currency], add)

func instantiate_upgrade_selection_effect_partilces() -> void:
	var new_particles = SELECTION_EFFECT_PARTICLES.instantiate()
	if upgrade_size == "medium": new_particles.scale = Vector2(1.15, 1.15)
	elif upgrade_size == "big": new_particles.scale = Vector2(1.3, 1.3)
	add_child(new_particles)
