extends Control
const MESSAGE_BOX = preload("res://ui/message_box/message_box.tscn")

var activated: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var sound_muted: bool
var extraPoints: int = 0
var debug_enabled: bool = false
var hour: int
var minute: int
var initial_statistics_labels_already_adjusted = false
var toolTip: int = 0
var lastToolTipId: int = 0
var grid_alpha_mask_is_fading: bool = true
var grid_alpha_mask_duration: float = 6.0

#highscores
var mass_destructions_highscore: int
var accuracy_streaks_highscore: int
var chain_reactions_highscore: int

var ability_1: String
var ability_2: String
var ability_3: String
var ability_4: String
var buildings_save_data: Dictionary
var support_units_save_data: Dictionary

var trees_data: Dictionary = {
	"cannon": {
		"branches": {
			"damage": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"critical": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"capacity": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"speed": {
				"upgrade_references": [],
				"connection_line_references": []
			},
		},
		"upgrade_destinations": {
			"cannon": {
				"upgrades": {
					"small": {
						"area_of_effect": {
							"value": 0.05,
							"cost": {"credits": 600}
						},
						"capacity": {
							"value": 0.1,
							"cost": {"credits": 600}
						},
						"critical_hit_chance": {
							"value": 0.3,
							"cost": {"credits": 600}
						},
						"critical_hit_damage": {
							"value": 0.08,
							"cost": {"credits": 600}
						},
						"damage": {
							"value": 0.08,
							"cost": {"credits": 600}
						},
						"projectile_speed": {
							"value": 0.04,
							"cost": {"credits": 600}
						},
						"attack_speed": {
							"value": 0.05,
							"cost": {"credits": 600}
						},
						"reload_time": {
							"value": 0.04,
							"cost": {"credits": 600}
						}
					},
					"medium" : {
						"area_of_effect": {
							"value": 0.1,
							"cost": {"credits": 4000}
						},
						"capacity": {
							"value": 0.2,
							"cost": {"credits": 4000}
						},
						"critical_hit_chance": {
							"value": 0.6,
							"cost": {"credits": 4000}
						},
						"critical_hit_damage": {
							"value": 0.16,
							"cost": {"credits": 4000}
						},
						"damage": {
							"value": 0.16,
							"cost": {"credits": 4000}
						},
						"projectile_speed": {
							"value": 0.08,
							"cost": {"credits": 4000}
						},
						"attack_speed": {
							"value": 0.1,
							"cost": {"credits": 4000}
						},
						"reload_time": {
							"value": 0.08,
							"cost": {"credits": 4000}
						},
						"synaptic_pruning": {
							"description": "Critical strike is impossible.\nIncreases Damage by 30% of base value.",
							"cost": {"credits": 3000}
						},
						"heavy_calibration": {
							"description": "Decreases Rate of Fire by 10% of base value.\nIncreases Damage by 3% of base value by every 0.1 Rate of Fire below value of 3 you do not possess.",
							"cost": {"credits": 3000}
						},
						"impressive_dedication": {
							"description": "Increases Area of Effect by 20% of base value.\nAll other cannon statistics reduced by 10% of base values.",
							"cost": {"credits": 3000}
						},
						"fearless_pioneer": {
							"description": "Increases Critical Strike chance by 200% of base value.\nDecreases Area of Effect by 10% of base value.",
							"cost": {"credits": 3000}
						},
						"reclaimed_roots": {
							"description": "Decreases Damage by 30% of base value.\nIncreases Rate of Fire by 30% of base value.",
							"cost": {"credits": 3000}
						},
						"fuller_purse": {
							"description": "Increases reward for destroying asteroids by 1 Resource Credit.",
							"cost": {"credits": 3000}
						},
						"collateral_profit": {
							"description": "Increases Mass Destruction rewards by 50% of base value.",
							"cost": {"credits": 3000}
						},
						"amplified_connection": {
							"description": "Incrases Chain Reaction rewards by 50% of base value.",
							"cost": {"credits": 3000}
						},
						"critical_gambit": {
							"description": "Decreases Damage by 20% of base value.\nIncreases Critical Damage by 20% of base value.",
							"cost": {"credits": 3000}
						},
						"relevant_shift": {
							"description": "Decreases Critical Chance by 15% of base value. Decreases Critical Damage by 5% of base value.\nIncreases Rate of Fire by 20% of base value.",
							"cost": {"credits": 3000}
						},
						"apex_exploration": {
							"description": "Decreases Critical Chance by 30% of base value.\nRaises the upper threshold of possible maximum Critical Damage by 10%.",
							"cost": {"credits": 3000}
						},
						"nadir_expansion": {
							"description": "Decreases Critical Chance by 30% of base value.\nRaises the lower threshold of possible maximum Critical Damage by 10%.",
							"cost": {"credits": 3000}
						},
						"calculated_demolition": {
							"description": "Critical strike chance is fully converted to critical multiplier at rate 20:1. This effect does not convert critical strike chance gained from Sealed Fate's stacks and Lethal Stance.",
							"cost": {"credits": 3000}
						},
						"devils_bargain": {
							"description": "Decreases Rate of Fire by 25% of base value. Increases Critical Chance by 150% of base value.",
							"cost": {"credits": 3000}
						},
						"kinetic_transfer": {
							"description": "Decreases Projectile Speed by 10% of base value.\n15% of Projectile Speed upgrades, is also added to the Rate of Fire. Doesn't calculate in real time.",
							"cost": {"credits": 3000}
						},
						"holistic_imbalance": {
							"description": "Increases all statistics by 20% of their base values.",
							"cost": {"credits": 3000}
						},
						"multiplied_energy_redirection": {
							"description": "Decreases Capacity by 30% of base value.\nIncreases Damage by 60% of base value.",
							"cost": {"credits": 3000}
						}
					},
					"big": {
						"area_of_effect": {
							"value": 0.2,
							"cost": {"credits": 12000}
						},
						"capacity": {
							"value": 0.4,
							"cost": {"credits": 20000}
						},
						"critical_hit_chance": {
							"value": 1.2,
							"cost": {"credits": 20000}
						},
						"critical_hit_damage": {
							"value": 0.32,
							"cost": {"credits": 20000}
						},
						"damage": {
							"value": 0.32,
							"cost": {"credits": 12000}
						},
						"projectile_speed": {
							"value": 0.16,
							"cost": {"credits": 20000}
						},
						"attack_speed": {
							"value": 0.20,
							"cost": {"credits": 20000}
						},
						"reload_time": {
							"value": 0.16,
							"cost": {"credits": 20000}
						},
						"exposed_weakness": {
							"description": "When basic attack hits only one asteroid, generates a stack up to a maximum of 10. Each stack increases Damage towards the target by 3% of base value. Resets after switching target or hitting multiple targets.",
							"cost": {"credits": 24000}
						},
						"wide_innovation": {
							"description": "When basic attack hits at least 5 asteroids, a stack is generated up to a maximum of 10. Each stack increases Area of Effect by 3% of base value. Hitting less than 5 asteroids in one attack, removes 3 stacks.",
							"cost": {"credits": 24000}
						},
						"imminent_execution": {
							"description": "Critical strikes generate Execution Power, stacking up to 10 times. At 10 stacks, Lethal Stance automatically triggers. While Lethal Stance is active or on cooldown, Execution Power cannot be generated. Lethal Stance: Increases critical strike chance by 5% and critical multiplier by 50% for 5 seconds. Cooldown: 30 seconds.",
							"cost": {"credits": 24000}
						},
						"sealed_fate": {
							"description": "If a critical strike fails to occur, increases Critical Chance and Rate of Fire by 10% of base values. Stacks up to 10 times. Critical strike removes all stacks.",
							"cost": {"credits": 24000}
						},
						"euphoria": {
							"description": "Rate of Fire increases by 0.1 every 0.1s, up to a maximum of 10.0. The effect lasts 7 seconds. Reload Time during this time is lowered to 0.2s. Cannon cooldowns the barrel 2 seconds after the effect is gone. The effect triggers if there are 20 asteroids on the sky. Cooldown of the effect lasts 90 seconds.",
							"cost": {"credits": 24000}
						}
					}
				}
			}
		}
	},
	
	"abilities": {
		"branches": {
			"ability_1": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"ability_2": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"ability_3": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"ability_4": {
				"upgrade_references": [],
				"connection_line_references": []
			}
		},
		"upgrade_destinations": {
			"plasma_barrage": {
				"upgrades": {
					"small": {
						"area_of_effect": {
							"value": 0.05,
							"cost": {"nano_cores": 1}
							},
						"cooldown": {
							"value": 0.05,
							"cost": {"nano_cores": 1}
						},
						"damage": {
							"value": 0.05,
							"cost": {"nano_cores": 1}
						},
						"projectiles": {
							"value": 1,
							"cost": {"nano_cores": 1}
						}
					},
					"big": {
						"initial": {
							"description": "Cannon rapidly fires slightly unstable plasma projectiles that explode upon impact.",
							"cost": {"nano_cores": 3}
						},
						"special": {
							"description": "Projectiles have 50% chance to deal double damage.",
							"cost": {"nano_cores": 3}
						}
					},
				}
			},
			"stasis_field": {
				"upgrades": {
					"small": {
						"cooldown": {
							"value": 0.05,
							"cost": {"nano_cores": 1}
						},
						"duration": {
							"value": 0.15,
							"cost": {"nano_cores": 1}
						},
						"slow": {
							"value": 0.15,
							"cost": {"nano_cores": 1}
						}
					},
					"big": {
						"initial": {
							"description": "Stasis Field appears on the battlefield and slows all asteroids.",
							"cost": {"nano_cores": 3}
						},
						"special": {
							"description": "Projectile Speed and Rate of Fire is increased by 10% of base value when Stasis Field is active.",
							"cost": {"nano_cores": 3}
						}
					}
				}
			},
			"gravity_well": {
				"upgrades": {
					"small": {
						"area_of_effect": {
							"value": 0.07,
							"cost": {"nano_cores": 1}
						},
						"cooldown": {
							"value": 0.05,
							"cost": {"nano_cores": 1}
						},
						"explosion_duration": {
							"value": 0.15,
							"cost": {"nano_cores": 1}
						},
						"pull_force": {
							"value": 0.5,
							"cost": {"nano_cores": 1}
						},
						"slow_during_pull_force": {
							"value": 0.15,
							"cost": {"nano_cores": 1}
						}
					},
					"big": {
						"initial": {
							"description": "Cannon launches a projectile which pierces through all obstacles and explodes upon destination creating a gravity well. Area slows all asteroids and pulls them inwards.",
							"cost": {"nano_cores": 3}
						},
						"special": {
							"description": "Asteroids in Gravity Well take 20% increased damage.",
							"cost": {"nano_cores": 3}
						}
					}
				}
			},
			"orbital_strike": {
				"upgrades": {
					"small": {
						"area_of_effect": {
							"value": 0.05,
							"cost": {"nano_cores": 1}
						},
						"cooldown": {
							"value": 0.05,
							"cost": {"nano_cores": 1}
						},
						"damage": {
							"value": 0.05,
							"cost": {"nano_cores": 1}
						}
					},
					"big": {
						"initial": {
							"description": "Cannon launches a projectile that pierces through all obstacles and explodes upon destination.",
							"cost": {"nano_cores": 3}
						},
						"special": {
							"description": "Asteroids in epicenter (less than 30% radius) take double damage.",
							"cost": {"nano_cores": 3}
						}
					}
				}
			}
		}
	},
	
	"base": {
		"branches": {
			"left_laser_turret": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"right_laser_turret": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"left_pulse_barrier": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"right_pulse_barrier": {
				"upgrade_references": [],
				"connection_line_references": []
			}
		},
		"upgrade_destinations": {
			"left_laser_turret": {
				"upgrades": {},
			},
			"right_lase_turret": {
				"upgrades": {},
			},
			"left_pulse_barrier": {
				"upgrades": {},
			},
			"right_pulse_barrier": {
				"upgrades": {},
			}
			
		}
	},
	
	"asteroids": {
		"branches": {
			"damage": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"plasma": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"slow": {
				"upgrade_references": [],
				"connection_line_references": []
			},
			"chromatic": {
				"upgrade_references": [],
				"connection_line_references": []
			}
		},
		"upgrade_destinations": {
			"toxic_asteroid": {
				"upgrades": {},
			},
			"freezing_asteroid": {
				"upgrades": {},
			}
		}
	}
}

