extends Node2D
var point_a
var point_b
var color = Color()
var width: float
var target_node = null


func _process(_delta: float) -> void:
	pass

func _ready():
	queue_redraw()	
	
func _draw():
	draw_line(point_a, point_b, color, width, true)
