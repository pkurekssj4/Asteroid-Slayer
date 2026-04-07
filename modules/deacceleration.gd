extends Node

var parent: Area2D = null
var speed_per_second: float

func _ready() -> void:
	parent = get_parent()
	
func _process(delta: float) -> void:
	parent.base_speed -= delta * speed_per_second
