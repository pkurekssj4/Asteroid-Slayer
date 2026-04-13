extends Node2D
var parent: Area2D = null
var offset = Vector2(0, 25)
var icon: CompressedTexture2D
func _ready() -> void:
	icon = preload("res://resource_icons/resource_credit.png")
	parent = get_parent()
	update_score(" 0")
	
func update_score(score: String) -> void:
	$Label.text = str(score)
	$Label.add_image(icon, 0, 13) # 0 = image ID (dowolna liczba), 16 = wysokość (dopasuj)
	
func _process(_delta) -> void:
	global_position = parent.global_position + offset
	global_rotation = 0
	global_scale = Vector2(1, 1)
	update_score(str(parent.resource_credits))

	
