extends Node2D
var parent: Area2D
var scale_vector: float = 0.01
var max_scale_vector: float = 1.0
var scale_vector_gain_per_second: float = 2.0
var fading_off: bool = false
var fading_off_per_second: float = 2.0
var fading_in_per_second: float = 4.0

func _ready() -> void:
	$Sprite2D.scale = Vector2(0, 0)

func _process(delta: float) -> void:
	if !is_instance_valid(parent):
		queue_free()
		return
	global_position = parent.global_position
	if fading_off:
		modulate.a -= fading_off_per_second * delta
		if modulate.a <= 0.0:
			fading_off = false
			scale_vector = 0.1
			$Sprite2D.scale = Vector2(scale_vector, scale_vector)
	else:
		if modulate.a < 1.0: modulate.a += fading_in_per_second * delta
		scale_vector += scale_vector_gain_per_second * delta
		if scale_vector >= max_scale_vector: fading_off = true
		$Sprite2D.scale = Vector2(scale_vector, scale_vector)
