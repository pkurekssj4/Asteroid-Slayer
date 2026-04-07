extends Area2D
const TOOLTIP_SCENE = preload('res://upgrade_console/tooltip_upgrade_console.tscn')
const SPECIALISATIONS_SCENE = preload('res://upgrade_console/specialisations/specialisations.tscn')
var choosen = false
var console: Control
func _ready() -> void:
	console = get_parent()

func _process(_delta: float) -> void:
	pass
	
func _on_mouse_entered() -> void:
	if !get_parent().activated: return
	create_tooltip()
	
func create_tooltip() -> void:
	var new_tooltip = TOOLTIP_SCENE.instantiate()
	var upper_label = new_tooltip.get_node("UpperLabel")
	var lower_label = new_tooltip.get_node("LowerLabel")
	upper_label.text = "Click here to open specialisations panel."
	lower_label.text = "Specialisations are available since day: [color=orange]" + str(GlobalScript.specialisation_unlock_day) + "[/color]"
	new_tooltip.global_position = get_global_mouse_position()
	get_tree().root.add_child(new_tooltip)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#if upgrade_console.day < GlobalScript.specialisation_unlock_day || !upgrade_console.activated: return
	if !console.activated: return
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			$BlinkingAnimation.stop()
			var new_specialisation_panel = SPECIALISATIONS_SCENE.instantiate()
			console.activated = false
			new_specialisation_panel.player_specialisation = GlobalScript.current_data.game.player_specialisation
			new_specialisation_panel.upgrade_console = console
			new_specialisation_panel.z_index = 4
			get_parent().add_child(new_specialisation_panel)
			