var destination_pascal_names = [
	"Cannon",
	"LeftLaser",
	"RightLaser",
	"LeftPulseBarrier",
	"RightPulseBarrier",
	"PlasmaBarrage",
	"StasisField",
 	"GravityWell",
	"OrbitalStrike"
]

var regular_upgrades_pascal_names = [
	"AreaOfEffect",
	"Capacity",
	"Cooldown",
	"CriticalHitChance",
	"CriticalHitDamage",
	"Damage",
	"ExplosionDuration",
	"Duration",
	"SlowDuringPullForce",
	"PullForce",
	"ProjectileSpeed",
	"Projectiles",
	"Fragments",
	"AttackSpeed",
	"ReloadTime",
	"Slow"
]

var other_upgrades_pascal_names = [
	"Initial",
	"Special",
	"SynapticPruning",
	"HeavyCalibration",
	"ImpressiveDedication",
	"FearlessPioneer",
	"ReclaimedRoots",
	"FullerPurse",
	"CollateralProfit",
	"ExposedWeakness",
	"WideInnovation",
	"AmplifiedConnection",
	"CriticalGambit",
	"RelevantShift",
	"ApexExploration",
	"NadirExpansion",
	"ImminentExecution",
	"CalculatedDemolition",
	"DevilsBargain",
	"SealedFate",
	"KineticTransfer",
	"Euphoria",
	"HolisticImbalance",
	"MultipliedEnergyRedirection"
]

