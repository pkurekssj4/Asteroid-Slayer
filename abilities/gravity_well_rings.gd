extends GPUParticles2D
var parent: Area2D
var phase: float = 40.0
var phase_progress_per_sec: float = 0.3
var alpha_channel: float = 0.1

func _ready() -> void:
	emitting = true
	get_node("/root/Game/ProgressBarManager").create_progress_bar("Gravity Well", "violet", GlobalScript.current_data.abilities.gravity_well.explosion.duration)
	#var new_shader_material: ShaderMaterial = ShaderMaterial.new()
	#var new_shader: Shader = PreloadedResourcesHolder.get_shader("gravity_well_waving")
	#new_shader_material.shader = new_shader
	#material = new_shader_material
	#material.set_shader_parameter("alpha_channel", alpha_channel)
	var scale_factor: float = (GlobalScript.current_data.abilities.gravity_well.explosion.area_of_effect * 1.0) / (texture.get_width() * 1.0)
	process_material.scale = Vector2(scale_factor, scale_factor)
	
func _process(delta: float) -> void:
	if !is_instance_valid(parent) and emitting: end_emitting()
	#phase += phase_progress_per_sec * delta
	#material.set_shader_parameter("phase", phase)

func end_emitting() -> void:
	emitting = false
	var new_timer: Timer = Timer.new()
	add_child(new_timer)
	new_timer.one_shot = true
	new_timer.start(lifetime)
	await new_timer.timeout
	queue_free()
