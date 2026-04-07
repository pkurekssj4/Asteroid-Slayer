extends Node2D
var scale_factor_rise_per_sec = 2.0
var scale_factor_threshold_to_decline_scale_factor_rise: float = 0.1
var scale_factor_rise_decline_per_sec: float = 1.5
var fading_off_scale_threshold: float = 0.2
var fading_off_per_second: float = 0.95
var scale_factor: float = 0.0

func _ready() -> void:
	$Sprite2D.scale = Vector2(0, 0)

func _process(delta: float) -> void:
	if scale_factor >= scale_factor_threshold_to_decline_scale_factor_rise: scale_factor_rise_per_sec -= scale_factor_rise_decline_per_sec * delta
	scale_factor += scale_factor_rise_per_sec * delta
	if scale_factor >= fading_off_scale_threshold: modulate.a -= fading_off_per_second * delta
	if modulate.a <= 0.0: queue_free()
	$Sprite2D.scale = Vector2(scale_factor, scale_factor)
