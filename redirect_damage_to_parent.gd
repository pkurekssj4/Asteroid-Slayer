extends Area2D

var parent: Area2D
var source: Area2D = null

func _ready() -> void:
	parent = get_parent()
	source = parent
	
func take_damage(damage: float, attacker: Area2D) -> void:
	parent.take_damage(damage, attacker)
