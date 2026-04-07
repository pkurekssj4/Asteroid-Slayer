extends Area2D
var type: String
var rise_and_decay_time: Array = []
var collision_parameters: Dictionary = {}
var duration: float
var is_decaying: bool = false
var current_scale: Vector2 = Vector2(0.01, 0.01)
var resource_credits: int = 0
var explosion_step: float
var source: Area2D = null

@onready var object_events_hub: Node = get_node("/root/Game/ObjectEventsHub")
@onready var game: Node2D = get_node("/root/Game")

func _ready():
	scale = current_scale

func _process(delta):
	# delta = odeglosc czasowa do nastepnej klatki aby sekunda w grze zawsze byla taka sama niezaleznie od FPS
	# przy 60 fps  delta = 0.0166... / przy 1 fps delta = 1 
	# explosion_duration = czas eksplozji ze skali 1 na 0 lub 0 na 1, więc żeby cała eksplozja faktycznie trwała przez tą wartość to explosion_step dzieli ją na 2 (przyśpiesza o 100%)
	if is_decaying:
		explosion_step = delta / (rise_and_decay_time[1])
		current_scale -= Vector2(explosion_step, explosion_step)
		if current_scale.x <= 0.01: game.add_new_object(false, self)
	else:
		explosion_step = delta / (rise_and_decay_time[0])
		current_scale += Vector2(explosion_step, explosion_step)
		if current_scale.x >= 1:
			if rise_and_decay_time[1] != 0.0:
				is_decaying = true
			else: 
				set_process(false)
				await_effect_duration_and_fade_off()
	scale = current_scale

func _on_area_entered(area: Area2D) -> void:
	object_events_hub.resolve_collision(true, self, area)

func _on_area_exited(area: Area2D) -> void:
	object_events_hub.resolve_collision(false, self, area)

func await_effect_duration_and_fade_off() -> void:
	var new_timer: Timer = Timer.new()
	new_timer.one_shot = true
	add_child(new_timer)
	new_timer.start(duration)
	await new_timer.timeout
	var new_tween: Tween = create_tween()
	var target_modulation: Color = Color(modulate.r, modulate.g, modulate.b, 0.0)
	var fading_off_duration: float = 0.2
	new_tween.tween_property(self, "modulate", target_modulation, fading_off_duration)
	new_tween.set_trans(Tween.TRANS_LINEAR)
	new_tween.set_ease(Tween.EASE_OUT)
	new_timer.start(fading_off_duration)
	await new_timer.timeout
	queue_free()
