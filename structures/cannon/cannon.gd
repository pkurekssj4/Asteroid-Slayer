extends Area2D
const TOOLTIP_SCENE = preload('res://tooltip_ingame.tscn')
const OVERHEAT_PARTICLES_SCENE = preload("res://structures/cannon/overheat_particles.tscn")
var audio_visual_effects: Dictionary = {}
var durability_bar: ProgressBar
var attack_readiness_bar: ProgressBar
var reloading_bar: ProgressBar
var last_shooting_delay: float
var snake_case_name: String = "cannon"
var rng = RandomNumberGenerator.new()
var jamm_rng = RandomNumberGenerator.new()
var trigger_jamm_stage: int = 0
var unjamm_chance: int
var can_shoot: bool = true
var is_reloading: bool = false
var source: Area2D = self
var overheat_progress: int = 0
var shooting_control: int = 0
var jamm_chance: float = 0.5
var cannon_data: Dictionary
var abilities_data: Dictionary
var capacity_at_the_moment: int
var ability_1_icon_tween: Tween = null
var ability_2_icon_tween: Tween = null
var ability_3_icon_tween: Tween = null
var ability_4_icon_tween: Tween = null

@onready var game: Node2D = get_node("/root/Game")
@onready var progress_bar_manager: Node = get_node("/root/Game/ProgressBarManager")
@onready var resource_loader: Node = get_node("/root/Game/ResourceLoader")
@onready var fabricated_scenes_manager: Node = get_node("/root/Game/FabricatedScenesManager")
@onready var stasis_field_particles: GPUParticles2D = get_node("/root/Game/StasisFieldParticles")
@onready var plasma_barrage_icon: Sprite2D = get_node("/root/Game/GUI/Abilities/Ability1/PlasmaBarrageIcon")
@onready var plasma_barrage_label: Label = get_node("/root/Game/GUI/Abilities/Ability1/Label")
@onready var stasis_field_icon: Sprite2D = get_node("/root/Game/GUI/Abilities/Ability2/StasisFieldIcon")
@onready var stasis_field_label: Label = get_node("/root/Game/GUI/Abilities/Ability2/Label")
@onready var gravity_well_icon: Sprite2D = get_node("/root/Game/GUI/Abilities/Ability3/GravityWellIcon")
@onready var gravity_well_label: Label = get_node("/root/Game/GUI/Abilities/Ability3/Label")
@onready var orbital_strike_icon: Sprite2D = get_node("/root/Game/GUI/Abilities/Ability4/OrbitalStrikeIcon")
@onready var orbital_strike_label: Label = get_node("/root/Game/GUI/Abilities/Ability4/Label")

func _ready():
	await game.game_ready
	cannon_data = GlobalScript.current_data.structures.cannon
	abilities_data = GlobalScript.current_data.abilities
	capacity_at_the_moment = cannon_data.capacity
	check_if_abilities_are_bought()
	rng.randomize()
	jamm_rng.randomize()
	update_rounds_left_label()
	
func _process(_delta):
	if !$Timers/ShootDelay.is_stopped():
		attack_readiness_bar.value = 100 * (last_shooting_delay - $Timers/ShootDelay.time_left) / last_shooting_delay
	update_abilities_cooldown_labels()
	if is_reloading: update_rounds_left_label()
	if !cannon_data.active: 
		set_process(false)
		attack_readiness_bar.value = 0.0
	if game.game_stopped: return
	$BarrelPointer.look_at(get_global_mouse_position())
	check_if_any_button_is_pressed()
	shooting_control += 1
	if overheat_progress >= 100 && shooting_control > 25:
		AudioBus.play("barrel_cooldown")
		create_overheat_particles()
		overheat_progress = 0
		shooting_control = 0
	
func barrel_pull_back() -> void:
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.play("reset_barrel")
	$AnimationPlayer.play("barrel_pull_back")

