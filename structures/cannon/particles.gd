extends GPUParticles2D
var follow_parent: bool = false
var parent = null
var has_parent: bool = false

func _ready() -> void:
	if parent != null: has_parent = true
	emitting = true
	
func _process(_delta):
	if has_parent:
		if is_instance_valid(parent):
			if follow_parent: global_position = parent.global_position
		else:
			emitting = false
			if !one_shot: schedule_for_deleting()
			set_process(false)
	
func _on_finished():
	queue_free()
	
func schedule_for_deleting() -> void:
	var new_timer: Timer = Timer.new()
	new_timer.one_shot = true
	add_child(new_timer)
	new_timer.start(lifetime)
	await new_timer.timeout
	queue_free()
	
func _on_ready() -> void:
	pass # Replace with function body.
