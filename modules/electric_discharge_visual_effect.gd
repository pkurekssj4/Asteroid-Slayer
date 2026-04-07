extends Node2D
var init_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var lightning_line_core: Line2D
var lightning_line_core_width: float = 1
var lightning_line_border: Line2D
var lightning_line_border_width: float = 2
var decaying: bool = false
var alpha_decaying_per_sec: float = 1.5
var width_decaying_per_sec: float = 0.6
var alpha_channel: float = 1.0
var parent = null
@onready var game = get_node("/root/Game")

func _process(delta) -> void:
	if alpha_channel <= 0.0: queue_free()
	queue_redraw()
	alpha_channel -= alpha_decaying_per_sec * delta
	if lightning_line_core_width >= 0 + width_decaying_per_sec: lightning_line_core_width -= width_decaying_per_sec * delta
	if lightning_line_border_width >= 0 + width_decaying_per_sec: lightning_line_border_width -= width_decaying_per_sec * delta
	if is_instance_valid(parent): init_position = parent.global_position
		
func _draw() -> void:
	if lightning_line_border_width > 0: draw_line(init_position, target_position, Color(0.3, 0.4, 0.8, alpha_channel), lightning_line_border_width, true)
	if lightning_line_core_width > 0: draw_line(init_position, target_position, Color(0.3, 0.9, 1, alpha_channel), lightning_line_core_width, true)