func shoot():
	can_shoot = false
	launch_projectile("cannon")
	overheat_progress += 1
	shooting_control = 0
	game.statistics_data.basic_attack.shots_fired += 1
	capacity_at_the_moment -= 1
	if capacity_at_the_moment == 0: reload() 
	else:
		last_shooting_delay = 1.0 / cannon_data.attack_speed
		$Timers/ShootDelay.start(last_shooting_delay)
		update_rounds_left_label()

func launch_plasma_barrage_projectiles():
	for i in range (1, abilities_data.plasma_barrage.projectiles + 1):
		launch_projectile("plasma_barrage")
		await game.create_delay_timer(0.05)

func launch_projectile(data_source: String) -> void:
	var data_dict: Dictionary = GlobalScript.get_data_source_dictionary(data_source, "current")
	var pos: Vector2 = $BarrelPointer/Marker2D.global_position
	var dest: Vector2 = get_global_mouse_position()
	var rot: float = $BarrelPointer.rotation
	var projectile_source: Area2D = self
	var new_projectile: Area2D = fabricated_scenes_manager.get_projectile_scene(data_source, data_dict, pos, dest, rot, projectile_source)
	barrel_pull_back()
	create_muzzle(data_dict)
	game.add_object(true, new_projectile)

func _on_shoot_delay_timeout():
	if !is_reloading: can_shoot = true

func reload():
	if capacity_at_the_moment == int(cannon_data.capacity):
		AudioBus.play("reload_finished")
		return
	game.change_cursor("reload")
	$Timers/ReloadCountdown.start(cannon_data.reload_time)
	is_reloading = true
	can_shoot = false
	# var force_cancel: bool = true
	# if is_instance_valid(reloading_bar): reloading_bar.cancel(force_cancel)
	reloading_bar = game.get_node("ProgressBarManager").create_progress_bar("Reloading...", "orange", cannon_data.reload_time)

func reload_finished() -> void:
	game.change_cursor("default")
	AudioBus.play("reload_finished")
	is_reloading = false
	can_shoot = true
	capacity_at_the_moment = int(cannon_data.capacity)
	update_rounds_left_label()

func create_muzzle(data_dict: Dictionary):
	var new_muzzle_flash: AnimatedSprite2D = resource_loader.get_resource("muzzle_flash").instantiate()
	var new_muzzle_flash_particles: GPUParticles2D = resource_loader.get_resource("muzzle_flash_particles").instantiate()
	new_muzzle_flash_particles.modulate = GlobalScript.get_composition_color(data_dict)
	for scene in [new_muzzle_flash, new_muzzle_flash_particles]:
		scene.add_to_group("vfx")
		scene.position = $BarrelPointer/Marker2D.global_position
		scene.rotation = $BarrelPointer.rotation + PI / 2
		game.add_object(true, scene)

func create_overheat_particles():
	var new_overheat_particles = OVERHEAT_PARTICLES_SCENE.instantiate()
	new_overheat_particles.position = $BarrelPointer/Marker2D.global_position
	new_overheat_particles.follow_parent = true
	new_overheat_particles.parent = $BarrelPointer/Marker2D
	get_parent().call_deferred("add_child", new_overheat_particles)

func _on_jam_timer_timeout():
	if trigger_jamm_stage > 0 || is_reloading: return
	if jamm_rng.randi_range(1, 1000) <= jamm_chance * 10:
		trigger_jamm_stage = 2
		unjamm_chance = rng.randi_range(15, 25)

func unjamm():
	if rng.randi_range(1, 100) < unjamm_chance && trigger_jamm_stage < 2:
		trigger_jamm_stage = 0
		if !GlobalScript.current_data.game.muted: AudioBus.play("reload_finished")
	else:
		if trigger_jamm_stage == 2: trigger_jamm_stage = 1
		AudioBus.play("trigger_jam")
		game.display_event_message("Trigger jammed!", 1, "nosound", 0, "red", "normal", "none", 0)
		unjamm_chance += 20

func _on_area_2d_mouse_entered() -> void:
	create_tooltip()

func create_tooltip() -> void:
	var new_tooltip = TOOLTIP_SCENE.instantiate()
	new_tooltip.type = "cannon"
	new_tooltip.set_script(preload("res://tooltip_ingame.gd"))
	get_tree().root.add_child(new_tooltip)

