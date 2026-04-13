extends Area2D
var data: Dictionary
var durability_bar: ProgressBar
var attack_readiness_bar: ProgressBar
var audio_visual_effects: Dictionary = {}
var last_cooldown: float
var source: Area2D = self
var resource_credits: int = 0
var ray_caster: Node2D = null
var snake_case_name: String
var target_range: float = 0.0
var current_target: Area2D = null
var ms_to_change_target: int = 200
var ms_left_to_change_target: int = 0
var ms_to_turn_off_attacking_state: int = 300
var ms_left_to_turn_off_attacking_state: int = 0
var ms_to_wait_for_target_to_be_in_attack_range: int = 400
var ms_left_to_wait_for_target_to_be_in_attack_range: int = 0
var ms_to_scan_sky: int = 50
var ms_left_to_scan_sky: int = 0
var ray_starting_point: Vector2
var ray_ending_point: Vector2
var state: String = "idle"

@onready var game: Node2D = get_node("/root/Game")
@onready var audio_bus: Node = get_node("/root/Game/AudioBus")
@onready var resource_loader: Node = get_node("/root/Game/ResourceLoader")

func _ready():
	await game.game_ready
	var self_name = self.get_name()
	snake_case_name = self_name.to_snake_case()
	data = GlobalScript["current_data"]["structures"][snake_case_name]
	target_range = data.attack_range + 50
	ray_caster = Node2D.new()
	ray_caster.name =  self_name + "RayCaster"
	ray_caster.set_script(resource_loader.get_scriptt("laser_turrets_ray_caster"))
	ray_caster.z_index = game.get_display_index("visual_effects")
	ray_caster.laser_turret = self
	ray_caster.laser_head_marker = $Head/Marker2D
	ms_left_to_wait_for_target_to_be_in_attack_range = ms_to_wait_for_target_to_be_in_attack_range
	game.get_node("ScenesContainer").get_node("Misc").add_child(ray_caster)
	ms_left_to_scan_sky = ms_to_scan_sky
	
func _process(delta):
	if !$CooldownTimer.is_stopped():
		attack_readiness_bar.value = 100 * (last_cooldown - $CooldownTimer.time_left) / last_cooldown
	if !data.active:
		current_target = null
		attack_readiness_bar.value = 0.0
		ray_caster.queue_free()
		set_process(false)
	if current_target != null:
		$Head.look_at(current_target.global_position)
		# ray caster musi polegać na obecnych danych 
		ray_starting_point = $Head/Marker2D.global_position
		ray_ending_point = current_target.global_position
		var distance_to_target: float = global_position.distance_to(current_target.global_position)
		if distance_to_target >= target_range:
			current_target = null
			return
		elif distance_to_target <= data.attack_range:
			if $CooldownTimer.is_stopped(): attack()
			else:
				if ms_left_to_turn_off_attacking_state > 0:
					ms_left_to_turn_off_attacking_state -= delta * 1000
				else:
					state = "cooldown"
		else:
			if state != "targeting": 
				ms_left_to_wait_for_target_to_be_in_attack_range = ms_to_wait_for_target_to_be_in_attack_range
			ms_left_to_wait_for_target_to_be_in_attack_range -= delta * 1000
			if ms_left_to_wait_for_target_to_be_in_attack_range <= 0:
				current_target = null
			state = "targeting"
	else: 
		if ms_left_to_change_target > 0: ms_left_to_change_target -= delta * 1000
		if ms_left_to_change_target > 0: return
		state = "idle"
		ms_left_to_scan_sky -= delta * 1000
		if ms_left_to_scan_sky <= 0:
			ms_left_to_scan_sky = ms_to_scan_sky
			scan_sky_and_pick_target()
		
func scan_sky_and_pick_target() -> void:
	var query_shape = CircleShape2D.new()
	query_shape.radius = target_range
	var query_params = PhysicsShapeQueryParameters2D.new()
	query_params.collide_with_areas = true
	query_params.collide_with_bodies = false
	query_params.shape = query_shape
	query_params.transform = Transform2D(0, global_position)
	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query_params, 200)
	for result in results:
		var object = result.collider
		if object != self and object.is_in_group("asteroids") and object.entered_screen and !object.is_in_group("ghosts"):
			if data.prioritize_lowest_altitude_targets:
				if current_target == null || object.global_position.y > current_target.global_position.y:
					current_target = object
			else:
				current_target = object
				break
				
func attack():
	$AttackParticles.emitting = true
	$AttackParticles.global_position = $Head/Marker2D.global_position
	$LightEffect.global_position = $Head/Marker2D.global_position
	$AnimationPlayer.play("light")
	audio_bus.play_audio("laser_attack")
	if current_target.take_damage(data.damage, self): current_target = null
	state = "attacking"
	ms_left_to_change_target = ms_to_change_target
	ms_left_to_turn_off_attacking_state = ms_to_turn_off_attacking_state
	last_cooldown = 1 / data.attack_speed
	$CooldownTimer.start(last_cooldown)
	
func _on_area_2d_mouse_entered() -> void:
	pass

func take_damage(damage: float, _attacker: Area2D) -> void:
	game.damage_structure(self, damage)
