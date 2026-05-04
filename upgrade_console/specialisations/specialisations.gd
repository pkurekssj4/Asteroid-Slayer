extends Control
var upgrade_console = null #set by upgrade_console.tscn
var current_specialisation = "none"
var player_specialisation = "none"
var actual_cost = 0
var specialisation_change_cost = 25000
var specialisation_change_in_progress = false


func _ready() -> void:
	global_position = get_viewport_rect().size / 2 - $MainPanel/Inside.size / 2
	update_your_specialisation_label()

func _process(_delta: float) -> void:
	if specialisation_change_in_progress:
		$SecondaryPanel/ChangingSpecialisationInside/ProgressBar.value += 0.1
		if $SecondaryPanel/ChangingSpecialisationInside/ProgressBar.value == 30: $SecondaryPanel/ChangingSpecialisationInside/Label.text = "Synchronizing cognitive matrice..."
		elif $SecondaryPanel/ChangingSpecialisationInside/ProgressBar.value == 55: $SecondaryPanel/ChangingSpecialisationInside/Label.text = "Reconfiguring specialization subnetworks..."
		if $SecondaryPanel/ChangingSpecialisationInside/ProgressBar.value == 100:
			specialisation_change_in_progress = false
			player_specialisation = current_specialisation
			GlobalScript.current_data.game.player_specialisation = player_specialisation
			AudioBus.play("new_specialisation_acquired")
			$SecondaryPanel/ChangingSpecialisationInside.hide()
			$SecondaryPanel/SpecialisationChangedInside.show()
			$SecondaryPanel/SpecialisationChangedInside/Label2.text = player_specialisation
			$SpecialisationChangedParticles.emitting = true
			await get_tree().create_timer(4).timeout
			$SpecialisationChangedParticles.emitting = false
			await get_tree().create_timer(6).timeout
			GlobalScript.add_additive_stats(false, "specialisation")
			GlobalScript.clear_and_set_new_specialisation_bonuses()
			GlobalScript.add_additive_stats(true, "specialisation")
			$SecondaryPanel/SpecialisationChangedInside/ContinueButton.show()
	else:
		if Input.is_action_just_pressed(&"back"):
			upgrade_console.activated = true
			queue_free()
			
func update_your_specialisation_label() -> void:
	$MainPanel/Inside/YourSpecialisationLabel.text = "Your current specialisation: " + player_specialisation

func change_specialisation() -> void:
	if current_specialisation == "pyrotechnist": 
		$MainPanel/Inside/BonusLabel.text = "Increases Area of Effect of basic attack and abilities by " + str(GlobalScript.SPECIALISATION_BONUSES.pyrotechnist.area_of_effect_of_basic_attack_and_abilities * 100.0) + "% of base values."
		$MainPanel/Inside/BonusLabel.text += "\nIncreases Damage of basic attack and abilities by " + str(GlobalScript.SPECIALISATION_BONUSES.pyrotechnist.damage_of_basic_attack_and_abilities * 100.0) + "% of base values."
	elif current_specialisation == "engineer":
		$MainPanel/Inside/BonusLabel.text = "Decreases Reload Time by " + str(GlobalScript.SPECIALISATION_BONUSES.engineer.reload_time * 100.0) + "% of base value."
		$MainPanel/Inside/BonusLabel.text += "\nIncreases Capacity by " + str(GlobalScript.SPECIALISATION_BONUSES.engineer.capacity * 100.0) + "% of base value."
	elif current_specialisation == "executor":
		$MainPanel/Inside/BonusLabel.text = "Increases Critical Hit Chance by " + str(GlobalScript.SPECIALISATION_BONUSES.executor.critical_hit_chance * 100.0) + "% of base value."
		$MainPanel/Inside/BonusLabel.text += "\nIncreases Critical Hit Damage by " + str(GlobalScript.SPECIALISATION_BONUSES.executor.critical_hit_damage * 100.0) + "% of base value."
	elif current_specialisation == "gunslinger":
		$MainPanel/Inside/BonusLabel.text = "Increases Attack Speed by " + str(GlobalScript.SPECIALISATION_BONUSES.gunslinger.attack_speed * 100.0) + "% of base value."
		$MainPanel/Inside/BonusLabel.text += "\nIncreases Projectile Speed by " + str(GlobalScript.SPECIALISATION_BONUSES.gunslinger.projectile_speed * 100.0) + "% of base value."
	elif current_specialisation == "strategist":
		$MainPanel/Inside/BonusLabel.text = "Increases Duration of abilities, buffs and fever by " + str(GlobalScript.SPECIALISATION_BONUSES.strategist.abilities_buffs_and_fever_duration * 100.0) + "% of base values."
		$MainPanel/Inside/BonusLabel.text += "\nDecreases Cooldown of all abilities by " + str(GlobalScript.SPECIALISATION_BONUSES.strategist.ability_cooldowns * 100.0) + "% of base values."
	elif current_specialisation == "collectioner":
		$MainPanel/Inside/BonusLabel.text = "At the end of each day, grants an additional " + str(GlobalScript.SPECIALISATION_BONUSES.collectioner.extra_resource_credits_earned_that_day * 100.0) + "% Resource Credits earned that day."
		$MainPanel/Inside/BonusLabel.text += "\nIncreases Drop Chance of Asteroids Shards by " + str(GlobalScript.SPECIALISATION_BONUSES.collectioner.shards_drop_chance * 100.0) + "% of base value."
	elif current_specialisation == "sentinel":
		$MainPanel/Inside/BonusLabel.text = "Increases all statistics of all Lasers and Pulse Bariers by " + str(GlobalScript.SPECIALISATION_BONUSES.sentinel.all_lasers_and_barriers_values * 100.0) + "% of base values."
		$MainPanel/Inside/BonusLabel.text += "\nReduces cost of all upgrades in Base upgrading tree by " + str(GlobalScript.SPECIALISATION_BONUSES.sentinel.base_tree_upgrade_costs_reduction * 100.0) + "%."
	elif current_specialisation == "polymath":
		$MainPanel/Inside/BonusLabel.text = "Enhances all cannon statistics by " + str(GlobalScript.SPECIALISATION_BONUSES.polymath.all_cannon_statistics * 100.0) + "% of base values."
		
