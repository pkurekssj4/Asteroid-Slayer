extends Node

var parent: Area2D = null
var number: int
var base_speed: int = 10
var speed_variation: Array[int] = [25, 70]

@onready var fabricated_scenes_manager = get_node("/root/Game/FabricatedScenesManager")
@onready var game = get_node ("/root/Game")

func _ready() -> void:
	parent = get_parent()
	await parent.ready_to_free
	for i in range (1, number + 1):
		var speed: float = (base_speed + randi_range(speed_variation[0], speed_variation[1]))
		var destination: Vector2
		for vector in ["x", "y"]:
			# randi range (-1, 1) moze wylosować 0, dlatego:
			var multiplier: int = randi_range(1, 2)
			if multiplier == 2: multiplier = -1
			destination[vector] = parent.position[vector] + ((100 + randi_range(100, 300)) * multiplier)
		var new_asteroid: Area2D = fabricated_scenes_manager.get_asteroid_scene("split_up", 1, 0.1, speed, parent.position, destination, false, 0)
		new_asteroid.source = parent.source
		game.add_object(true, new_asteroid)
