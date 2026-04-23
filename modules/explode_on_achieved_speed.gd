extends Node

var parent: Area2D = null
var trigger_speed: float
var speed_is_rising: bool
@onready var game = get_node("/root/Game")

func _ready() -> void:
	parent = get_parent()
	if parent.base_speed > trigger_speed: speed_is_rising = false
	else: speed_is_rising = true

func _process(_delta: float) -> void:
	if speed_is_rising:
		if parent.base_speed > trigger_speed:
			game.add_object(false, parent)
	else:
		if parent.base_speed < trigger_speed:
			game.add_object(false, parent)
