extends Control

var game: Node2D
var red: float = 0.0
var green: float = 0.001
var green_decaying: bool = false
var blue: float = 0.2
var game_ended: bool = false
var selected_button: Button = null

func _ready() -> void:
	game = get_parent()
	await game.game_ready
	$Buttons/Restart.modulate = Color(0.3, 0.3, 0.3, 1)
	$Buttons/MainMenu.modulate = Color(0.3, 0.3, 0.3, 1)
	$Buttons/UpgradeConsole.modulate = Color(0.3, 0.3, 0.3, 1)
	$Buttons/Exit.modulate = Color(0.3, 0.3, 0.3, 1)
	$Particles.modulate = Color (0.2, 0.2, 2, 1)
	$Panel.modulate = Color (0.3, 0.3, 2, 1)
	selected_button = $Buttons/Restart
	if GlobalScript.current_data.game.day == 1 and GlobalScript.settings.debug.enabled: $Buttons/UpgradeConsole.hide()
	
func _process(_delta):
	if GlobalScript.auto_pause_when_lost_focus and !get_window().has_focus() and game.game_pausable: pause_game()
	if is_visible_in_tree(): advance_background_animation()
	
	if Input.is_action_just_pressed(&"pause") && !game_ended:
		$Buttons/Restart.grab_focus()
		selected_button = $Buttons/Restart
		if !get_tree().paused and game.game_pausable:
			pause_game()
			# if GlobalScript.current_data.asteroids.general.asteroids_alive > 0: pause_game()
		else:
			resume_game()
	
func pause_game():
	get_tree().paused = true
	show()
	
func resume_game():
	get_tree().paused = false
	hide()

func advance_background_animation() -> void:
	
	if green_decaying:
		green -= 0.0015
		if green < 0:
			$Particles.emitting = true
			green_decaying = false
	else: 
		green += 0.0015
		if green > 0.2:
			$Particles.emitting = false
			green_decaying = true
		
	$Background.modulate = Color(red, green, blue, 0.6)
		
func switch_to_game_over() -> void:
	game_ended = true
	$Buttons/Restart.grab_focus()
	selected_button = $Buttons/Restart
	$Label.text =  "Game over, you have lost too many structures!"
	$Particles.modulate = Color (2, 0.2, 0.2, 1)
	$Panel.modulate = Color (2, 0.2, 0.2, 1)
	blue = 0.0
	red = 0.2

func reset_modulation() -> void:
	selected_button.modulate = Color(0.3, 0.3, 0.3, 1)

# === RESTART ===
func _on_restart_mouse_entered() -> void:
	$Buttons/Restart.grab_focus()

func _on_restart_focus_entered() -> void:
	reset_modulation()
	selected_button = $Buttons/Restart
	$Buttons/HighlightButtonAnimation.play("restart")

func _on_restart_pressed() -> void:
	get_tree().paused = false
	if GlobalScript.initial_config.new_game: GlobalScript.initial_config.new_game = false
	GlobalScript.load_scene("game")

# === MAIN MENU ===
func _on_main_menu_mouse_entered() -> void:
	$Buttons/MainMenu.grab_focus()

func _on_main_menu_focus_entered() -> void:
	reset_modulation()
	selected_button = $Buttons/MainMenu
	$Buttons/HighlightButtonAnimation.play("main menu")

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	if GlobalScript.initial_config.new_game: GlobalScript.initial_config.new_game = false
	GlobalScript.load_scene("menu")

# === UPGRADE MENU ===
func _on_upgrade_console_mouse_entered() -> void:
	$Buttons/UpgradeConsole.grab_focus()

func _on_upgrade_console_focus_entered() -> void:
	reset_modulation()
	selected_button = $Buttons/UpgradeConsole
	$Buttons/HighlightButtonAnimation.play("upgrade menu")

func _on_upgrade_console_pressed() -> void:
	get_tree().paused = false
	GlobalScript.load_scene("console")

# === EXIT ===
func _on_exit_mouse_entered() -> void:
	$Buttons/Exit.grab_focus()
	
func _on_exit_focus_entered() -> void:
	reset_modulation()
	selected_button = $Buttons/Exit
	$Buttons/HighlightButtonAnimation.play("exit")

func _on_exit_pressed() -> void:
	get_tree().quit()
