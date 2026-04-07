extends Node

var parent: Area2D = null
var sprite_name_to_modulate: String
var sprite_to_modulate: Sprite2D

var initial_difference: float
var target_speed: float
var current_modulation: float = 10.0

func _ready() -> void:
	parent = get_parent()
	sprite_to_modulate = parent.get_node(sprite_name_to_modulate)
	initial_difference = parent.base_speed - target_speed
	
func _process(_delta: float) -> void:
	var modulation: float = 1 + ((parent.base_speed - target_speed) / initial_difference) * current_modulation
	sprite_to_modulate.modulate = Color(modulation, modulation, modulation)
	