func _ready():
	load_game()
	GlobalScript.init()
	get_window().grab_focus()
	intro()
	# GlobalScript.current_data.game.day = 2
	#player_specialisation = "none"
	modulate_statistics_labels()
	refresh_shards("all")
	update_nano_cores_label()
	calculate_and_set_statistics_labels("all")
	#show_upgrade_tree("Cannon", false)
	if GlobalScript.current_data.game.day >= GlobalScript.specialisation_unlock_day && GlobalScript.current_data.game.player_specialisation == "none":
		$SpecialisationPlus/BlinkingAnimation.play("blinking")
	elif GlobalScript.current_data.game.day < 5: $SpecialisationPlus.modulate = Color (0.5, 0.5, 0.5, 1)
	if GlobalScript.current_data.game.day >= 6:
		assign_values_to_blessings() 
		$UpgradeButtons/Blessings.show()
	else: $UpgradeButtons/Blessings.hide()
	await get_tree().create_timer(3).timeout
	
	var day_string: String = "day_" + str(GlobalScript.current_data.game.day)
	if GlobalScript.regular_messages.console.has(day_string):
		var new_msg_box = GlobalScript.get_message_box("console", GlobalScript.regular_messages.console[day_string])
		await display_message_box(new_msg_box)
				
	if GlobalScript.current_data.game.day == 6: $UpgradeButtons/BlessingsBlinkingAnimation.play("default")
	activated = true

