extends Node
var visual_effect_script: Script
var maximum_number_of_targets: int
var last_discharge_time: float
var cooldown: float
var damage: float
var attack_range: float
var parent: Area2D = null
var timer: Timer
var ms_to_scan_sky: int = 50
var ms_left_to_scan_sky: int = 0

@onready var game = get_node("/root/Game")
@onready var vfx_scenes_container = get_node("/root/Game/ScenesContainer/VFX")
@onready var audio_bus = get_node("/root/Game/AudioBus")
@onready var resource_loader = get_node("/root/Game/ResourceLoader")

func _ready() -> void:
	visual_effect_script = resource_loader.get_scriptt("electric_discharge_visual_effect")
	timer = Timer.new()
	timer.name = "ElectricDischargeCooldown"
	timer.one_shot = true
	add_child(timer)
	parent = get_parent()
	ms_left_to_scan_sky = ms_to_scan_sky

func _process(delta: float) -> void:
	if parent.entered_screen and timer.is_stopped():
		ms_left_to_scan_sky -= int(delta * 1000)
		if ms_left_to_scan_sky <= 0:
			ms_left_to_scan_sky = ms_to_scan_sky
			scan_for_targets()
		
func scan_for_targets():
	var query_shape: CircleShape2D = CircleShape2D.new()
	query_shape.radius = attack_range
	
	var query_params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query_params.collide_with_areas = true
	query_params.collide_with_bodies = false
	query_params.shape = query_shape
	query_params.transform = Transform2D(0, parent.global_position)
		
	var space_state = parent.get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query_params, 32)
	var objects_attacked: int = 0
	for result in results:
		var target = result.collider
		if target != parent and target.is_in_group("asteroids") and target.entered_screen and !target.is_in_group("ghosts"):
			target.take_damage(damage, parent)
			trigger_visual_effect(target.global_position)
			timer.start(cooldown)
			objects_attacked += 1
			if objects_attacked == maximum_number_of_targets: break

func trigger_visual_effect(target_position: Vector2):
	var new_electric_discharge_visual_effect: Node2D = Node2D.new()
	new_electric_discharge_visual_effect.name = "NewElectricDischargeVisualEffect"
	new_electric_discharge_visual_effect.set_script(visual_effect_script)
	new_electric_discharge_visual_effect.target_position = target_position
	new_electric_discharge_visual_effect.init_position = parent.global_position
	new_electric_discharge_visual_effect.parent = parent
	new_electric_discharge_visual_effect.z_index = game.get_display_index("visual_effects")
	audio_bus.play_audio("electric_discharge")
	vfx_scenes_container.add_child(new_electric_discharge_visual_effect)
