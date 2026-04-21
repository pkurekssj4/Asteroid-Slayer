extends Area2D
const TOOLTIP_SCENE = preload('res://tooltip_ingame.tscn')
var audio_visual_effects: Dictionary = {}
var durability_bar: ProgressBar
var bonus_progress_bar: ProgressBar
var snake_case_name: String
var source: Area2D = self
var display_name: String
var statistic_snake_case_name: String
var statistic_display_name: String
var function: String
var data: Dictionary
var durability_points: float
@onready var game: Node2D = get_node("/root/Game")
@onready var cannon: Area2D = get_node("/root/Game/Cannon")
@onready var object_events_hub: Node = get_node("/root/Game/ObjectEventsHub")

func _ready() -> void:
	await game.game_ready
	snake_case_name = self.get_name().to_snake_case()
	display_name = snake_case_name.capitalize()
	data = GlobalScript["current_data"]["structures"][snake_case_name]
	durability_points = data.durability.current_points
	if data.has("bonuses_for_other_objects"): 
		function = get_function(snake_case_name)
		bonus_progress_bar.value = (data.bonuses_for_other_objects.total_growth_rate_multiplicator / data.bonuses_for_other_objects.max_growth_rate_multiplicator) * 100.0
	if data.has("dish") and data.active: $AnimationPlayer.seek(randf_range(0.2, 2.8))

func take_damage(damage: float, _attacker: Area2D):
	game.damage_structure(self, damage)

func get_function(statistic: String) -> String:
	var function_to_return: String
	if statistic == "explosion_amplifier":
		function_to_return = "When active, amplifies explosions of basic attacks, increasing the Area of ​​Effect."
	elif statistic == "cryo_silos":
		function_to_return = "When active, cools down the barrel, increasing Rate of Fire."
	elif statistic.contains("overclock_station"):
		function_to_return = "When active, overclocks the Cannon’s ability renewal system, reducing all Ability Cooldowns."
	elif statistic == "power_generator":
		function_to_return = "When active, delivers additional power to the cannon, increasing basic attack Damage."
	elif statistic == "plasma_reactor":
		function_to_return = "When active, accelerates energy recovery, decreasing Reload Time."
	elif statistic == "impact_prediction_center":
		function_to_return = "When active, calculates weak points of asteroids and sends it directly to the Cannon components, increasing Critical Hit Chance."
	elif statistic == "projectile_accelerator":
		function_to_return = "When active, increases the muzzle velocity, increasing Projectile Speed of all types of projectiles."
	elif statistic == "critical_power_generator":
		function_to_return = "When active, delivers an additional critical power to the cannon, increasing basic attack Critical Damage."
	elif statistic == "energy_storage_nexus":
		function_to_return = "When active, stores an additional energy, increasing Capacity."
	elif statistic.contains("radar"):
		function_to_return = "When active, scans the sky, showing how many asteroids are left to come."
	elif statistic.contains("heat_interceptor"):
		function_to_return = "When active, intercepts enormous amount of heat produced by Cannon and explosion on the sky, increasing statistics granted by Fever."
	elif statistic.contains("ion_flux_turbine"):
		function_to_return = "A high-efficiency energy conduit that enhances the performance of auxiliary defense systems. Laser Turret and Pulse Barrier on the same side receive a moderate boost to their operational statistics."
	return function_to_return
	
func _on_tooltip_trigger_mouse_entered() -> void:
	pass
	#var new_tooltip = TOOLTIP_SCENE.instantiate()
	#new_tooltip.global_position = get_global_mouse_position()
	#get_parent().add_child(new_tooltip)