func _on_pyrotechnist_button_pressed() -> void:
	current_specialisation = "pyrotechnist"
	change_specialisation()
	
func _on_collectioner_button_pressed() -> void:
	current_specialisation = "collectioner"
	change_specialisation()

func _on_engineer_button_pressed() -> void:
	current_specialisation = "engineer"
	change_specialisation()

func _on_strategist_button_pressed() -> void:
	current_specialisation = "strategist"
	change_specialisation()

func _on_executor_button_pressed() -> void:
	current_specialisation = "executor"
	change_specialisation()

func _on_gunslinger_button_pressed() -> void:
	current_specialisation = "gunslinger"
	change_specialisation()

func _on_sentinel_button_pressed() -> void:
	current_specialisation = "sentinel"
	change_specialisation()

func _on_polymath_button_pressed() -> void:
	current_specialisation = "polymath"
	change_specialisation()
	
func _on_confirm_button_pressed() -> void:
	if current_specialisation == "none": return
	if GlobalScript.current_data.game.player_specialisation == "none": actual_cost = 0
	else: actual_cost = specialisation_change_cost
	if GlobalScript.current_data.game.player_specialisation == current_specialisation: return 
	if GlobalScript.current_data.game.player_specialisation != "none" && GlobalScript.current_data.resources.credits < actual_cost: return
	$MainPanel.hide()
	$SecondaryPanel.show()
	$SecondaryPanel/ConfirmationInside/Label1.text = "You want to change your specialisation to: " + current_specialisation
	$SecondaryPanel/ConfirmationInside/Label2.text = "The cost of the operation is: " + str(actual_cost) + " Resource Credits"
	$SecondaryPanel/ConfirmationInside.show()

func _on_close_button_pressed() -> void:
	upgrade_console.activated = true
	queue_free()

func _on_no_button_pressed() -> void:
	$SecondaryPanel.hide()
	$MainPanel.show()

func _on_yes_button_pressed() -> void:
	#upgrade_console.add_resources("credits", actual_cost, false)
	#upgrade_console.update_points(0)
	#upgrade_console.update_upgrades(["Cannon", "Base"])
	upgrade_console.get_node("SpecialisationPlus/BlinkingAnimation").stop()
	$SecondaryPanel/ConfirmationInside.hide()
	$SecondaryPanel/ChangingSpecialisationInside.show()
	$SecondaryPanel/ChangingSpecialisationInside/Label.text = "Rewiring neuro connections..."
	specialisation_change_in_progress = true

func _on_continue_button_pressed() -> void:
	upgrade_console.activated = true
	queue_free()
