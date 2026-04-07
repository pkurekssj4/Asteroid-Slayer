extends ProgressBar
var delay_timer: Timer
var damage_taken_bar: ProgressBar
var damage_taken_delay: float = 2.0
var value_normalizing_per_frame: float = 1
# interfejs nie należy do świata gry dlatego per frame


func _ready() -> void:
	delay_timer = Timer.new()
	delay_timer.one_shot = true
	add_child(delay_timer)
	delay_timer.timeout.connect(_on_damage_taken_delay_timeout)

func _process(delta: float) -> void:
	if damage_taken_bar.value > value: damage_taken_bar.value -= value_normalizing_per_frame
	else: set_process(false)
	
func update_value(new_value: int, damage_taken: bool) -> void:
	value = new_value
	if damage_taken:
		set_process(false)
		if !delay_timer.is_stopped(): delay_timer.stop()
		delay_timer.start(damage_taken_delay)
	else:
		damage_taken_bar.value = new_value
	if value > 66: modulate = Color(0, 1, 0, 1)
	elif value > 33: modulate = Color(1, 0.5, 0, 1)
	else: modulate = Color(1, 0, 0, 1)

func _on_damage_taken_delay_timeout() -> void:
	set_process(true)
