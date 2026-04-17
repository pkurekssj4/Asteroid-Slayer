extends Area2D
var source: Area2D = null

func _ready() -> void:
	source = get_parent()
	
func take_damage(damage: float, attacker: Area2D) -> void:
	source.take_damage(damage, attacker)
