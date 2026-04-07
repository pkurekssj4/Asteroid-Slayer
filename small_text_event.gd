extends RichTextLabel
var pixels_move_per_second: int
var duration_time: float
var alpha_channel: float = 1.0
var fading_out_duration: float
var fading_out: bool = false

func _process(delta: float) -> void:
	var step: float = pixels_move_per_second * delta
	position.y -= step
	if fading_out:
		alpha_channel -= delta / fading_out_duration
		if alpha_channel <= 0.0: queue_free()
		modulate.a = alpha_channel
	else:
		duration_time -= delta
		if duration_time <= 0: fading_out = true