func _process(_delta):
	if grid_alpha_mask_is_fading:
		$Background/GridAlphaMask.position.x += 6
		if $Background/GridAlphaMask.position.x >= 2500:
			$Background/GridAlphaMask.position.x = -1000
			grid_alpha_mask_is_fading = false
			await get_tree().create_timer(grid_alpha_mask_duration * 2).timeout
			grid_alpha_mask_is_fading = true
			var tween = get_tree().create_tween()
			var red: float = rng.randi_range(1, 100) / 100.0
			var green: float = rng.randi_range(1, 100) / 100.0
			var blue: float = rng.randi_range(1, 100) / 100.0
			var alpha = 0.5
			tween.tween_property($Background/GridAlphaMask, "modulate", Color(red, green, blue, alpha), grid_alpha_mask_duration)

func intro() -> void:
	$OpeningHatch.show()
	await get_tree().create_timer(1.5).timeout
	if !GlobalScript.current_data.game.muted: $Sounds/HatchOpening.play()
	for i in range(1, 15):
		await get_tree().create_timer(0.02).timeout
		$OpeningHatch/Upper.global_position.y -= 1.5
		$OpeningHatch/Lower.global_position.y += 1.5
	for i in range(1, 40):
		await get_tree().create_timer(0.02).timeout
		$OpeningHatch/Upper.global_position.y -= 15
		$OpeningHatch/Lower.global_position.y += 15
	$OpeningHatch.queue_free()

