extends Control

var selected_button = null
var new_game: bool = false
var game_difficulty: String = ""
var save_slot: int
var load_case = false
var load_focus = 0
var saves_available
var time = 0.0 # movement fraktali

func _ready():
	#get_tree().root.size = Vector2(1024, 768)
	# var win := get_tree().root
	# win.content_scale_size = Vector2i(1024, 768)
	#get_tree().root.content_scale_size = Vector2i(1024, 768)
	$MainMenuContainer.hide()
	get_window().grab_focus()
	$BackgroundMusic.play()
	for child in get_children(): if child.get_name().contains("Container"): child.position = (get_viewport_rect().size / 2) - (child.size / 2)
	load_main_menu()
	$MainMenuContainer.show()

func _process(delta):
	time += delta
	get_node("Fractals").material.set_shader_parameter("u_time", time)
	
func load_main_menu() -> void:
	load_case = true
	load_save_slots()
	$MainMenuContainer/NewGameButton.modulate = Color (0.3, 0.3, 0.3, 1)
	$MainMenuContainer/LoadGameButton.modulate = Color (0.3, 0.3, 0.3, 1)
	$MainMenuContainer/OptionsButton.modulate = Color (0.3, 0.3, 0.3, 1)
	$MainMenuContainer/ExitButton.modulate = Color (0.3, 0.3, 0.3, 1)
	if saves_available == 0: 
		$MainMenuContainer/LoadGameButton.hide()
		selected_button = $MainMenuContainer/NewGameButton
		$MainMenuContainer/NewGameButton.grab_focus()
	else:
		selected_button = $MainMenuContainer/LoadGameButton
		$MainMenuContainer/LoadGameButton.grab_focus()
	
func reset_modulation() -> void:
	selected_button.modulate = Color(0.3, 0.3, 0.3, 1)
		
func load_save_slots() -> void:
	saves_available = 3
	load_focus = 0
	for i in range (1, 4):
		var slot = get_node("SaveSlotsContainer/SaveSlot%s" % i)
		slot.modulate = Color (0.3, 0.3, 0.3, 1)
		GlobalScript.initial_config.save_slot = i
		var save_path: String = GlobalScript.get_save_path("game")
		if FileAccess.file_exists(save_path):
			if load_focus == 0: load_focus = i
			var file = FileAccess.open(save_path, FileAccess.READ)
			var current_data: Dictionary = file.get_var()
			file.close()
			slot.text = "Creation date: " + current_data.game.save_creation_date + "\nLast save date: " + current_data.game.last_save_date + "\nDifficulty: " + current_data.game.difficulty + "\nDay: " + str(current_data.game.day) + "\nResource credits: " + str(current_data.resources.credits) 
		else:
			saves_available -= 1
			slot.text = "Empty slot"
	$SaveSlotsContainer/BackFromSaveSlotsButton.modulate = Color (0.3, 0.3, 0.3, 1)
	
func _on_new_game_button_mouse_entered() -> void:
	$MainMenuContainer/NewGameButton.grab_focus()
	
func _on_new_game_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $MainMenuContainer/NewGameButton
	$HighlightButtonAnimation.play("new")
	
func _on_new_game_button_pressed() -> void:
	load_case = false
	reset_modulation()
	selected_button = $SaveSlotsContainer/SaveSlot1
	$SaveSlotsContainer/SaveSlot1.grab_focus()
	reset_save_slots()
	$SaveSlotsContainer.show()
	$MainMenuContainer.hide()
	
func _on_load_game_button_mouse_entered() -> void:
	$MainMenuContainer/LoadGameButton.grab_focus()
	
func _on_load_game_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $MainMenuContainer/LoadGameButton
	$HighlightButtonAnimation.play("load")

func _on_load_game_button_pressed() -> void:
	load_case = true
	$MainMenuContainer.hide()
	for i in range (1, 4):
		var slot = get_node("SaveSlotsContainer/SaveSlot%s" % i)
		if load_focus == i: slot.grab_focus()
		if slot.text == "Empty slot": slot.hide()
	$SaveSlotsContainer.show()

