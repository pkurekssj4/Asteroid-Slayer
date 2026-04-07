extends CharacterBody2D
var text: String
var id: int
var maxDistance = 35
var offsetY = 20
var offsetX: int
var offsetXa = 0
var offsetXb = 270
@onready var game = get_node("/root/Game")

func _ready():
	print ("hello")
	hide()
	if $UpperLabel.get_total_character_count() > 225:
		$UpperLabel.add_theme_font_size_override("normal_font_size", 10)
	$Activator.start(0.1)
	game.last_tooltip_id += 1
	id = game.last_tooltip_id
	global_position.y += offsetY
	if get_global_mouse_position().x > 1550:
		offsetX = offsetXb
		global_position.x -= offsetX
	else: offsetX = offsetXa

func _process(_delta):
	if !game.activated: queue_free()
	if abs(get_global_mouse_position().x - global_position.x - offsetX) > maxDistance or abs(get_global_mouse_position().y - global_position.y + offsetY) > maxDistance or id != game.last_tooltip_id:
		queue_free()

func _on_activator_timeout() -> void:
	show()
