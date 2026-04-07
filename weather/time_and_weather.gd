extends Node
const CLOUDS = [
	preload("res://weather/clouds/cloud1.tscn"),
	preload("res://weather/clouds/cloud2.tscn"),
	preload("res://weather/clouds/cloud3.tscn"),
	preload("res://weather/clouds/cloud4.tscn"),
	preload("res://weather/clouds/cloud5.tscn"),
	preload("res://weather/clouds/cloud6.tscn"),
]
const RAIN = preload("res://weather/rain.tscn")
var starting_month: int = 8
var starting_day: int = 17
var starting_hour: int = 20
var starting_minute: int = 13
var calendar: Dictionary = {
	8: {
		"literally": "August",
		"days": 31
	},
	9: {
		"literally": "September",
		"days": 30
	},
	10: {
		"literally": "October",
		"days": 31
	},
	11: {
		"literally": "November",
		"days": 30
	}
}
var wind: int
var cloud_spawn_interval: int = 1
var cloud_spawn_chance_thresholds: Array[int] = [1, 8]
var fractals_chance: int = 15
var rain_chance: int = 20
var fractals_activated: bool = false
var fractals_phase_step_per_sec: float = 0.5
var fractals_phase_max: float = 3000.0
var fractals_phase: float = 0.0
var fractals_phase_decaying: bool
var cloud_timer: Timer

@onready var game: Node2D = get_node("/root/Game")
@onready var cloud_scenes_container: Node = get_node("/root/Game/ScenesContainer/Clouds")
@onready var fractals: Sprite2D = get_node("/root/Game/Fractals")
@onready var stars: Sprite2D = get_node("/root/Game/Stars")

func _ready() -> void:
	await game.game_ready
	cloud_timer = Timer.new()
	cloud_timer.one_shot = true
	add_child(cloud_timer)
	cloud_timer.start(cloud_spawn_interval)

func _process(delta: float) -> void:
	if cloud_timer.is_stopped():
		cloud_timer.start(cloud_spawn_interval)
		if randi_range(1, 100) <= GlobalScript.current_data.game.cloud_spawn_chance: spawn_cloud(false)
		
	if fractals_activated:
		if fractals_phase == fractals_phase_max: fractals_phase_decaying = true
		elif fractals_phase == 0.0: fractals_phase_decaying = false
		var phase_multiplier: int = 1
		if fractals_phase_decaying: phase_multiplier = -1
		fractals_phase += (fractals_phase_step_per_sec * delta) * phase_multiplier
		fractals.material.set("shader_parameter/phase", fractals_phase)
	
func init() -> void:
	var sky_low: Sprite2D = game.get_node("SkyLow")
	var sky_high: Sprite2D = game.get_node("SkyHigh")
	sky_low.modulate = GlobalScript.current_data.game.low_sky_modulation
	sky_high.modulate = GlobalScript.current_data.game.high_sky_modulation
	
	if GlobalScript.current_data.game.fractals:
		fractals.visible = true
		fractals_activated = true
	else:
		fractals.queue_free()
		
	if is_night():
		stars.visible = true
		stars.global_position.y += randi_range(-100, 540)
	else:
		stars.queue_free()
		
	if GlobalScript.current_data.game.rain:
		var new_rain = RAIN.instantiate()
		add_child(new_rain)
		if !GlobalScript.current_data.game.muted: game.get_node("Sounds/Rain").play()
	else: if !GlobalScript.current_data.game.muted: game.get_node("Sounds/Ambient").play()
	
	wind = randi_range(1,2)
	if wind == 1: wind = randi_range(3,12)
	else: wind = randi_range(3,12) * -1
	for i in range (1 * GlobalScript.current_data.game.cloud_spawn_chance, 5 * GlobalScript.current_data.game.cloud_spawn_chance):
		spawn_cloud(true)

func set_config_for_next_day():
	set_game_time()
	set_game_date()
	set_sky_modulation()
	if randi_range(1, 100) <= fractals_chance: GlobalScript.current_data.game.fractals = true
	else: GlobalScript.current_data.game.fractals = false
	if randi_range(1, 100) <= rain_chance: GlobalScript.current_data.game.rain = true
	else: GlobalScript.current_data.game.rain = false
	GlobalScript.current_data.game.cloud_spawn_chance = randi_range(cloud_spawn_chance_thresholds[0], cloud_spawn_chance_thresholds[1])

func set_game_date():
	var days = GlobalScript.current_data.game.day
	var month = starting_month
	var month_day = starting_day
	while days > 1:
		days -= 1
		month_day += 1
		if month_day > calendar[month].days:
			month += 1
			month_day = 1
	GlobalScript.current_data.game.month_literally = calendar[month].literally
	GlobalScript.current_data.game.month_day = month_day

func set_game_time():
	var hour: int
	var minute: int
	
	if GlobalScript.current_data.game.day > 1:
		hour = GlobalScript.current_data.game.time[0]
		minute = GlobalScript.current_data.game.time[1]
		var minutes_to_add = randi_range(191, 856)
		while minutes_to_add > 0:
			minutes_to_add -= 1
			minute += 1
			if minute == 60:
				minute = 0
				hour += 1
				if hour == 24: hour = 0
	else:
		hour = starting_hour
		minute = starting_minute
	
	GlobalScript.current_data.game.time = [hour, minute]

func set_sky_modulation() -> void:
	var low_sky_modulation: Color
	var high_sky_modulation: Color
	
	if is_night():
		low_sky_modulation = Color(0.05, 0.05, 0.2, 1.1)
		high_sky_modulation = Color(0.05, 0.05, 0.2, 1)
	else:
		var red: float = randi_range(100, 250) / 1000.0
		var green: float = randi_range(200, 350) / 1000.0
		var blue: float = randi_range(200, 450) / 1000.0
		low_sky_modulation = Color(red, green, blue, 1.2)
		red = randi_range(50, 300) / 1000.0
		green = randi_range(150, 350) / 1000.0
		blue = randi_range(250, 500) / 1000.0
		high_sky_modulation = Color(red, green, blue, 1)
	
	GlobalScript.current_data.game.low_sky_modulation = low_sky_modulation
	GlobalScript.current_data.game.high_sky_modulation = high_sky_modulation
	
func is_night() -> bool:
	if GlobalScript.current_data.game.time[0] >= 20 || GlobalScript.current_data.game.time[0] <= 6: return true
	else: return false

func spawn_cloud(initial_spawn):
	var cloud_number = randi_range(1, 6)
	var cloud_to_instantiate = CLOUDS[cloud_number - 1]
	var cloud = cloud_to_instantiate.instantiate()
	var vector_x
	if initial_spawn: 
		vector_x = randi_range(-200,2300)
	else:
		if wind > 0:
			vector_x = -200
		else:
			vector_x = 2300
	var cloud_scale: float = randf_range(0.3, 2.1)
	cloud.scale = Vector2(cloud_scale, cloud_scale)
	cloud.position = Vector2(vector_x, randi_range(100,260))
	cloud.speed = wind
	cloud.z_index = game.get_display_index("clouds")
	cloud_scenes_container.call_deferred("add_child", cloud)
