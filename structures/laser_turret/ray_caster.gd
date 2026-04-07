extends Node2D
var laser_turret: Area2D
var laser_head_marker: Marker2D
var ray_color: Color
var ray_width: float
var drawing: bool = false

func _process(_delta):
	match laser_turret.state:
		"idle":
			if drawing: 
				drawing = false
				queue_redraw()
			return
		"cooldown":
			ray_color = Color(0.7, 0.3, 0, 0.5)
			ray_width = 0.5
		"targeting":
			ray_color = Color(0.0, 0.3, 1, 0.5)
			ray_width = 0.5
		"attacking":
			ray_color = Color(1, 0, 0, 0.7)
			ray_width = 0.7
	drawing = true
	queue_redraw()
	
func _draw():
	if drawing:
		draw_line(laser_turret.ray_starting_point, laser_turret.ray_ending_point, ray_color, ray_width, true)
