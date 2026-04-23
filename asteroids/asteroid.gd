extends Area2D
# states / flags
var is_flashing: bool = false
var flashing_duration: float = 0.0

var explosion_scene: Area2D
var audio_visual_effects: Dictionary = {}
var collision_parameters: Dictionary = {}
var modules: Dictionary = {}
var current_pull_force: float
var target_pull_force: float
var pull_force_center: Vector2
var slow_power_during_pull: float
var credits_reward: int = 0
var is_regular: bool # rozroznienie niektorych eventowych od normalnych
var type: String
var speed: float
var base_speed: float
var target_speed: float
var speed_multiplier: float = 0.0
var freezes_by_asteroids: int = 0
var freezing_asteroids_actual_slow_power: float = 0.0
var direction: Vector2
var destination: Vector2
var rotation_dir: float = randf_range(-0.5, 0.5)
var resource_credits: int = 0
var rarity: int = 0
var source: Area2D = self
var stasis_field_slow_power: float = 0.0
var entered_screen: int = false
var is_on_initial_trajectory: bool = true
var durability_points: float
var destroy_threshold: float = 0.15
var exploded: bool = false

@onready var object_events_hub: Node = get_node("/root/Game/ObjectEventsHub")
@onready var resource_loader: Node = get_node("/root/Game/ResourceLoader")
@onready var game: Node2D = get_node("/root/Game")
@onready var fabricated_scenes_manager: Node = get_node("/root/Game/FabricatedScenesManager")
@onready var fever: Node = get_node("/root/Game/Fever")

signal ready_to_process
signal ready_to_free

func _ready():
	set_initial_durability_points()
	adjust_collision_damage_to_scale()
	if is_flashing: 
		await start_flashing(flashing_duration)
	emit_signal("ready_to_process")
	
func _process(delta):
	calculate_speed_and_trajectory(delta)
	rotation += rotation_dir * delta
	global_position += direction * speed * delta
	
func calculate_speed_and_trajectory(delta) -> void:
	if GlobalScript.current_data.abilities.stasis_field.enabled:
		stasis_field_slow_power = GlobalScript.current_data.abilities.stasis_field.slow_power / 100.0
	else:
		stasis_field_slow_power = 0.0

	speed_multiplier = 1.0 - (freezing_asteroids_actual_slow_power + stasis_field_slow_power + slow_power_during_pull) # -shockwave.force
	target_speed = base_speed * speed_multiplier
	if target_speed < 0.0: target_speed = 0.0
	
	if speed != target_speed:
		lerp_speed(delta)
	else:
		if current_pull_force > 0:
			if current_pull_force < target_pull_force:
				current_pull_force += target_pull_force / (180 * delta) # daje okolo 4 sekundy do osiagniecia maksymalnej siły
			var direction_to_pull_force_center: Vector2 = global_position.direction_to(pull_force_center)
			lerp_trajectory(direction_to_pull_force_center, current_pull_force)
		elif !is_on_initial_trajectory:
			var direction_to_initial_destination: Vector2 = global_position.direction_to(destination)
			lerp_trajectory(direction_to_initial_destination, 2 * delta)
			if direction.distance_to(direction_to_initial_destination) < 0.001: #direction pokazuje 6 miejsc po przecinku, ale faktycznie posiada większą dokładność, dlatego direction == initial_direction nie spełnia warunku i stąd też warunek z tolerancją
				is_on_initial_trajectory = true
	
func take_damage(damage: float, attacker: Area2D) -> bool:
	if !entered_screen: return false
	damage /= rarity
	fever.progress(damage, attacker, self)
	durability_points -= damage
	if durability_points <= 0.0:
		if is_instance_valid(attacker.source): source = attacker.source
		game.add_credits(source, credits_reward + resource_credits, self.global_position)
		emit_signal("ready_to_free")
		game.add_object(false, self)
		return true
	var new_scale: float = destroy_threshold + (durability_points / 1000.0)
	scale = Vector2(new_scale, new_scale)
	adjust_collision_damage_to_scale()
	object_events_hub.execute_fx("damaged", self)
	return false
		
func apply_slow_by_asteroid(slow: bool, slow_power: float, extra_slow_power: float) -> void:
	#Gra musi liczyć ilość spowolnień. W innym wypadku bedzie psuć slow z innych asteroid.
	if slow:
		freezes_by_asteroids += 1
	else:
		freezes_by_asteroids -= 1
	if freezes_by_asteroids > 0:
		# slow power to baza np 20% + ekstra np 10% spowolnienia liczonego z bazy za każdy dodatkowy slow czyli 2% za kazdy dodatkowy slow
		# przyklad: 3 slowy to 24%: 20 + 2 + 2
		var bonus = 0.0
		if freezes_by_asteroids > 1: bonus = ((freezes_by_asteroids - 1) * extra_slow_power) * slow_power #each extra slow by asteroid gives extra x% slow
		freezing_asteroids_actual_slow_power = slow_power + bonus
	else: freezing_asteroids_actual_slow_power = 0.0
	
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if !entered_screen:
		GlobalScript.current_data.asteroids.general.asteroids_on_screen += 1
		entered_screen = true

func apply_shockwave_force(shockwave_center: Vector2, force: float) -> void:
	speed = (speed * 0.3) + (force * 10)
	is_on_initial_trajectory = false
	direction = (global_position - shockwave_center).normalized()
	
