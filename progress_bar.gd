extends ProgressBar
var duration: float
var time_left: float
var destination: String
var fade_time: float = 1
var parent: Array
@onready var game = get_node("/root/Game")
@onready var progress_bar_manager = get_node("/root/Game/ProgressBarManager")


func  _ready() -> void:
	$DurationTimer.start(duration)
	$Destination.text = destination
	update_time_left_label()
	
func update_time_left_label() -> void:
	$TimeLeft.text = str(snapped(time_left, 0.1)) + "s"
	
func _process(_delta: float) -> void:
	time_left = $DurationTimer.time_left
	value = time_left / duration * 100.0
	update_time_left_label()
	if value == 0:
		fade(0)
		set_process(false)

func fade(alpha_channel: float) -> void:
	var new_fade: Tween = create_tween()
	new_fade.tween_property(self, "modulate", Color(1, 1, 1, alpha_channel), fade_time)
	await game.create_delay_timer(fade_time)
	cancel(true)

func cancel(force: bool) -> void:
	if force: 
		progress_bar_manager.erase_array(parent) 
		queue_free()
	else:
		set_process(false)
		$DurationTimer.stop()
		fade(0)
