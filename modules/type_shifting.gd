extends Node
var current_tween: Tween = null
var tweens: Array = []
var data_dict: Dictionary
var parent: Area2D = null
var current_key: int = 0
var types_to_shift_through: Array[String]
var shift_duration: float
var last_shift_time: float = 0.0
var alpha_channel: float
@onready var game = get_node("/root/Game")
@onready var audio_bus = get_node("/root/Game/AudioBus")

func _ready() -> void:
	parent = get_parent()
	data_dict = GlobalScript.current_data.asteroids
	alpha_channel = data_dict.chromatic_asteroid.explosion.alpha_channel
	for type in data_dict:
		if data_dict[type].has("spawn") and type != "chromatic_asteroid": types_to_shift_through.append(type)
	types_to_shift_through.shuffle()
	parent.explosion_scene.collision_parameters.transform_asteroids_to_parent_type = types_to_shift_through[current_key]
	last_shift_time = shift_duration
	parent["audio_visual_effects"]["visuals_when_launched"][1]["scene"].modulate = data_dict[types_to_shift_through[current_key]]["composition_color"]
	
func _process(_delta: float) -> void:
	if Time.get_ticks_msec() / 1000.0 - last_shift_time >= shift_duration:
		parent.explosion_scene.collision_parameters.transform_asteroids_to_parent_type = types_to_shift_through[current_key]
		var comp_color: Color = data_dict[types_to_shift_through[current_key]]["composition_color"]
		parent.explosion_scene.modulate = comp_color
		parent.explosion_scene.modulate.a = alpha_channel
		current_key += 1
		if current_key >= types_to_shift_through.size(): current_key = 0
		last_shift_time = Time.get_ticks_msec() / 1000.0
		if current_tween != null: current_tween.kill()
		current_tween = create_tween()
		current_tween.set_trans(Tween.TRANS_EXPO)
		current_tween.set_ease(Tween.EASE_IN)
		current_tween.tween_property(parent["audio_visual_effects"]["visuals_when_launched"][1]["scene"], "modulate", comp_color, shift_duration)
