extends Node
const PROGRESS_BAR = preload('res://progress_bar.tscn')
var progress_bar_y_offset_from_center: int = 80
var distance_between_bars: int = 30
var progress_bars: Array[Array]
var init_position: Vector2

func _ready() -> void:
	init_position = (get_viewport().size / 2)
	init_position.y += progress_bar_y_offset_from_center

func create_progress_bar(destination: String, color: String, time_sec: float):
	var new_progress_bar: ProgressBar = PROGRESS_BAR.instantiate()
	new_progress_bar.duration = time_sec
	new_progress_bar.time_left = time_sec
	new_progress_bar.destination = destination
	get_parent().add_child(new_progress_bar)
	var modulation: Color
	if color == "orange": modulation = Color(1, 0.7, 0)
	elif color == "red": modulation = Color(1, 0.2, 0.2)
	elif color == "fuchsia": modulation = Color(1, 0, 1, 1) 
	elif color == "blue": modulation = Color(0.1, 0.4, 1)
	elif color == "white": modulation = Color(1, 1 ,1)
	elif color == "violet": modulation = Color(0.6, 0.5, 1.0)
	new_progress_bar.self_modulate = modulation
	var new_array: Array = [new_progress_bar, time_sec]
	new_progress_bar.parent = new_array
	progress_bars.append(new_array)
	sort_progress_bars()
	return new_progress_bar

func sort_progress_bars() -> void:
	for array in progress_bars: array[1] = array[0].time_left
	progress_bars.sort_custom(func(a, b): return a[1] > b[1])
	var bar_slot: int = 0
	for array in progress_bars:
		var distance_y_offset: int = distance_between_bars * bar_slot
		array[0].global_position = Vector2(init_position.x - array[0].size.x / 2, init_position.y + distance_y_offset)
		bar_slot += 1
		
func erase_array(slot: Array) -> void:
	for case in progress_bars:
		if case == slot: progress_bars.erase(case)
