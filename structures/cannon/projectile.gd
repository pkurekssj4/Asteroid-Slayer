extends Area2D
var explosion_scene: Area2D = null
var audio_visual_effects: Dictionary = {}
var modules: Dictionary = {}
var collision_parameters: Dictionary = {}
var speed: float
var destination: Vector2
var source: Area2D = null
var type: String
var exploded: bool = false

@onready var game: Node2D = get_node("/root/Game")
@onready var audio_bus: Node = get_node("/root/Game/AudioBus")
@onready var object_events_hub: Node = get_node("/root/Game/ObjectEventsHub")

signal ready_to_process

func _ready() -> void:
	emit_signal("ready_to_process")

func _process(delta):
	# delta = odstep miedzy kazda klatka, przy 60 fps to 0.0166...
	# jesli fpsów jest mniej niż zakląda silnik (np 40) to wtedy delta podnosi się aby przykladowo pocisk z kazda klatka przemierzal wiecej
	# ale w rzeczywistosci tyle same jakby lecial na 60 fps
	# delte trzeba uwzgledniac przy wszystkim co ma sie wykonac w jakims okreslonym czasie, albo ma sie poruszać w okreslonej predkosci na sekunde
	print (str(global_position.y) + " / " + str(destination.y))
	position += transform.x * speed * delta
	if global_position.y <= destination.y:
	#if destination.y >= global_position.y:
		game.add_object(false, self)

func _on_visible_on_screen_notifier_2d_screen_exited():
	game.add_object(false, self)

func _on_area_entered(area: Area2D) -> void:
	if !exploded: object_events_hub.resolve_collision(true, self, area)
