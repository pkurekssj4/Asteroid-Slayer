extends Area2D
var audio_visual_effects: Dictionary = {}
var parent: Area2D = null
var rarity = 0
var source: Area2D = null
var durability_points: float
var destroy_threshold: float = 0.7
@onready var game: Node2D = get_node("/root/Game")
@onready var object_events_hub: Node = get_node("/root/Game/ObjectEventsHub")
@onready var fever: Node = get_node("/root/Game/Fever")

func _ready():
	durability_points = (scale.x - destroy_threshold) * 1000
	adjust_scale()
	source = parent
	
func _process(_delta):
	if is_instance_valid(parent): global_position = parent.global_position
	else: queue_free()

func take_damage(damage: float, attacker: Area2D):
	damage /= rarity
	fever.progress(damage, attacker, self)
	durability_points -= damage
	if durability_points <= 0.0:
		game.add_new_object(false, self)
		queue_free()
		return
	object_events_hub.execute_fx("damaged", self)
	adjust_scale()
	
func adjust_scale() -> void:
	var new_scale: float = destroy_threshold + (durability_points / 1000.0)
	scale = Vector2(new_scale, new_scale)