func load_game():
	print("Loading")
	var file = FileAccess.open(GlobalScript.get_save_path("game"), FileAccess.READ)
	GlobalScript.current_data = file.get_var()
	GlobalScript.initial_data = {}
	GlobalScript.initial_data = file.get_var()
	update_points(0)
	
	var upgrade_number = 0
	var cannon_upgrades = file.get_var()
	for branch in $UpgradeTrees/Cannon.get_children():
		for upgrade in branch.get_children():
			var branch_name = branch.get_name().to_snake_case()
			if !cannon_upgrades.is_empty(): upgrade.IsBought = cannon_upgrades[upgrade_number]
			trees_data["cannon"]["branches"][branch_name]["upgrade_references"].append(upgrade)
			upgrade_number += 1
			
	var plasma_barrage_upgrades = file.get_var()
	upgrade_number = 0
	for upgrade in $UpgradeTrees/Abilities/Ability1.get_children():
		if !plasma_barrage_upgrades.is_empty(): upgrade.IsBought = plasma_barrage_upgrades[upgrade_number]
		trees_data["abilities"]["branches"]["ability_1"]["upgrade_references"].append(upgrade)
		upgrade_number += 1
		
	var stasis_field_upgrades = file.get_var()
	upgrade_number = 0
	for upgrade in $UpgradeTrees/Abilities/Ability2.get_children():
		if !stasis_field_upgrades.is_empty(): upgrade.IsBought = stasis_field_upgrades[upgrade_number]
		trees_data["abilities"]["branches"]["ability_2"]["upgrade_references"].append(upgrade)
		upgrade_number += 1
		
	var gravity_well_upgrades = file.get_var()
	upgrade_number = 0
	for upgrade in $UpgradeTrees/Abilities/Ability3.get_children():
		if !gravity_well_upgrades.is_empty(): upgrade.IsBought = gravity_well_upgrades[upgrade_number]
		trees_data["abilities"]["branches"]["ability_3"]["upgrade_references"].append(upgrade)
		upgrade_number += 1
		
	var orbital_strike_upgrades = file.get_var()
	upgrade_number = 0
	for upgrade in $UpgradeTrees/Abilities/Ability4.get_children():
		if !orbital_strike_upgrades.is_empty(): upgrade.IsBought = orbital_strike_upgrades[upgrade_number]
		trees_data["abilities"]["branches"]["ability_4"]["upgrade_references"].append(upgrade)
		upgrade_number += 1
		
	mass_destructions_highscore = file.get_var()
	accuracy_streaks_highscore = file.get_var()
	chain_reactions_highscore = file.get_var()
	file.close()

