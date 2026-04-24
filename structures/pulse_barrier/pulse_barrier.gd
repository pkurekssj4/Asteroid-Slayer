extends Area2D
var durability_bar: ProgressBar
var attack_readiness_bar: ProgressBar
var audio_visual_effects: Dictionary = {}
var last_cooldown: float
var readiness: float = 0.0
var resource_credits: int = 0
var data: Dictionary
var snake_case_name: String
var target_range: float
var ms_to_scan_sky: int = 300
var ms_left_to_scan_sky: int = 0
var source: Area2D = self
var cooldown_timer: Timer
@onready var game: Node2D = get_node("/root/Game")
@onready var vfx_scenes_container: Node = get_node("/root/Game/ScenesContainer/VFX")
@onready var audio_bus: Node = get_node("/root/Game/AudioBus")
@onready var resource_loader: Node = get_node("/root/Game/ResourceLoader")

func _ready():
	await game.game_ready
	snake_case_name = self.get_name().to_snake_case()
	data = GlobalScript["current_data"]["structures"][snake_case_name]
	target_range = data.attack_range + 50
	ms_left_to_scan_sky = ms_to_scan_sky
	cooldown_timer = Timer.new()
	cooldown_timer.name = "AttackCooldown"
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	
func _process(delta):
	if !cooldown_timer.is_stopped():
		readiness = (last_cooldown - cooldown_timer.time_left) / last_cooldown
		attack_readiness_bar.value = 100 * readiness
		$PointLight2D.energy = readiness * 1.5
		$PulseBarrierEye.modulate = Color(readiness, readiness, readiness, 1)
	else:
		ms_left_to_scan_sky -= delta * 1000
		if ms_left_to_scan_sky <= 0:
			ms_left_to_scan_sky = ms_to_scan_sky
			scan_sky()
	if !data.active:
		set_process(false)
		$PointLight2D.energy = 0.0
		$PulseBarrierEye.modulate = Color(0, 0, 0)
		attack_readiness_bar.value = 0.0

func launch_wave() -> void:
	var wave: Node2D = Node2D.new()
	wave.name = get_name() + "Shockwave"
	wave.set_script(resource_loader.get_scriptt("pulse_barriers_shockwave"))
	wave.global_position = $WaveEpicenterMarker2D.global_position
	wave.target_radius = data.attack_range + 5
	wave.z_index = game.get_display_index("visual_effects")
	vfx_scenes_container.add_child(wave)

func scan_sky():
	var query_shape = CircleShape2D.new()
	query_shape.radius = data.attack_range
	var query_params = PhysicsShapeQueryParameters2D.new()
	query_params.collide_with_areas = true
	query_params.collide_with_bodies = false
	query_params.shape = query_shape
	query_params.transform = Transform2D(0, $WaveEpicenterMarker2D.global_position)	
	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query_params, 200)
	var targets_number: int = 0
	var targets := {}
	var targets_to_be_sorted := {}
	for result in results:
		var object = result.collider
		if object != self and object.is_in_group("asteroids") and object.entered_screen and !object.is_in_group("ghosts"):
			var object_id = object.get_instance_id()  # Unikalny identyfikator instancji
			if data.prioritize_lowest_altitude_targets:
				if !targets_to_be_sorted.has(object_id):
					if targets_number != data.maximum_number_of_targets: targets_number += 1
					targets_to_be_sorted[object_id] = [object, object.global_position.y]
			else:
				if !targets.has(object_id):
						targets_number += 1
						targets[object_id] = object
						if targets_number == data.maximum_number_of_targets: break
	if targets_number >= data.minimum_number_of_targets:
		if data.prioritize_lowest_altitude_targets:
			var sorted_targets = targets_to_be_sorted.keys()
			sorted_targets.sort_custom(func(a, b): return targets_to_be_sorted[a][1] > targets_to_be_sorted[b][1])
			var first_keys = sorted_targets.slice(0, targets_number)
			for key in first_keys:
				targets[key] = targets_to_be_sorted[key][0]
		for i in targets.keys():
			if is_instance_valid(targets[i]): targets[i].take_damage(data.damage, self)
		audio_bus.play_audio("pulse_barrier_attack")
		launch_wave()
		last_cooldown = 1 / data.attack_speed
		cooldown_timer.start(last_cooldown)
		
func take_damage(damage: float, _attacker: Area2D) -> void:
	game.damage_structure(self, damage)
