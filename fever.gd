extends Node
var current_damage: float = 0.0
var required_damage: float
var timer: Timer
var initial_shader_phase: float = 100.0
var shader_phase: float = 0.0
var shader_material: ShaderMaterial
var shader_phase_raise_per_second: float = 0.5
var current_damage_percent_decline_per_second: float = 1.0
@onready var fever_meter: TextureProgressBar = get_node("/root/Game/GUI/Fever/ProgressBar")
@onready var game: Node2D = get_node("/root/Game")
@onready var audio_bus: Node = get_node("/root/Game/AudioBus")
@onready var cannon: Node2D = get_node("/root/Game/Cannon")
@onready var reloading_timer: Timer = get_node("/root/Game/Cannon/Timers/ReloadCountdown")
@onready var resource_loader: Node = get_node("/root/Game/ResourceLoader")
@onready var progress_bar_manager: Node = get_node("/root/Game/ProgressBarManager")

func _process(delta: float) -> void:
	if GlobalScript.current_data.fever.enabled:
		shader_phase += shader_phase_raise_per_second * delta
		fever_meter.material.set_shader_parameter("phase", shader_phase)
	else:
		current_damage -= ((current_damage_percent_decline_per_second / 100.0) * required_damage) * delta
		progress(0.0)

func _ready() -> void:
	shader_material = ShaderMaterial.new()
	var new_shader: Shader = resource_loader.get_shader("fever_progress_bar")
	shader_material.shader = new_shader
	await game.game_ready
	required_damage = GlobalScript.current_data.fever.current_damage_requirement
	timer = Timer.new()
	timer.name = "Cooldown"
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "end_fever"))
	
func progress(damage: float) -> void:
	if GlobalScript.current_data.fever.enabled: return
	current_damage += damage
	if current_damage >= required_damage: start_fever()
	fever_meter.value = (current_damage / required_damage) * 100.0

func start_fever() -> void:
	current_damage = required_damage
	GlobalScript.current_data.fever.enabled = true
	timer.start(GlobalScript.current_data.fever.duration)
	audio_bus.play_audio("fever")
	game.display_event_message("Fever!", 2, "none", 0.0, "fuchsia", "big", "none", 0)
	GlobalScript.include_additive_stats(true, "fever")
	fever_meter.material = shader_material
	progress_bar_manager.create_progress_bar("Fever", "fuchsia", GlobalScript.current_data.fever.duration)
	if cannon.is_reloading:
		if reloading_timer.time_left <= GlobalScript.current_data.structures.cannon.additive_statistics.fever.reload_time:
			reloading_timer.stop()
			cannon.reload_finished()
			var forced: bool = false
			cannon.reloading_bar.cancel(forced)
		else:
			reloading_timer.start(GlobalScript.current_data.structures.cannon.additive_statistics.fever.reload_time)
			var progress_bar_timer: Timer = cannon.reloading_bar.get_node("DurationTimer")
			progress_bar_timer.start(progress_bar_timer.time_left - GlobalScript.current_data.structures.cannon.additive_statistics.fever.reload_time)
	
func end_fever() -> void:
	current_damage = 0.0
	fever_meter.value = 0.0
	fever_meter.material = null
	shader_phase = initial_shader_phase
	GlobalScript.current_data.fever.enabled = false
	GlobalScript.include_additive_stats(false, "fever")