func save_game():
	var file = FileAccess.open(GlobalScript.get_save_path("game"), FileAccess.WRITE)
	print ("Saving")
	GlobalScript.current_data.game.last_save_date = GlobalScript.get_current_date()
	file.store_var(GlobalScript.current_data)
	file.store_var(GlobalScript.initial_data)

	var cannon_upgrades = []
	for branch in $UpgradeTrees/Cannon.get_children():
		for upgrade in branch.get_children():
			cannon_upgrades.append(upgrade.IsBought)
	file.store_var(cannon_upgrades)
	
	var plasma_barrage_upgrades = []
	for upgrade in $UpgradeTrees/Abilities/Ability1.get_children():
		plasma_barrage_upgrades.append(upgrade.IsBought)
	file.store_var(plasma_barrage_upgrades)
	
	var stasis_field_upgrades = []
	for upgrade in $UpgradeTrees/Abilities/Ability2.get_children():
		stasis_field_upgrades.append(upgrade.IsBought)
	file.store_var(stasis_field_upgrades)
	
	var gravity_well_upgrades = []
	for upgrade in $UpgradeTrees/Abilities/Ability3.get_children():
		gravity_well_upgrades.append(upgrade.IsBought)
	file.store_var(gravity_well_upgrades)
	
	var orbital_strike_upgrades = []
	for upgrade in $UpgradeTrees/Abilities/Ability4.get_children():
		orbital_strike_upgrades.append(upgrade.IsBought)
	file.store_var(orbital_strike_upgrades)
	file.store_var(mass_destructions_highscore)
	file.store_var(accuracy_streaks_highscore)
	file.store_var(chain_reactions_highscore)
	file.close()

func update_points(Points):
	if Points != 0: GlobalScript.current_data.resources.credits -= Points
	$Score/ResourceCreditsCount.text = str(GlobalScript.current_data.resources.credits)

func update_nano_cores_label():
	$Score/NanoCoresCount.text = str(GlobalScript.current_data.resources.nano_cores)

func _on_done_pressed():
	if !activated: return
	if $UpgradeTrees/Abilities/Ability1/PlasmaBarrageBigUpgrade0Initial.IsBought: ability_1 = "Plasma Barrage"
	if $UpgradeTrees/Abilities/Ability2/StasisFieldBigUpgrade0Initial.IsBought: ability_2 = "Stasis Field"
	if $UpgradeTrees/Abilities/Ability3/GravityWellBigUpgrade0Initial.IsBought: ability_3 = "Gravity Well"
	if $UpgradeTrees/Abilities/Ability4/OrbitalStrikeBigUpgrade0Initial.IsBought: ability_4 = "Orbital Strike"
	$fadeOffSolid.show()
	$fadeOff.play("fade_off")
	if !GlobalScript.current_data.game.muted: $Sounds/LaunchGame.play()
	await get_tree().create_timer(2.0).timeout
	save_game()
	GlobalScript.load_scene("game")

func _on_main_menu_pressed() -> void:
	if !activated: return
	get_tree().change_scene_to_file("res://main_menu/menu.tscn")

func play_ok_sound():
	if !GlobalScript.current_data.game.muted: $Sounds/Ok.play()

func play_nok_sound():
	if !GlobalScript.current_data.game.muted: $Sounds/Nok.play()

func refresh_shards(Type) -> void:
	if Type == "all" || Type == "common":
		$Score/CommonShardsCount.text = str(GlobalScript.current_data.resources.common_shards)
	if Type == "all" || Type == "celestial":
		$Score/CelestialShardsCount.text = str(GlobalScript.current_data.resources.celestial_shards)
	if Type == "all" || Type == "astral":
		$Score/AstralShardsCount.text = str(GlobalScript.current_data.resources.astral_shards)
	if Type == "all" || Type == "ethereal":
		$Score/EtherealShardsCount.text = str(GlobalScript.current_data.resources.ethereal_shards)

func _on_cannon_pressed() -> void:
	show_upgrade_tree("Cannon", true)

func _on_abiliites_pressed() -> void:
	show_upgrade_tree("Abilities", true)

func add_nano_cores(amount) -> void:
	GlobalScript.current_data.resources.nano_cores += amount
	update_nano_cores_label()