func _on_options_button_mouse_entered() -> void:
	$MainMenuContainer/OptionsButton.grab_focus()
	
func _on_options_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $MainMenuContainer/OptionsButton
	$HighlightButtonAnimation.play("options")
	
func _on_exit_button_mouse_entered() -> void:
	$MainMenuContainer/ExitButton.grab_focus()

func _on_exit_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $MainMenuContainer/ExitButton
	$HighlightButtonAnimation.play("exit")

func _on_exit_button_pressed():
	get_tree().quit()
	
func _on_save_slot_1_mouse_entered() -> void:
	$SaveSlotsContainer/SaveSlot1.grab_focus()

func _on_save_slot_1_focus_entered() -> void:
	reset_modulation()
	selected_button = $SaveSlotsContainer/SaveSlot1
	$HighlightButtonAnimation.play("slot1")
	
func _on_save_slot_1_pressed() -> void:
	save_slot = 1
	var slot = get_node("SaveSlotsContainer/SaveSlot1")
	$SaveSlotsContainer.hide()
	if slot.text != "Empty slot" && !load_case:
		display_overwrite_save_menu()
	else:
		if !load_case: 
			$SaveSlotsContainer.hide()
			$DifficultyContainer/EasyButton.grab_focus()
			$DifficultyContainer.show()
			new_game = true
		else:
			launch_game()
		
func _on_save_slot_2_mouse_entered() -> void:
	$SaveSlotsContainer/SaveSlot2.grab_focus()

func _on_save_slot_2_focus_entered() -> void:
	reset_modulation()
	selected_button = $SaveSlotsContainer/SaveSlot2
	$HighlightButtonAnimation.play("slot2")
	
func _on_save_slot_2_pressed() -> void:
	save_slot = 2
	var slot = get_node("SaveSlotsContainer/SaveSlot2")
	$SaveSlotsContainer.hide()
	if slot.text != "Empty slot" && !load_case:
		display_overwrite_save_menu()
	else:
		if !load_case: 
			$SaveSlotsContainer.hide()
			$DifficultyContainer/EasyButton.grab_focus()
			$DifficultyContainer.show()
			new_game = true
		else:
			launch_game()
	
func _on_save_slot_3_mouse_entered() -> void:
	$SaveSlotsContainer/SaveSlot3.grab_focus()

func _on_save_slot_3_focus_entered() -> void:
	reset_modulation()
	selected_button = $SaveSlotsContainer/SaveSlot3
	$HighlightButtonAnimation.play("slot3")
	
func _on_save_slot_3_pressed() -> void:
	save_slot = 3
	var slot = get_node("SaveSlotsContainer/SaveSlot3")
	$SaveSlotsContainer.hide()
	if slot.text != "Empty slot" && !load_case:
		display_overwrite_save_menu()
	else:
		if !load_case: 
			$SaveSlotsContainer.hide()
			$DifficultyContainer/EasyButton.grab_focus()
			$DifficultyContainer.show()
			new_game = true
		else:
			launch_game()
		
func launch_game() -> void:
	$BackgroundMusic.stop()
	$LaunchGameSound.play()
	$FadeOffSolid.show()
	$FadeOffAnimation.play("fade_off")
	await get_tree().create_timer(2.0).timeout
	if new_game: 
		GlobalScript.initial_config.new_game = true
		GlobalScript.initial_config.game_difficulty = game_difficulty
	GlobalScript.initial_config.save_slot = save_slot
	GlobalScript.load_scene("game")
	
func display_overwrite_save_menu() -> void:
	$OverwriteContainer/YesOrNoContainer/NoButton.modulate = Color (0.3, 0.3, 0.3, 1)
	$OverwriteContainer/YesOrNoContainer/YesButton.modulate = Color (0.3, 0.3, 0.3, 1)
	reset_modulation()
	selected_button = $OverwriteContainer/YesOrNoContainer/NoButton
	$OverwriteContainer/YesOrNoContainer/NoButton.grab_focus()
	$OverwriteContainer.show()

