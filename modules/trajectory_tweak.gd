extends Node

var trajectory_tweak_direction: int = 0
var trajectory_tweak_phase: int = 0
var parent: Area2D = null

func _ready() -> void:
	parent = get_parent()
	
func _process(delta: float) -> void:
	if trajectory_tweak_phase == 0: trajectory_tweak_direction = randi_range(-1, 1)
	var variation: float = randf_range(60.0, 100.0) * trajectory_tweak_direction
	parent.destination.x += variation * delta
	parent.position.x += variation * delta
	trajectory_tweak_phase += 1
	if trajectory_tweak_phase == 15: trajectory_tweak_phase = 0
