extends RichTextLabel
var pixels_move_per_second: int
var duration_time: float
var alpha_channel: float = 1.0
var fading_out_duration: float
var fading_out: bool = false
var new_tween: Tween
var raise_scale_factor: float = 2.0
var scale_raise_time_sec: float = 0.25
var scale_return_time_sec: float = 0.15

func _ready() -> void:
	new_tween = create_tween()
	new_tween.tween_property(self, "scale", Vector2(raise_scale_factor, raise_scale_factor), scale_raise_time_sec)
	new_tween.tween_property(self, "scale", Vector2(1.0, 1.0), scale_return_time_sec)
	
func _process(delta: float) -> void:
	var step: float = pixels_move_per_second * delta
	position.y -= step
	if fading_out:
		alpha_channel -= delta / fading_out_duration
		if alpha_channel <= 0.0: 
			new_tween.kill()
			queue_free()
		modulate.a = alpha_channel
	else:
		duration_time -= delta
		if duration_time <= 0: fading_out = true
