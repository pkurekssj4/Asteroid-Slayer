extends Area2D
const TOOLTIP_SCENE = preload('res://tooltip_ingame.tscn')
var object_name: String
var function: String
var drop_chance: float = 0.0

func _on_mouse_entered() -> void:
	create_tooltip()
	
func create_tooltip() -> void:
	var new_tooltip = TOOLTIP_SCENE.instantiate()
	new_tooltip.type = "resource"
	new_tooltip.set_script(preload("res://tooltip_ingame.gd"))
	get_tree().root.add_child(new_tooltip)
	new_tooltip.object_name = object_name
	new_tooltip.function = function
	new_tooltip.drop_chance = drop_chance
