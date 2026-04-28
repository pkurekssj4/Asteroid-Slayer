extends Node2D

var scene_to_load: String
var scene_load_status: int
var load_progress: Array = []
var scene_loaded: bool = false
var skew_decaying: bool = false
var skew_progressing_per_sec: float = 9.0

func _ready() -> void:
	ResourceLoader.load_threaded_request(scene_to_load)
	$UILayer/ProgressBar.value = 25
	#set_process(false)
	#await get_tree().create_timer(0.5).timeout
	#set_process(true)

func _process(delta: float) -> void:
	var skew_multiplier: int = 1
	if skew_decaying: skew_multiplier = -1
	$UILayer/Sprite2D.skew += (skew_progressing_per_sec * delta) * skew_multiplier
	if $UILayer/Sprite2D.skew == 89.9: skew_decaying = true
	elif $UILayer/Sprite2D.skew == -89.9: skew_decaying = false
	scene_load_status = ResourceLoader.load_threaded_get_status(scene_to_load, load_progress)
	if load_progress[0] > 0.25: $UILayer/ProgressBar.value = load_progress[0] * 100
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		change_scene()
		set_process(false)
	
func change_scene() -> void:
	var new_scene = ResourceLoader.load_threaded_get(scene_to_load)
	$UILayer/Sprite2D.queue_free()
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_packed(new_scene)
