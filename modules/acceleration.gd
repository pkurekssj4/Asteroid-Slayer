extends Node

var parent: Area2D = null
var speed_per_second: float

func _ready() -> void:
	parent = get_parent()

func _process(delta: float) -> void:
	if parent.speed_multiplier == 1.0 and parent.is_on_initial_trajectory: parent.base_speed += delta * speed_per_second