func reset_save_slots() -> void:
	for i in range (1, 4):
		var slot = get_node("SaveSlotsContainer/SaveSlot%s" % i)
		slot.modulate = Color (0.3, 0.3, 0.3, 1)
		slot.show()
		
func _on_no_button_mouse_entered() -> void:
	$OverwriteContainer/YesOrNoContainer/NoButton.grab_focus()
	
func _on_no_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $OverwriteContainer/YesOrNoContainer/NoButton
	$HighlightButtonAnimation.play("no")
	
func _on_no_button_pressed() -> void:
	$OverwriteContainer.hide()
	reset_modulation()
	reset_save_slots()
	selected_button = $SaveSlotsContainer/SaveSlot1
	$SaveSlotsContainer/SaveSlot1.grab_focus()
	$SaveSlotsContainer.show()

func _on_yes_button_mouse_entered() -> void:
	$OverwriteContainer/YesOrNoContainer/YesButton.grab_focus()
	
func _on_yes_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $OverwriteContainer/YesOrNoContainer/YesButton
	$HighlightButtonAnimation.play("yes")

func _on_yes_button_pressed() -> void:
	$SaveSlotsContainer.hide()
	$OverwriteContainer.hide()
	$DifficultyContainer/EasyButton.grab_focus()
	$DifficultyContainer.show()

func _on_back_from_save_slots_button_mouse_entered() -> void:
	$SaveSlotsContainer/BackFromSaveSlotsButton.grab_focus()

func _on_back_from_save_slots_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $SaveSlotsContainer/BackFromSaveSlotsButton
	$HighlightButtonAnimation.play("back_from_save_slots")
	
func _on_back_from_save_slots_button_pressed() -> void:
	$SaveSlotsContainer.hide()
	$MainMenuContainer.show()
	load_main_menu()

func _on_easy_button_mouse_entered() -> void:
	$DifficultyContainer/EasyButton.grab_focus()

func _on_easy_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $DifficultyContainer/EasyButton
	$HighlightButtonAnimation.play("easy")

func _on_easy_button_pressed() -> void:
	$DifficultyContainer.hide()
	game_difficulty = "easy"
	new_game = true
	launch_game()

func _on_medium_button_mouse_entered() -> void:
	$DifficultyContainer/MediumButton.grab_focus()

func _on_medium_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $DifficultyContainer/MediumButton
	$HighlightButtonAnimation.play("medium")
	
func _on_medium_button_pressed() -> void:
	$DifficultyContainer.hide()
	game_difficulty = "medium"
	new_game = true
	launch_game()
	
func _on_hard_button_mouse_entered() -> void:
	$DifficultyContainer/HardButton.grab_focus()
	
func _on_hard_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $DifficultyContainer/HardButton
	$HighlightButtonAnimation.play("hard")

func _on_hard_button_pressed() -> void:
	$DifficultyContainer.hide()
	game_difficulty = "hard"
	new_game = true
	launch_game()

func _on_hardcore_button_mouse_entered() -> void:
	$DifficultyContainer/HardcoreButton.grab_focus()
	
func _on_hardcore_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $DifficultyContainer/HardcoreButton
	$HighlightButtonAnimation.play("hardcore")

func _on_hardcore_button_pressed() -> void:
	$DifficultyContainer.hide()
	game_difficulty = "hardcore"
	new_game = true
	launch_game()
	
func _on_back_from_difficulty_button_mouse_entered() -> void:
	$DifficultyContainer/BackFromDifficultyButton.grab_focus()
	
func _on_back_from_difficulty_button_focus_entered() -> void:
	reset_modulation()
	selected_button = $DifficultyContainer/BackFromDifficultyButton
	$HighlightButtonAnimation.play("back_from_difficulty")

func _on_back_from_difficulty_button_pressed() -> void:
	$DifficultyContainer.hide()
	$SaveSlotsContainer/SaveSlot1.grab_focus()
	$SaveSlotsContainer.show()