func apply_pull_force(center: Vector2, force: float, slow_power: float) -> void:
	force /= 100.0
	slow_power /= 100.0
	current_pull_force = force / 300
	target_pull_force = force
	pull_force_center = center
	slow_power_during_pull = slow_power
	is_on_initial_trajectory = false
	
func reset_pull_force() -> void:
	current_pull_force = 0.0
	slow_power_during_pull = 0.0
	
func lerp_trajectory(dir, force) -> void:
	direction = lerp(direction, dir, force).normalized()
	
func lerp_speed(delta) -> void:
	speed = lerp(speed, target_speed, delta * 3)
	if speed > target_speed:
		if target_speed / speed >= 0.96: speed = target_speed
	elif speed < target_speed:
		if speed / target_speed >= 0.96: speed = target_speed

func start_flashing(time_sec: float) -> void:
	add_to_group("ghosts")
	set_process(false)
	var new_shader_material: ShaderMaterial = ShaderMaterial.new()
	var new_shader: Shader = resource_loader.get_shader("asteroid_flashing")
	new_shader_material.shader = new_shader
	$Asteroid.material = new_shader_material
	speed = 0
	var shader_data: Dictionary = {
		"wave_amplitude": {
			"initial": 0.4,
			"target": 0.0,
		},
		"wave_speed": {
			"initial": 0.3,
			"target": 0.0,
		},
		"custom_color": {
			"initial": Vector4(10, 10, 10, 0),
			"target": Vector4(1, 1, 1, 1)
		},
		"phase": {
			"initial": 100,
			"target": 200
		}
	}
	for parameter in shader_data:
		var parameter_tween: Tween = create_tween()
		parameter_tween.set_trans(Tween.TRANS_LINEAR)
		parameter_tween.set_ease(Tween.EASE_OUT)
		parameter_tween.tween_method(func(value): $Asteroid.material.set_shader_parameter(parameter, value), shader_data[parameter]["initial"], shader_data[parameter]["target"], time_sec)
	$Asteroid.material.set("shader_parameter/frequency", randf_range(8.0, 14.0))
	await game.create_delay_timer(time_sec)
	is_flashing = false
	remove_from_group("ghosts")
	set_process(true)

func _on_area_entered(area: Area2D) -> void:
	object_events_hub.resolve_collision(true, self, area)
	
func adjust_collision_damage_to_scale() -> void:
	if explosion_scene == null or !explosion_scene.collision_parameters.has("damage"):
		collision_parameters.damage = scale.x * 100
	
func change_type(target_type: String) -> void:
	for module in modules:
		if module == "resource_credits_label" and resource_credits > 0 and target_type != "electric_asteroid": pass
		else: modules[module]["scene"].queue_free()
	modules.clear()
	var data_dict: Dictionary = GlobalScript.current_data.asteroids[target_type]
	var comp_color: Color = data_dict["composition_color"]
	for category in audio_visual_effects:
		if category.contains("sound"):
			if !audio_visual_effects[category].has("not_removable"): audio_visual_effects[category].clear()
		else:
			for effect in audio_visual_effects[category]:
				if !audio_visual_effects[category][effect].has("not_removable"): 
						audio_visual_effects[category][effect]["scene"].queue_free()
						audio_visual_effects[category].erase(effect)
				elif audio_visual_effects[category][effect].has("modulate_to_comp_color"): audio_visual_effects[category][effect]["scene"].modulate = comp_color
	fabricated_scenes_manager.apply_audio_visual_effects(self, data_dict, data_dict["audio_visual_effects"], comp_color)
	fabricated_scenes_manager.apply_parameters(self, data_dict)
	if data_dict.has("modules"):
		fabricated_scenes_manager.apply_modules(self, data_dict.modules)
	if data_dict.has("explosion"):
		if explosion_scene != null: explosion_scene.queue_free()
		explosion_scene = fabricated_scenes_manager.get_explosion_scene(target_type, data_dict, comp_color)
	else:
		explosion_scene = null
		adjust_collision_damage_to_scale()
	object_events_hub.add_applied_modules(self)
	object_events_hub.execute_fx("launch", self)
	type = target_type
	emit_signal("ready_to_process")

func set_initial_durability_points() -> void:
	# Asteroida np 0.17 - 0.15 = 0.02 * 1000 = 20 wytrzymałości
	# Eventowe asteroidy mniejsze niż próg zniszczenia mają zerowaną wytrzymałość po pierwszej kalkulacji
	# Dodatkowo wszystkie asteroidy mają doliczoną wytrzymałość ze skali.x
	# Jest to dodatkowy fever progress za każdą asteroide nawet tą poniżej progu zniszczenia + logika że nawet najmniejsza asteroida musiała otrzymać jakiś damage
	# Asteroida np 0.1 ma 0 wytrzymałości po pierwszej kalkulacji, bo poniżej progu zniszczenia, ale 0.1 * 50 = 5 dodatkowej wytrzymałości, 8.5 dla asteroidy 0.2, łącznie dla niej 28.5.
	durability_points = (scale.x - destroy_threshold) * 1000
	if durability_points < 0.0: durability_points = 0.0
	durability_points += scale.x * 50