func calculate_and_set_statistics_labels(scope: String) -> void:
	return
	var destinations = get_statistic_destinations(scope)
	for destination in destinations:
		var tree_name: String
		if destination.get_name() == "Cannon": tree_name = "cannon"
		else: tree_name = destination.get_parent().get_name().to_snake_case()
		for label_group in destination.get_node("Labels").get_children():
			for label in label_group.get_children():
				var label_name = label.get_name()
				var group_name = label_group.get_name()
				if label_name != "Main" and group_name != "Type":
					if group_name == "Initial":
						label.text = "[color=" + GlobalScript.COLOR_PALETTE.initial_statistic_value_color + "]" + str(GlobalScript["initial_statistics"][destination.get_name().to_snake_case()][label.get_name().to_snake_case()])
					elif group_name in ["Current", "Difference"]:
						var label_snake_name: String = label.get_name().to_snake_case()
						var destination_snake_name: String = destination.get_name().to_snake_case()
						var initial_value: float = GlobalScript["initial_statistics"][destination_snake_name][label_snake_name]
						var multiplier: float = trees_data[tree_name]["upgrade_destinations"][destination_snake_name]["save_data"][label_snake_name + "_multiplier"]
						# Deklaracja zmiennej bez typu czyni ja dynamiczna kosztem wydajnosci.
						# Sztywnego typu zmiennej nie mozna zmienic w zaden sposob.
						# Zeby wyswietlic float jako int trzeba uzyc dodatkowej zmiennej lub funkcji
						# Zaokraglanie dzieje sie za pomoca snapped bo w przypadku procentow ma gorsza dokladnosc
						var current_value: float = initial_value * multiplier
						if group_name == "Current": label.text = "[color=" + GlobalScript.COLOR_PALETTE.statistic_value_color + "]" + if_int_cut_decimals(current_value)
						elif group_name == "Difference":
							var difference_value: float = current_value - initial_value
							var value_sign: String = ""
							if difference_value > 0.0: value_sign = "+"
							var difference_percent: float = difference_value / initial_value
							label.text = value_sign + if_int_cut_decimals(difference_value) + " (" + value_sign + str(snapped(difference_percent * 100, 1)) + "%)"
							var red = 1 - abs(difference_percent)
							var blue = 1 - abs(difference_percent)
							var green = 1 + abs(difference_percent)
							label.modulate = Color(red, green, blue, 1)
					if group_name in ["Initial", "Current"]:
						if label_name in ["ReloadTime", "Cooldown", "Duration"]:
							if !label.text.contains("s"): label.text += "s"
						elif label_name in ["Slow", "CriticalHitChance"]:
							if !label.text.contains("%"): label.text += "%"

func if_int_cut_decimals(value_a: float):
	var value_b: String
	if fmod(snapped(value_a, 0.01), 1.0) == 0.0: value_b = str(snapped(value_a, 1))
	else: value_b = str(snapped(value_a, 0.01))
	return value_b

func get_statistic_destinations(scope):
	# wrzuca do array node'y które mają pod sobą labele
	# jeśli scope nie jest równy "all" wrzuca tylko to co jest pod scope
	var destinations = []
	for group in $Statistics.get_children():
		if group.get_name() != "Cannon":
			for child in group.get_children():
				if scope != "all":
					if child.get_name().to_snake_case() == scope: destinations.append(child)
				else: destinations.append(child)
		else:
			if scope != "all":
				if group.get_name().to_snake_case() == scope: destinations.append(group)
			else: destinations.append(group)
	return destinations

