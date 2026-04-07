extends Node2D
const RISE_DURATION = 0.3
const FADING_OFF_DURATION = 2.0
var radius: float = 0.0
var target_radius: float = 0.0
var initial_alpha_channel: float = 0.3
var alpha_channel: float = 0.0


func _ready() -> void:
	alpha_channel = initial_alpha_channel

func _process(delta):
	if radius <= target_radius:
		radius += target_radius / (RISE_DURATION / delta)
	elif alpha_channel > 0.0:
		alpha_channel -= initial_alpha_channel / (FADING_OFF_DURATION / delta)
	else:
		queue_free()
	queue_redraw()
		
func _draw():
	var color: Color = Color(0.9, 0.3, 1.0, alpha_channel)
	draw_circle(Vector2.ZERO, radius, color)