func update_rounds_left_label() -> void:
	var rounds_left_label: Label = game.get_node("GUI/RoundsLeftCount")
	var current_rounds_number: int
	var actual_capacity_percent: float
	
	if is_reloading: 
		actual_capacity_percent = (cannon_data.reload_time - $Timers/ReloadCountdown.time_left) / cannon_data.reload_time
		current_rounds_number = actual_capacity_percent * cannon_data.capacity
	else: 
		actual_capacity_percent = capacity_at_the_moment * 1.0 / cannon_data.capacity * 1.0
		current_rounds_number = capacity_at_the_moment
		
	rounds_left_label.text = str(current_rounds_number)
	if actual_capacity_percent > 0.66:
		rounds_left_label.modulate = Color (0.3, 1, 0.3, 1)
	elif actual_capacity_percent > 0.33:
		rounds_left_label.modulate = Color (0.8, 0.7, 0, 1)
	else:
		rounds_left_label.modulate = Color (1, 0.3, 0.3, 1)

func check_if_any_button_is_pressed() -> void:
	if (Input.is_action_just_pressed(&"reload") or capacity_at_the_moment == 0) and !is_reloading:
		reload()
	elif Input.is_action_just_pressed(&"fire") && trigger_jamm_stage > 0: unjamm()
	elif Input.is_action_pressed(&"fire"):
		if can_shoot && capacity_at_the_moment > 0:
			if trigger_jamm_stage == 0: shoot()
			else: if trigger_jamm_stage == 2: unjamm()
	elif Input.is_action_just_pressed(&"skill1"):
		if (abilities_data.plasma_barrage.bought and $Timers/PlasmaBarrageCooldown.is_stopped()) or (GlobalScript.settings.debug.enabled && GlobalScript.settings.debug.all_cds_disabled):
			$Timers/PlasmaBarrageCooldown.start(abilities_data.plasma_barrage.cooldown)
			if ability_1_icon_tween != null: ability_1_icon_tween.kill()
			plasma_barrage_icon.modulate = Color(0.3, 0.3, 0.3, 1)
			launch_plasma_barrage_projectiles()
		else: return
	elif Input.is_action_just_pressed(&"skill2"):
		if (abilities_data.stasis_field.bought and $Timers/StasisFieldCooldown.is_stopped()) or (GlobalScript.settings.debug.enabled && GlobalScript.settings.debug.all_cds_disabled):
			$Timers/StasisFieldCooldown.start(abilities_data.stasis_field.cooldown)
			if ability_2_icon_tween != null: ability_2_icon_tween.kill()
			stasis_field_icon.modulate = Color(0.3, 0.3, 0.3, 1)
			enable_stasis_field()
		else: return
	elif Input.is_action_just_pressed(&"skill3"):
		if (abilities_data.gravity_well.bought and $Timers/GravityWellCooldown.is_stopped()) or (GlobalScript.settings.debug.enabled && GlobalScript.settings.debug.all_cds_disabled):
			$Timers/GravityWellCooldown.start(abilities_data.gravity_well.cooldown)
			if ability_3_icon_tween != null: ability_3_icon_tween.kill()
			gravity_well_icon.modulate = Color(0.3, 0.3, 0.3, 1)
			launch_projectile("gravity_well")
		else: return
	elif Input.is_action_just_pressed(&"skill4"):
		if (abilities_data.orbital_strike.bought and $Timers/OrbitalStrikeCooldown.is_stopped()) or (GlobalScript.settings.debug.enabled && GlobalScript.settings.debug.all_cds_disabled):
			$Timers/OrbitalStrikeCooldown.start(abilities_data.orbital_strike.cooldown)
			if ability_4_icon_tween != null: ability_4_icon_tween.kill()
			orbital_strike_icon.modulate = Color(0.3, 0.3, 0.3, 1)
			launch_projectile("orbital_strike")
		else: return