func show_upgrade_tree(tree_name_to_show: String, play_sound: bool) -> void:
	$CurentTree.text = tree_name_to_show
	for tree in $UpgradeTrees.get_children():
		if str(tree).contains(tree_name_to_show):
			tree.show()
			for branch in tree.get_children():
				for line in trees_data[tree.get_name().to_snake_case()]["branches"][branch.get_name().to_snake_case()]["connection_line_references"]: line.show()
		else: 
			tree.hide()
			for branch in tree.get_children():
				for line in trees_data[tree.get_name().to_snake_case()]["branches"][branch.get_name().to_snake_case()]["connection_line_references"]: line.hide()
	
	for statistic in $Statistics.get_children():
		if str(statistic).contains(tree_name_to_show): statistic.show()
		else: statistic.hide()
		
		
	if tree_name_to_show == "God's Blessings":
		$GodsBlessings.show()
		$SpecialisationPlus.hide()
		$Statistics/Cannon.show()
		$CurentTree.add_theme_font_size_override("font_size", 88)
	else: 
		$GodsBlessings.hide()
		$SpecialisationPlus.show()
		$CurentTree.add_theme_font_size_override("font_size", 110)
		
	if tree_name_to_show == "Asteroids" and GlobalScript.current_data.game.day < GlobalScript.asteroids_tree_unlock_day:
		$UpgradeTrees/Asteroids.hide()
		$Statistics/Asteroids.hide()
		$SpecialisationPlus.hide()
		# obecny dzien - 1 zeby system nie liczyl tego co jeszcze sie nie ukazalo na ekranie
		$AsteroidsTreeDisabledPanel/ProgressBar.value = (1.0 - (((GlobalScript.asteroids_tree_unlock_day - 1) * 1.0 - (GlobalScript.current_data.game.day - 1) * 1.0) / (GlobalScript.asteroids_tree_unlock_day - 1) * 1.0)) * 100.0
		$AsteroidsTreeDisabledPanel.show()
	else:
		$AsteroidsTreeDisabledPanel.hide()


	if play_sound: $Sounds/TreeChange.play()

func add_resources(resource: String, amount: int, add: bool) -> void:
	var resource_label = null # zmiana na Resource?
	if !add: amount *= -1
	if resource == "credits" : resource_label = $Score/ResourceCreditsCount
	elif resource == "nano_cores" : resource_label = $Score/NanoCoresCount
	GlobalScript.current_data.resources[resource] += amount
	resource_label.text = str(GlobalScript.current_data.resources[resource])

func modulate_statistics_labels() -> void:
	var destinations = get_statistic_destinations("all")
	for destination in destinations:
		destination.get_node("MainLabel").text = "[color=" + GlobalScript.COLOR_PALETTE.ability_name + "]" + destination.get_name().capitalize() + "[/color]" + " statistics"
		for label in destination.get_node("Labels").get_node("Type").get_children():
			if !label.get_name().contains("Main"): label.text = "[color=" + GlobalScript.COLOR_PALETTE.statistic_name_color + "]" + label.text + "[/color]"

func update_upgrades(scope: Array) -> void:
	if scope == []: scope = ["Abilities", "Cannon", "Base", "Asteroids"]
	for tree in $UpgradeTrees.get_children():
		if tree.get_name() in scope:
			for branch in tree.get_children():
				for upgrade in branch.get_children():
					#print (upgrade.get_name())
					upgrade.adjust_modulation()

func _on_reset_trees_pressed() -> void:
	for tree in $UpgradeTrees.get_children():
		for branch in tree.get_children():
			for upgrade in branch.get_children():
				upgrade.IsBought = false
				upgrade.adjust_modulation()

func _on_asteroids_pressed() -> void:
	show_upgrade_tree("Asteroids", true)

func _on_blessings_pressed() -> void:
	$UpgradeButtons/BlessingsBlinkingAnimation.stop()
	show_upgrade_tree("God's Blessings", true)

func assign_values_to_blessings() -> void:
	pass
	#for i in blessings.size():
	#	var blessing_node = $GodsBlessings.get_node("Blessing" + str(i + 1))
	#	var blessing_number = blessings[i]
	#	var verb: String = "Increases"
	#	if GlobalScript.blessings[blessing_number]["display_name"] == "Reload Time": verb = "Decreases"
	#	blessing_node.get_node("Background").color = Color (1, 1, 1, 0.5)
	#	blessing_node.get_node("Label").text = verb + " " + GlobalScript.blessings[blessing_number]["display_name"] + " by " + str(GlobalScript.blessings[blessing_number]["value"]) + "% of base value."

func _on_add_resources_pressed() -> void:
	add_resources("credits", 10000, true)
	add_resources("nano_cores", 10, true)

func _on_substract_resources_pressed() -> void:
	add_resources("credits", 10000, false)
	add_resources("nano_cores", 10, false)

func display_message_box(new_message_box: Control) -> void:
	activated = false
	add_child(new_message_box)
	new_message_box.z_index = 3
	await new_message_box.ready_to_continue
	activated = true