func _on_plasma_barrage_cooldown_timeout() -> void:
	plasma_barrage_label.text = "Q"
	plasma_barrage_icon.modulate = Color(10, 10, 10, 1)
	if !game.game_ended:
		game.display_event_message("Plasma Barrage is ready to use", 2, "none", 0, "white", "normal", "none", 0)
		AudioBus.play("ability_ready")
	ability_1_icon_tween = create_tween()
	ability_1_icon_tween.tween_property(plasma_barrage_icon, "modulate", Color(1, 1, 1, 1), 0.4)
	
func _on_stasis_field_cooldown_timeout() -> void:
	stasis_field_label.text = "W"
	stasis_field_icon.modulate = Color(10, 10, 10, 1)
	if !game.game_ended:
		game.display_event_message("Stasis Field is ready to use", 2, "none", 0, "white", "normal", "none", 0)
		AudioBus.play("ability_ready")
	ability_2_icon_tween = create_tween()
	ability_2_icon_tween.tween_property(stasis_field_icon, "modulate", Color(1, 1, 1, 1), 0.4)

func _on_gravity_well_cooldown_timeout() -> void:
	gravity_well_label.text = "E"
	gravity_well_icon.modulate = Color(10, 10, 10, 1)
	if !game.game_ended:
		game.display_event_message("Gravity Well is ready to use", 2, "none", 0, "white", "normal", "none", 0)
		AudioBus.play("ability_ready")
	ability_3_icon_tween = create_tween()
	ability_3_icon_tween.tween_property(gravity_well_icon, "modulate", Color(1, 1, 1, 1), 0.4)

func _on_orbital_strike_cooldown_timeout() -> void:
	orbital_strike_label.text = "R"
	orbital_strike_icon.modulate = Color(10, 10, 10, 1)
	if !game.game_ended:
		game.display_event_message("Orbital Strike is ready to use", 2, "none", 0, "white", "normal", "none", 0)
		AudioBus.play("ability_ready")
	ability_4_icon_tween = create_tween()
	ability_4_icon_tween.tween_property(orbital_strike_icon, "modulate", Color(1, 1, 1, 1), 0.4)

func enable_stasis_field():
	progress_bar_manager.create_progress_bar("Stasis Field", "white", abilities_data.stasis_field.duration)
	$Timers/StasisFieldDuration.start(abilities_data.stasis_field.duration)
	stasis_field_particles.emitting = true
	abilities_data.stasis_field.enabled = true

func _on_stasis_field_duration_timeout() -> void:
	stasis_field_particles.emitting = false
	abilities_data.stasis_field.enabled = false

func update_abilities_cooldown_labels() -> void:
	if !$Timers/PlasmaBarrageCooldown.is_stopped(): plasma_barrage_label.text = str(int($Timers/PlasmaBarrageCooldown.time_left))
	if !$Timers/StasisFieldCooldown.is_stopped(): stasis_field_label.text = str(int($Timers/StasisFieldCooldown.time_left))
	if !$Timers/GravityWellCooldown.is_stopped(): gravity_well_label.text = str(int($Timers/GravityWellCooldown.time_left))
	if !$Timers/OrbitalStrikeCooldown.is_stopped(): orbital_strike_label.text = str(int($Timers/OrbitalStrikeCooldown.time_left))

func check_if_abilities_are_bought() -> void:
	if game.plasma_barrage_upgrades.size() > 0 and game.plasma_barrage_upgrades[0] == true:
		abilities_data.plasma_barrage.bought = true
		plasma_barrage_icon.show()
	if game.stasis_field_upgrades.size() > 0 and game.stasis_field_upgrades[0] == true:
		abilities_data.stasis_field.bought = true
		stasis_field_icon.show()
	if game.gravity_well_upgrades.size() > 0 and game.gravity_well_upgrades[0] == true:
		abilities_data.gravity_well.bought = true
		gravity_well_icon.show()
	if game.orbital_strike_upgrades.size() > 0 and game.orbital_strike_upgrades[0] == true:
		abilities_data.orbital_strike.bought = true
		orbital_strike_icon.show()

func take_damage(damage: float, _attacker: Area2D) -> void:
	game.damage_structure(self, damage)
