extends Node
# === config === 
var skip_intro: bool = true
var specialisation_unlock_day: int = 5
var asteroids_tree_unlock_day: int = 12
const PLANET_NAME = "Oasis"
var auto_pause_when_lost_focus: bool = true
var previous_scene: String = "menu"
const MESSAGE_BOX = preload("res://ui/message_box/message_box.tscn")
const DEFAULT_CURSOR = preload("res://cursor.png")
const RELOAD_CURSOR = preload("res://cursor_reload.png")

var settings: Dictionary = {
	"game_muted": false,
	"debug": {
		"enabled": false,
		"cant_lose": false,
		"asteroids_stopped": false,
		"all_cds_disabled": true,
		"keep_pressing_hotkey_to_spawn_asteroids": true,
		"debug_values": true,
		"day": 13,
		"basic_attack_damage": 200,
		"basic_attack_reload_time": 1,
		"basic_attack_attack_speed": 5,
		"basic_attack_capacity": 50,
		"basic_attack_area_of_effect": 200,
		"basic_attack_critical_hit_damage_thresholds": [1.2, 1.4],
		"basic_attack_critical_hit_chance": 0.1,
		"projectile_speed": 700
}
}

const COLOR_PALETTE: Dictionary = {
	"object_color": "HOT_PINK",
	"ability_name": "ORANGE",
	"statistic_name_color": "GOLD",
	"statistic_value_color": "DARK_TURQUOISE",
	"initial_statistic_value_color": "GRAY",
}

const SPECIALISATION_BONUSES = {
	"pyrotechnist": {
		"area_of_effect_of_basic_attack_and_abilities" = 0.15,
		"damage_of_basic_attack_and_abilities" = 0.45,
	},
	"engineer": {
		"reload_time" = 0.2,
		"capacity" = 0.7,
	},
	"executor": {
		"critical_hit_chance" = 3.0,
		"critical_hit_damage" = 0.3
	},
	"gunslinger": {
		"attack_speed" = 0.35,
		"projectile_speed" = 0.2,
	},
	"strategist": {
		"abilities_buffs_and_fever_duration" = 0.35,
		"ability_cooldowns" = 0.15,
	},
	"collectioner": {
		"extra_resource_credits_earned_that_day" = 0.05,
		"shards_drop_chance" = 0.2,
	},
	"sentinel": {
		"all_lasers_and_barriers_values" = 0.2,
		"base_tree_upgrade_costs_reduction" = 0.05,
	}
}

const BLESSING_BONUSES: Dictionary = {
	"cannon": {
		"reload_time": 0.07,
		"projectile_speed": 0.2,
		"attack_speed": 0.20,
		"capacity": 0.3,
		"explosion": {
			"area_of_effect": 0.12,
			"damage": 0.25,
			"critical_hit_chance": 1,
			"critical_hit_damage_thresholds": 0.15
		}
	},
	"laser_turret": {
		"attack_speed": 0.25,
		"attack_range": 0.15,
		"damage": 0.25,
	},
	"pulse_barrier": {
		"attack_speed": 0.25,
		"attack_range": 0.15,
		"damage": 0.25,
	}
}

const COMMON_STRUCTURE_DICTIONARY_RECEIVERS: Dictionary = {
	"left_radar": {
		"extra_dictionaries": {
			"dish": {},
		}
	},
	"right_radar": {
		"extra_dictionaries": {
			"dish": {},
		}
	},
	"left_heat_interceptor": {
		"extra_dictionaries": {
			"fever": {},
		}
	},
	"right_heat_interceptor": {
		"extra_dictionaries": {
			"fever": {},
		}
	},
	"left_overclock_station": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 0.35,
				"receivers": ["plasma_barrage", "stasis_field", "gravity_well", "orbital_strike"],
				"statistic_structures": [
					["cooldown"]
				]
			}
		}
	},
	"right_overclock_station": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 0.35,
				"receivers": ["plasma_barrage", "stasis_field", "gravity_well", "orbital_strike"],
				"statistic_structures": [
					["cooldown"]
				]
			}
		}
	},
	"cryo_silos": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 2.5,
				"receivers": ["cannon"],
				"statistic_structures": [
					["attack_speed"]
				]
			}
		}
	},
	"projectile_accelerator": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 2.0,
				"receivers": ["cannon"],
				"statistic_structures": [
					["projectile_speed"]
				]
			}
		}
	},
	"energy_storage_nexus": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 3.0,
				"receivers": ["cannon"],
				"statistic_structures": [
					["capacity"]
				]
			}
		}
	},
	"plasma_reactor": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 1.0,
				"receivers": ["cannon"],
				"statistic_structures": [
					["reload_time"]
				]
			}
		}
	},
	"power_generator": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 2.0,
				"receivers": ["cannon"],
				"statistic_structures": [
					["explosion", "damage"]
				]
			}
		}
	},
	"critical_power_generator": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 1.5,
				"receivers": ["cannon"],
				"statistic_structures": [
					["explosion", "critical_hit_damage_thresholds"]
				]
			}
		}
	},
	"explosion_amplifier": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 2.0,
				"receivers": ["cannon"],
				"statistic_structures": [
					["explosion", "area_of_effect"]
				]
			}
		}
	},
	"impact_prediction_center": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 4.5,
				"receivers": ["cannon"],
				"statistic_structures": [
					["explosion", "critical_hit_chance"]
				]
			}
		}
	},
	"left_ion_flux_turbine": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 1.0,
				"receivers": ["left_laser_turret", "left_pulse_barrier"],
				"statistic_structures": [
					["attack_range"],
					["attack_speed"],
					["damage"]
				]
			}
		}
	},
	"right_ion_flux_turbine": {
		"extra_dictionaries": {
			"bonuses_for_other_objects": {
				"growth_rate": 1.0,
				"receivers": ["right_laser_turret", "right_pulse_barrier"],
				"statistic_structures": [
					["attack_range"],
					["attack_speed"],
					["damage"]
				]
			}
		}
	}
}

const EXTRA_STRUCTURE_DICTIONARIES: Dictionary = {
	"bonuses_for_other_objects": {
		"max_growth_rate_multiplier": 25.0,
		"base_growth_rate_multiplier": 5.0,
		"total_growth_rate_multiplier": 0.0,
		"base_bonus": 0.0,
		"growth_rate_bonus": 0.0,
		"total_bonus": 0.0,
	},
	"dish": {
		"rotation": 0.0
	},
	"fever": {
		"bonus": 2.5
	}
}

const VFX_DATA: Dictionary = {
	"ordinary_projectile_explosion_particles": {
		"modulate_to_comp_color": true,
		"initial_amount_ratio_variation": 0.2,
		"adjust_amount_ratio_to_scale_factor": true,
		"area_of_effect": 100.0,
		"scaling_reference": "area_of_effect"
	},
	
	"asteroid_damaged_particles": {
		"modulate_to_tier": true,
		"not_removable": true,
		"initial_amount_ratio_variation": 0.2,
		"adjust_amount_ratio_to_scale_factor": true,
		"scaling_reference": "parent_scale"
	},
	
	"structure_damaged_smoke_particles": {
		"initial_amount_ratio_variation": 0.4,
	},
	"structure_damaged_particles": {
		"initial_amount_ratio_variation": 0.4,
	},
	"structure_destroyed_fire_particles": {
		"initial_amount_ratio_variation": 0.4,
	},
	"structure_destroyed_explosion_particles": {
		"initial_amount_ratio_variation": 0.4,
	},
	
	"gravity_well_rings": {
		"assign_as_child_of": "explosion",
		"area_of_effect": 300.0,
		"scaling_reference": "area_of_effect"
	},
	
	"gravity_well_particles": {
		"assign_as_child_of": "explosion",
		"area_of_effect": 300,
		"adjust_amount_ratio_to_scale_factor": true,
		"scaling_reference": "area_of_effect"
	},
	
	"gravity_well_projectile_following_particles": {
		"follow_parent": true,
		"assign_as_child_of": "object",
		"initial_amount_ratio_variation": 0.2,
	},
	
	"orbital_strike_projectile_following_particles": {
		"follow_parent": true,
		"assign_as_child_of": "object",
		"initial_amount_ratio_variation": 0.2,
	},
	
	"orbital_strike_projectile_explosion_particles": {
		"area_of_effect": 270.0,
		"initial_amount_ratio_variation": 0.1,
		"adjust_amount_ratio_to_scale_factor": true,
		"scaling_reference": "area_of_effect"
	},
	
	"ordinary_asteroid_following_particles": {
		"initial_amount_ratio_variation": 0.2,
		"adjust_amount_ratio_to_scale_factor": true,
		"follow_parent": true,
		"assign_as_child_of": "object",
		"modulate_to_comp_color": true,
		"not_removable": true,
		"scaling_reference": "parent_scale"
	},
	
	"ordinary_asteroid_following_particles_smoke": {
		"initial_amount_ratio_variation": 0.2,
		"adjust_amount_ratio_to_scale_factor": true,
		"follow_parent": true,
		"assign_as_child_of": "object",
		"not_removable": true,
		"scaling_reference": "parent_scale"
	},
	
	"asteroid_destroyed_particles": {
		"adjust_amount_ratio_to_scale_factor": true,
		"modulate_to_comp_color": true,
		"not_removable": true,
		"scaling_reference": "parent_scale"
	},
	
	"following_gas_particles": {
		"adjust_amount_ratio_to_scale_factor": true,
		"initial_amount_ratio_variation": 0.2,
		"follow_parent": true,
		"assign_as_child_of": "object",
		"modulate_to_comp_color": true,
		"scaling_reference": "parent_scale"
	},
	
	"following_snow_particles": {
		"adjust_amount_ratio_to_scale_factor": true,
		"follow_parent": true,
		"assign_as_child_of": "object",
		"initial_amount_ratio_variation": 0.2,
		"scaling_reference": "parent_scale"
	},
	
	"shockwave_asteroid_pulsing": {
		"assign_as_child_of": "object",
		"scaling_reference": "parent_scale"
	},
	
	"plasma_asteroid_following_particles": {
		"adjust_amount_ratio_to_scale_factor": true,
		"initial_amount_ratio_variation": 0.2,
		"follow_parent": true,
		"assign_as_child_of": "object",
		"scaling_reference": "parent_scale"
	},
	
	"ribbons_asteroid_following_particles": {
		"adjust_amount_ratio_to_scale_factor": true,
		"initial_amount_ratio_variation": 0.2,
		"follow_parent": true,
		"assign_as_child_of": "object",
		"modulate_to_comp_color": true,
		"scaling_reference": "parent_scale"
	},
	
	"asteroid_destroyed_ring": {
		"modulate_to_tier": true,
		"scaling_reference": "parent_scale",
		"not_removable": true,
	},
	
	"shield_damaged_particles": {
		"scaling_reference": "parent_scale",
		"modulate_to_tier": true,
	},
	
	"shield_destroyed_particles": {
		"scaling_reference": "parent_scale",
		"modulate_to_tier": true,
	}
}

var initial_config: Dictionary = {
	"new_game": false,
	"save_slot": 1,
	"save_path": "user://save_game",
	"config_path": "user://config",
	"game_difficulty": ""
}

const legacy_data: Dictionary = {
	"game": {
		"day": 1,
		"difficulty": "",
		"player_specialisation": "none",
		"save_slot": 1,
		"save_creation_date": "",
		"last_save_date": "",
		"time": [0, 0],
		"rain": false,
		"fractals": false,
		"low_sky_modulation": Color(0, 0, 0, 0),
		"high_sky_modulation": Color(0, 0, 0, 0),
		"month_literally": "",
		"month_day": "",
		"cloud_spawn_chance": 0,
		"muted": false,
		"included_additive_stats": []
	},
	
	"resources": {
		"credits": 0,
		"nano_cores": 0,
		"common_shards": 0,
		"celestial_shards": 0,
		"astral_shards": 0,
		"ethereal_shards": 0,
		"divine_shards": 0,
		"shard_drop_chance": 0.02,
		"additive_statistics": {}
	},
	
	"fever": {
		"enabled": false,
		"initial_damage_requirement": 500,
		"current_damage_requirement": 0,
		"damage_percent_increase_rate": 50,
		"initial_percent_bonus": 20,
		"bonus_percent_increase_rate": 5,
		"data_adjust_days_interval": 10,
		"duration": 10,
		"specialisation_duration_bonus": 0,
		"additive_statistics": {}
	},

	"rewards": {
		"regular_asteroid": 8,
		"shower_asteroid": 2, 
		"huge_asteroid": 50,
		"accuracy_streak": 1,
		"chain_reaction": 5,
		"hyper_asteroid": 2,
		"mass_destruction": 1,
		"last_stand": 100,
		"additive_statistics": {}
	},
	
	"next_blessings_config": {
		"cloud_1": {},
		"cloud_2": {},
		"cloud_3": {}
	},
	"blessings": {},
	"buffs": {},

	"structures": {
		"general": {
			"audio_visual_effects": {
				"sound_when_damaged": {
					"name": "structure_damaged",
					"volume_gain": 0.0,
					"pitch": 1.0,
					"pitch_percent_variation": 0.03
				},
				"visuals_when_damaged": ["structure_damaged_smoke_particles", "structure_damaged_particles"],
				"visuals_when_destroyed": ["structure_destroyed_fire_particles", "structure_destroyed_explosion_particles"]
			}
		},
		"cannon": {
			"active": true,
			"active_days": 0,
			"composition_color": Color(0.3, 1, 1),
			"fever_composition_color": Color(1, 0.5, 0.4),
			"capacity": 20,
			"projectile_speed": 480,
			"reload_time": 3.5,
			"attack_speed": 0.65, # strzaly na sekunde
			"durability": {
				"daily_percent_recovery_rate": 10,
				"current_points": 200,
				"max_points": 200,
				"repair_days": 3,
				"current_repair_days": 0
			},
			"explosion": {
				# druga wartość 0 oznacza ze nie zanika
				"rise_and_decay_time": [0.2, 0.2],
				"alpha_channel": 0.8,
				"shape": "round",
				"area_of_effect": 60.0, # srednica / diameter 60
				"damage": 30,
				"critical_hit_chance": 0.04,
				"critical_hit_damage_thresholds": [1.5, 1.8]
			},
			"projectile": {
				"audio_visual_effects": {
					"sound_when_launched": {
						"name": "ordinary_projectile_launch",
						"volume_gain": 0.0,
						"pitch": 1.15,
						"pitch_percent_variation": 0.02
					},
					"sound_when_destroyed": {
						"name": "ordinary_projectile_explosion",
						"volume_gain": 0.0,
						"pitch": 1.0,
						"pitch_percent_variation": 0.05
					},
					"visuals_when_destroyed": ["ordinary_projectile_explosion_particles"]
				},
				"ghost": false,
			},
			"additive_statistics": {}
		},
	
		"laser_turret": {
			"active": true,
			"prioritize_lowest_altitude_targets": false,
			"attack_speed": 0.3,
			"damage": 30,
			"attack_range": 300,
			"active_days": 0,
			"durability": {
				"daily_percent_recovery_rate": 10,
				"current_points": 200,
				"max_points": 200,
				"repair_days": 3,
				"current_repair_days": 0
			},
			"additive_statistics": {}
		},
	
		"pulse_barrier": {
			"active": true,
			"prioritize_lowest_altitude_targets": false,
			"attack_speed": 0.2,
			"damage": 50,
			"minimum_number_of_targets": 3,
			"maximum_number_of_targets": 3,
			"attack_range": 350,
			"active_days": 0,
			"durability": {
				"daily_percent_recovery_rate": 10,
				"current_points": 200,
				"max_points": 200,
				"repair_days": 3,
				"current_repair_days": 0
			},
			"additive_statistics": {}
		},
	
		"common_structure": {
			"active": true,
			"active_days": 0,
			"durability": {
				"daily_percent_recovery_rate": 10,
				"current_points": 100,
				"max_points": 100,
				"repair_days": 3,
				"current_repair_days": 0
			},
			"additive_statistics": {}
		}
	},
	
	"abilities": {
		"plasma_barrage": {
			"cooldown": 45.0,
			"projectiles": 5,
			"bought": false,
			"composition_color": Color(1, 0.3, 1),
			"explosion": {
				"rise_and_decay_time": [0.25, 0.25],
				"shape": "round",
				"alpha_channel": 0.8,
				"area_of_effect": 120.0,
				"damage": 30.0,
			},
			"projectile": {
				"audio_visual_effects": {
					"sound_when_launched": {
						"name": "ordinary_projectile_launch",
						"volume_gain": 0.0,
						"pitch": 1.0,
						"pitch_percent_variation": 0.05
					},
					"sound_when_destroyed": {
						"name": "ordinary_projectile_explosion",
						"volume_gain": 0.0,
						"pitch": 1.0,
						"pitch_percent_variation": 0.05
					},
					"visuals_when_destroyed": ["ordinary_projectile_explosion_particles"]
				},
				"modules": {
					"trajectory_tweak": {"strength": 3},
				},
				"ghost": false,
			},
			"additive_statistics": {}
		},
		
		"stasis_field": {
			"duration": 7.0,
			"cooldown": 50.0,
			"slow_power": 20.0,
			"bought": false,
			"enabled": false,
			"additive_statistics": {}
		},
		
		"gravity_well": {
			"bought": false,
			"composition_color": Color(0.2, 0.6, 1.0),
			"cooldown": 55.0,
			"explosion": {
				"rise_and_decay_time": [0.3, 0.0],
				"shape": "round",
				"alpha_channel": 0.1,
				"area_of_effect": 300.0,
				"duration": 6.0,
				"pull_force": 3.0,
				"pull_slow": 10.0
			},
			"projectile": {
				"audio_visual_effects": {
					"sound_when_launched": {
						"name": "gravity_well_projectile_launch",
						"volume_gain": 0.0,
						"pitch": 1.0,
						"pitch_percent_variation": 0.05
					},
					"sound_when_destroyed": {
						"name": "ordinary_projectile_explosion",
						"volume_gain": 0.0,
						"pitch": 1.0,
						"pitch_percent_variation": 0.05
					},
					"visuals_when_launched": ["gravity_well_projectile_following_particles"],
					"visuals_when_destroyed": ["ordinary_projectile_explosion_particles", "gravity_well_rings", "gravity_well_particles"]
				},
				"ghost": true,
			},
			"additive_statistics": {}
		},
		
		"orbital_strike": {
			"bought": false,
			"composition_color": Color(0.6, 1, 0.2),
			"cooldown": 60,
			"explosion": {
				"rise_and_decay_time": [0.25, 0.25],
				"shape": "round",
				"alpha_channel": 0.8,
				"area_of_effect": 270.0,
				"damage": 60,
			},
			"projectile": {
				"audio_visual_effects": {
					"sound_when_launched": {
						"name": "orbital_strike_projectile_launch",
						"volume_gain": 0.0,
						"pitch": 1.0,
						"pitch_percent_variation": 0.05
					},
					"sound_when_destroyed": {
						"name": "orbital_strike_projectile_explosion",
						"volume_gain": 0.0,
						"pitch": 1.0,
						"pitch_percent_variation": 0.05
					},
					"visuals_when_launched": ["orbital_strike_projectile_following_particles"],
					"visuals_when_destroyed": ["orbital_strike_projectile_explosion_particles"]
				},
				"ghost": true,
			},
			"additive_statistics": {}
		}
	},
	
	"asteroids": {
		"general": {
			"audio_visual_effects": {
				"sound_when_damaged": {
					"name": "asteroid_damaged",
					"volume_gain": -1.5,
					"pitch": 1.0,
					"pitch_percent_variation": 0.05,
					"not_removable": true
				},
				"visuals_when_damaged": ["asteroid_damaged_particles"],
				"visuals_when_launched": ["ordinary_asteroid_following_particles", "ordinary_asteroid_following_particles_smoke"],
				"visuals_when_destroyed": ["asteroid_destroyed_particles", "asteroid_destroyed_ring"]
			},
			"base_spawn_delay": 1.2,
			"spawn_delay_daily_decline": 0.003,
			"spawn_delay_percent_variation": 25,
			"asteroids_initial_number": 11,
			"asteroids_number_daily_growth_rate": 3,
			"base_speed": 17.0,
			"base_speed_multipliers_thresholds": [1.1, 1.5],
			"speed_daily_growth_rate": 0.07,
			"asteroids_total": 0,
			"asteroids_left": 0,
			"asteroids_alive": 0,
			"asteroids_destroyed": 0,
			"asteroids_on_screen": 0,
			"spawn_delay": 0.0,
			"speed": 0.0,
		},
		
		"tiers": {
			1: {
				"modulation": Color(1, 1 ,1 ,1),
				"spawn_unlock_day": 0,
				"shield_unlock_day": 6,
				"shield_chance": 4,
				"spawn_chance_thresholds": [0, 0],
				"shield_chance_thresholds": [0, 0]
			},
			2: {
				"modulation": Color(0.7, 1.0, 0.7, 1.0),
				"spawn_unlock_day": 12,
				"shield_unlock_day": 16,
				"spawn_chance": 5,
				"shield_chance": 4,
				"spawn_chance_thresholds": [0, 0],
				"shield_chance_thresholds": [0, 0]
			},
			3: {
				"modulation": Color(0.5, 0.8, 1.0, 1.0),
				"spawn_unlock_day": 31,
				"shield_unlock_day": 36,
				"spawn_chance": 5,
				"shield_chance": 4,
				"spawn_chance_thresholds": [0, 0],
				"shield_chance_thresholds": [0, 0]
			},
			4: {
				"modulation": Color(1, 0.4, 0.6, 1.0),
				"spawn_unlock_day": 51,
				"shield_unlock_day": 56,
				"spawn_chance": 5,
				"shield_chance": 4,
				"spawn_chance_thresholds": [0, 0],
				"shield_chance_thresholds": [0, 0]
			},
			5: {
				"modulation": Color(1, 0.8, 0.4, 1.0),
				"spawn_unlock_day": 71,
				"shield_unlock_day": 76,
				"spawn_chance": 5,
				"shield_chance": 4,
				"spawn_chance_thresholds": [0, 0],
				"shield_chance_thresholds": [0, 0]
			}
		},

		"shields": {
			"audio_visual_effects": {
				"visuals_when_damaged": ["shield_damaged_particles"],
				"visuals_when_destroyed": ["shield_destroyed_particles"],
				"sound_when_damaged": {
					"name": "asteroid_shield_damaged",
					"volume_gain": 0.0,
					"pitch": 1.3,
					"pitch_percent_variation": 0.05
				},
				"sound_when_destroyed": {
					"name": "asteroid_shield_destroyed",
					"volume_gain": 0.5,
					"pitch": 1.1,
					"pitch_percent_variation": 0.05
				},
			}	
		},
		
		"common_asteroid": {
			"composition_color": Color(3, 1.5, 0),
			"audio_visual_effects": {
				"sound_when_destroyed": {
					"name": "asteroid_destroyed",
					"volume_gain": 0.0,
					"pitch": 1.0,
					"pitch_percent_variation": 0.03
				},
			},
			"is_regular": true,
			"spawn": {
				"unlock_day": 1,
				"chance_thresholds": [0, 0]
			},
		},
		
		"hyper_velocity_asteroid": {
			"composition_color": Color(4, 0.4, 0.4),
			"audio_visual_effects": {
				"sound_when_destroyed": {
					"name": "asteroid_destroyed",
					"volume_gain": 0.0,
					"pitch": 1.0,
					"pitch_percent_variation": 0.03
				},
			},
			"modules": {
				"acceleration": {"speed_per_second": 9.0}
			},
			"spawn": {
				"base_chance": 0.5,
				"daily_chance_growth_rate": 0.1,
				"unlock_day": 2,
				"chance_thresholds": [0, 0]
			},
			"is_regular": true,
			"additive_statistics": {}
		},
		
		"toxic_asteroid": {
			"composition_color": Color(0.2, 2, 0.2),
			"audio_visual_effects": {
				"sound_when_destroyed": {
					"name": "asteroid_destroyed",
					"volume_gain": 0.0,
					"pitch": 0.9,
					"pitch_percent_variation": 0.03
				},
				"visuals_when_launched": ["following_gas_particles"]
			},
			"explosion": {
				"shape": "round",
				"rise_and_decay_time": [0.35, 0.35],
				"alpha_channel": 0.8,
				"area_of_effect": 220.0,
				"damage": 30.0
			},
			"spawn": {
				"base_chance": 3.0,
				"daily_chance_growth_rate": 0.2,
				"unlock_day": 3,
				"chance_thresholds": [0, 0]
			},
			"is_regular": true,
			"additive_statistics": {}
		},
			
		"freezing_asteroid": {
			"composition_color": Color(0.4, 0.4, 2.7),
			"audio_visual_effects": {
				"sound_when_destroyed": {
					"name": "asteroid_destroyed",
					"volume_gain": 0.0,
					"pitch": 0.9,
					"pitch_percent_variation": 0.03
				},
				"visuals_when_launched": ["following_snow_particles"]
			},
			"explosion": {
				"rise_and_decay_time": [0.3, 10.0],
				"shape": "round",
				"alpha_channel": 0.2,
				"particles": "freezing",
				"area_of_effect": 280.0,
				"slow_by_asteroid_power": 0.2,
				"slow_by_asteroid_extra_power": 1
			},
			"spawn": {
				"base_chance": 3.0,
				"daily_chance_growth_rate": 0.03,
				"unlock_day": 4,
				"chance_thresholds": [0, 0]
			},
			"is_regular": true,
			"additive_statistics": {}
		},
			
		"splitting_asteroid": {
			"composition_color": Color(2, 2, 0),
			"audio_visual_effects": {
				"sound_when_destroyed": {
					"name": "asteroid_destroyed",
					"volume_gain": 0.0,
					"pitch": 1.0,
					"pitch_percent_variation": 0.03
				},
			},
			"modules": {
				"create_split_up_asteroids_when_destroyed": {"number": 7},
			},
			"spawn": {
				"base_chance": 3.0,
				"daily_chance_growth_rate": 0.06,
				"unlock_day": 6,
				"chance_thresholds": [0, 0]
			},
			"is_regular": true,
			"additive_statistics": {}
		},
			
		"split_up_asteroid": {
			"composition_color": Color(2, 2, 0),
			"audio_visual_effects": {
				"sound_when_destroyed": {
					"name": "asteroid_destroyed",
					"volume_gain": 0.0,
					"pitch": 1.3,
					"pitch_percent_variation": 0.05
				},
			},
			"modules": {
				"overbright_and_normalize_on_achieved_speed": {
					"initial_modulation": 10,
					"sprite_name_to_modulate": "Asteroid"
				},
				"deacceleration": {
					"speed_per_second": 30.0
				},
				"explode_on_achieved_speed": {
					"trigger_speed": 0.0
				}
			},
			"ghost": true,
			"explosion": {
				"rise_and_decay_time": [0.15, 0.15],
				"shape": "round",
				"alpha_channel": 0.8,
				"damage": 15,
				"area_of_effect": 70.0
			},
			"additive_statistics": {}
		},
			
		"shockwave_asteroid": {
			"composition_color": Color(0.0, 2.806, 1.625),
			"audio_visual_effects": {
				"sound_when_destroyed": {
					"name": "asteroid_destroyed",
					"volume_gain": 0.0,
					"pitch": 1.0,
					"pitch_percent_variation": 0.03
				},
				"visuals_when_launched": ["shockwave_asteroid_pulsing"]
			},
			"explosion": {
				"shape": "round",
				"rise_and_decay_time": [0.3, 0.3],
				"alpha_channel": 0.1,
				"area_of_effect": 320.0,
				"shockwave_force": 10
			},
			"spawn": {
				"base_chance": 1.5,
				"daily_chance_growth_rate": 0.05,
				"unlock_day": 7,
				"chance_thresholds": [0, 0]
			},
			"is_regular": true,
			"additive_statistics": {}
		},
			
		"electric_asteroid": {
			"composition_color": Color(1.023, 0.647, 1.573),
			"audio_visual_effects": {
				"sound_when_destroyed": {
					"name": "asteroid_destroyed",
					"volume_gain": 0.0,
					"pitch": 1.0,
					"pitch_percent_variation": 0.03
				},
			},
			"spawn": {
				"base_chance": 1.2,
				"daily_chance_growth_rate": 0.04,
				"unlock_day": 8,
				"chance_thresholds": [0, 0]
			},
			"modules": {
				"resource_credits_label": {},
				"electric_discharge": {
					"cooldown": 4,
					"damage": 15,
					"maximum_number_of_targets": 3,
					"range": 80
				},
			},
			"is_regular": true,
			"additive_statistics": {}
		},
			
		"plasma_asteroid": {
			"composition_color": Color(6, 0.6, 6),
			"audio_visual_effects": {
				"sound_when_destroyed": {
					"name": "plasma_asteroid_destroyed",
					"volume_gain": 0.0,
					"pitch": 1.0,
					"pitch_percent_variation": 0.03
				},
				"visuals_when_launched": ["plasma_asteroid_following_particles"]
			},
			"explosion": {
				"rise_and_decay_time": [0.40, 0.40],
				"shape": "cross",
				"alpha_channel": 0.9,
				"area_of_effect": 270.0,
				"damage": 45
			},
			"spawn": {
				"base_chance": 1.7,
				"daily_chance_growth_rate": 0.06,
				"unlock_day": 9,
				"chance_thresholds": [0, 0]
			},
			"is_regular": true,
			"additive_statistics": {}
		},
			
		"chromatic_asteroid": {
			"composition_color": Color(1.0, 1.0, 1.0),
			"audio_visual_effects": {
				"sound_when_destroyed": {
					"name": "asteroid_destroyed",
					"volume_gain": 0.0,
					"pitch": 1.0,
					"pitch_percent_variation": 0.03
				},
				"visuals_when_launched": ["ribbons_asteroid_following_particles"]
			},
			"explosion": {
				"transform_asteroids_to_parent_type": {},
				"rise_and_decay_time": [0.4, 0.4],
				"shape": "round",
				"alpha_channel": 0.1,
				"area_of_effect": 320.0,
			},
			"spawn": {
				"base_chance": 1.5,
				"daily_chance_growth_rate": 0.06,
				"unlock_day": 11,
				"chance_thresholds": [0, 0]
			},
			"modules": {
				"type_shifting": {"shift_duration": 0.5}
			},
			"is_regular": true,
			"additive_statistics": {}
		}
	}
}

var initial_data: Dictionary = {}
var current_data: Dictionary = {}

var sub_dicts_with_additive_stats: Array[Dictionary]

const message_senders: Dictionary = {
	"game": "Xanetti Corporation",
	"console": "Livrenn Group"
}

const regular_messages: Dictionary = {
	"game": {
		"day_1": {
			"start": {
				"part_1": "Welcome to the Oasis – the last remaining stronghold on Earth, sheltering around a thousand survivors of our species. Once a symbol of hope, it is no longer safe. Scientists have calculated with grim certainty: for the next 100 days, relentless waves of asteroids will rain down upon the planet, threatening to annihilate what little is left of humanity.",
				"part_2": "As our appointed commander, you carry the weight of survival on your shoulders. You will take charge of our defensive cannon, plan strategies, and make critical decisions to protect the Oasis from destruction. While you fight off the cosmic onslaught, a team of engineers and scientists will work tirelessly to prepare a rocket—a vessel that holds the fragile hope of escaping Earth and starting anew on Mars.",
				"part_3": "Time is not on our side. The fate of humanity rests in your hands. Can you hold the line long enough to ensure our future among the stars? The countdown begins now."
			},
			"end": {
				"part_1": "Well done Commander, thanks to you we've survived the first day of asteroids threats.\nBe advised: Along with our scientists and astereologists, we predict that each new day, a new type of asteroid will appear on the sky. We estimate there will be ten in total. Our data shows that each day, they’ll come slightly faster and bigger. We strongly advise you caution and proper preparation."
			}
		},
		"day_3": {
			"start": {
				"part_1": "Commander – great work! You've made it to Day 3. Your aim and decisions are impressive. But stay sharp – the asteroid threat is growing. Our systems have just detected incoming small asteroids in significant batches."
			}
		},
		"day_5": {
			"start": {
				"part_1": "Commander, this day is extraordinary. A wave of massive asteroids is on a collision course with the base. Their size make them especially dangerous. This will be a true test of your defenses and precision. Prepare your weapon systems and hold the line — the humanity survival depends on you."
			},
			"end": {
				"part_1": "This is insane! We have detected a surge of power within the defensive infrastructure. We don't know how to explain it, but apparently God sees your efforts and decided to support you!\nBy the way – you managed to deal with those massive asteroids that posed a huge threat to our base and future. Glory to you, Commander. We are very grateful for your commitment."
			}
		},
		"day_6": {
			"start": {
				"part_1": "Commander be advised, we have a new observation. Before asteroids appear in the sky, they occasionally collide with one another. These impacts cause them to shed dust, which then condenses into a protective shield forming at the asteroid’s core. Apparently, this will make destroying them more challenging."
			}
		},
		"day_8": {
			"start": {
				"part_1": "Commander, be advised as danger raises. Our radars have detected a huge number of incoming hypervelocity asteroid waves. According to the data, their frequencies and numbers will increase over time. We estimate that waves will appear on the sky everyday. Stay cautious."
			}
		},
		"day_9": {
			"start": {
				"part_1": "Our systems have detected incoming huge asteroids. Fortunately they move singularly. To help you prepare, we will emit warning sound before they arrive."
			}
		},
		"day_15": {
			"start": {
				"part_1": "It's another day when we expect unusual wave of asteroids. This time they are only explosive, what makes them easier to destroy but in the same time it's huge threat to the infrastructure. Good luck Commander!"
			}
		}
	},
	
	"console": {
		"day_2": {
			"part_1": "Commander, welcome to the Upgrade Console. This is a special place where all your upgrades will take shape. Plan your choices carefully — some decisions are difficult, or even impossible, to reverse. Take your time and choose wisely.",
			"part_2": "Please note that upgrade trees and specialization network function through highly advanced computational structures, loosely inspired by the architecture of the human brain. These networks require immense energy input and a precise balance of various calculating components to operate. Because of this complexity, altering the configuration is no trivial task—it demands a substantial amount of Resource Credits, Nano Cores and Asteroid Shards to initiate and stabilize any changes.",
			"part_3": "When it comes to resources, this is a short overview of them:\n\nResource Credits – a reward for destryoing asteroids provided by the Xanetti Corporation, which hired you. Used to improve the cannon and base infrastructure.",
			"part_4": "Asteroid Shards - There’s a small chance they’ll drop from destroyed asteroids. Used to manipulate the properties and behavior of asteroids. \n\nNano Cores - Our scientists work tirelessly in laboratories to produce them. Since the process is slow and complex, you'll receive only one Nano Core at the end of each day. Used to implement and enhance cannon abilities."
		},
		"day_5": {
			"part_1": "Commander, you’re no longer a newcomer — you’ve become a seasoned practitioner. You’ve proven your worth and successfully defended the base from destruction. This is a moment to celebrate. From now on, you have the opportunity to choose a specialisation and become even more effective. Take your time — each specialisation is unique and has its own benefits. Click the glowing circle in the upgrade menu to explore the available options."
		},
		"day_6": {
			"part_1": "Dear Commander, Xanetti Corporation just informed us that power raised in base and it looks like this is a kind of permanent upgrade to your infrastructure. We have upgraded the Console and added a new tab. Thanks to this you will be able to have an eye on so called God's blessings."
		},
		"day_12": {
			"part_1": "We have collected all available data regarding asteroids and closely examined behavior of their types. We have also deployed powerful sonds across vast universe distances that detected incoming new tiers from other galaxies.",
			"part_2": "We expect these intergalactic asteroids to have far greater durability than common ones: they will be harder to destroy but their shards will be much more potent.",
			"part_3": "Using the collected data, we designed an effective Asteroid Tree to manipulate both the appearance of asteroids in the sky and also their behavior. We believe that this will help you to plan new strategies and bring your commandement skills to higher level."
		}
	}
}

const irregular_messages: Dictionary = {
	"gods_eyes_appearance": {
		"part_1": "Wait! What is this?? Commander, do you see this? This world is extraordinary. We are regularly encountering asteroids, UFOs and they are serious threat to the humanity, but we see these eyes for the first time and we have no idea what is going to happen!",
		"part_2": "This encounter is improbable and unpredictable. It looks like real entity of God is looking directly on us."
	}
}





func _ready() -> void:
	load_settings()
	
func load_settings() -> void:
	if FileAccess.file_exists(get_save_path("config")):
		var file = FileAccess.open(GlobalScript.get_save_path("config"), FileAccess.READ)
		settings = file.get_var()
		file.close()
	else:
		save_settings()
		
func save_settings() -> void:
	var file = FileAccess.open(GlobalScript.get_save_path("config"), FileAccess.WRITE)
	file.store_var(settings)
	file.close()

func load_scene(scene_to_load: String):
	AudioBus.stop_all()
	change_cursor("default")
	var scene_path: String
	match scene_to_load:
		"menu": scene_path = "main_menu/menu.tscn"
		"console": scene_path = "res://upgrade_console/upgrade_console.tscn"
		"game": scene_path = "res://game.tscn"
	if previous_scene == scene_to_load or scene_to_load == "menu":
		# Szybkie ładowanie z praktycznie zerowym czasem oczekiwania
		get_tree().change_scene_to_file(scene_path)
	else:
		var loading_screen = load("res://loading_screen.tscn").instantiate()
		loading_screen.scene_to_load = scene_path
		get_tree().root.add_child(loading_screen)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = loading_screen 
	previous_scene = scene_to_load

func change_cursor(cursor: String) -> void:
	if cursor == "default": Input.set_custom_mouse_cursor(DEFAULT_CURSOR, Input.CURSOR_ARROW, Vector2(20,20))
	elif cursor == "reload": Input.set_custom_mouse_cursor(RELOAD_CURSOR, Input.CURSOR_ARROW, Vector2(20,20))

func init() -> void:
	set_asteroid_type_spawn_chance_thresholds()
	set_asteroid_tiers_chance_thresholds()
	set_asteroid_shield_chance_thresholds()
	set_general_asteroids_data()
	sub_dicts_with_additive_stats = get_sub_dicts_with_additive_stats()
	include_additive_stats(false, "all")
	clear_and_set_new_fever_bonuses_and_requirement()
	clear_and_set_new_structure_bonuses()
	include_additive_stats(true, "tree_upgrades")
	include_additive_stats(true, "specialisation")
	include_additive_stats(true, "structures")
	include_additive_stats(true, "blessings")

func prepare_for_new_game() -> void:
	# Jeśli w tej samej sesji powstałoby kilka nowych zapisów to wszystkie działałyby na już zmodyfikowanym initial_data, dlatego \/
	initial_data = {}
	initial_data = legacy_data.duplicate(true)
	for structure_type in initial_data.structures:
		match structure_type:
			"laser_turret":
				for structure in ["left_laser_turret", "right_laser_turret"]:
					initial_data.structures[structure] = initial_data.structures.laser_turret.duplicate(true)
			"pulse_barrier":
				for structure in ["left_pulse_barrier", "right_pulse_barrier"]:
					initial_data.structures[structure] = initial_data.structures.pulse_barrier.duplicate(true)
			"common_structure":
				for structure in COMMON_STRUCTURE_DICTIONARY_RECEIVERS:
					initial_data.structures[structure] = initial_data.structures.common_structure.duplicate(true)
					for extra_dictionary in COMMON_STRUCTURE_DICTIONARY_RECEIVERS[structure]["extra_dictionaries"]:
						initial_data["structures"][structure][extra_dictionary] = {}
						initial_data["structures"][structure][extra_dictionary].merge(EXTRA_STRUCTURE_DICTIONARIES[extra_dictionary])
						if extra_dictionary == "bonuses_for_other_objects": 
							initial_data["structures"][structure][extra_dictionary].merge(COMMON_STRUCTURE_DICTIONARY_RECEIVERS[structure]["extra_dictionaries"]["bonuses_for_other_objects"])
							# -> initial_data["structures"][structure][extra_dictionary]["total"] = initial_data["structures"][structure][extra_dictionary]["base"]
	initial_data.structures.erase("pulse_barrier")
	initial_data.structures.erase("laser_turret")
	initial_data.structures.erase("common_structure")
	set_values_according_to_difficulty()
	current_data = initial_data.duplicate(true)
	current_data.game.save_creation_date = get_current_date()
	current_data.game.difficulty = initial_config.game_difficulty
	prepare_next_blessings_config()

func prepare_next_blessings_config() -> void:
	current_data.next_blessings_config.cloud_2.bonus_receiver = "cannon"
	for i in range (1, 3):
		var structure: String
		var cloud_number: String
		if randi_range(1, 2) == 1:
			structure = "laser_turret"
		else: 
			structure = "pulse_barrier"
		if i == 1:
			cloud_number = "1"
			structure = "left_" + structure
		else:
			cloud_number = "3"
			structure = "right_" + structure
		current_data.next_blessings_config["cloud_" + cloud_number].bonus_receiver = structure
		
	for cloud in current_data.next_blessings_config:
		var data_sub_dict: String
		if current_data.next_blessings_config[cloud].bonus_receiver.contains("laser"): data_sub_dict = "laser_turret"
		elif current_data.next_blessings_config[cloud].bonus_receiver.contains("barrier"): data_sub_dict = "pulse_barrier"
		else: data_sub_dict = "cannon"
		var statistics: Array[Array]
		for element in GlobalScript.BLESSING_BONUSES[data_sub_dict]:
			if GlobalScript.BLESSING_BONUSES[data_sub_dict][element] is Dictionary:
				for second_element in GlobalScript.BLESSING_BONUSES[data_sub_dict][element]:
					var new_array: Array[String] = [element, second_element]
					statistics.append(new_array)
			else: 
				var new_array: Array[String] = [element]
				statistics.append(new_array)
		current_data.next_blessings_config[cloud].statistic_structure = []
		current_data.next_blessings_config[cloud].statistic_structure = statistics.pick_random().duplicate(true)
		var blessing_percent: float = get_value_from_dict(current_data.next_blessings_config[cloud].statistic_structure, GlobalScript.BLESSING_BONUSES[data_sub_dict])
		var initial_stat_value = get_value_from_dict(current_data.next_blessings_config[cloud].statistic_structure, get_data_source_dictionary(current_data.next_blessings_config[cloud].bonus_receiver, "initial"))
		var bonus_value: Variant
		if initial_stat_value is Array:
			bonus_value = [0.0, 0.0]
			bonus_value[0] = initial_stat_value[0] * blessing_percent
			bonus_value[1] = initial_stat_value[1] * blessing_percent
		else:
			bonus_value = 0.0
			bonus_value = initial_stat_value * blessing_percent
		current_data.next_blessings_config[cloud].statistic_value = bonus_value
		
func set_values_according_to_difficulty() -> void:
	var durability_points_multiplier: float
	
	if initial_config.game_difficulty == "easy":
		initial_data.rewards.regular_asteroid = 8
		initial_data.asteroids.general.base_speed += 0.0
		durability_points_multiplier = 1.0
	elif initial_config.game_difficulty == "medium":
		initial_data.asteroids.general.base_speed += 1.0
		initial_data.rewards.regular_asteroid = 7
		durability_points_multiplier = 0.8
	elif initial_config.game_difficulty == "hard":
		initial_data.asteroids.general.base_speed += 1.5
		initial_data.rewards.regular_asteroid = 6
		durability_points_multiplier = 0.6
	elif initial_config.game_difficulty == "hardcore":
		initial_data.asteroids.general.base_speed += 2.0
		initial_data.rewards.regular_asteroid = 5
		durability_points_multiplier = 0.4
		
	for structure in initial_data.structures:
		if initial_data.structures[structure].has("durability"):
			initial_data["structures"][structure]["durability"]["max_points"] = int(initial_data["structures"][structure]["durability"]["max_points"] * durability_points_multiplier)
			initial_data["structures"][structure]["durability"]["current_points"] = initial_data["structures"][structure]["durability"]["max_points"]
	
func set_asteroid_type_spawn_chance_thresholds() -> void:
	var last_upper_threshold: int = 0
	var lower_threshold: int
	for asteroid in current_data.asteroids:
		if current_data["asteroids"][asteroid].has("spawn") and asteroid != "common_asteroid":
			if current_data["asteroids"][asteroid]["spawn"]["unlock_day"] <= current_data.game.day:
				lower_threshold = last_upper_threshold + 1
				last_upper_threshold = lower_threshold + ((current_data["asteroids"][asteroid]["spawn"]["base_chance"] + (current_data["asteroids"][asteroid]["spawn"]["daily_chance_growth_rate"] * current_data.game.day)) * 100)
				current_data["asteroids"][asteroid]["spawn"]["chance_thresholds"] = [lower_threshold, last_upper_threshold]
			else: current_data["asteroids"][asteroid]["spawn"]["chance_thresholds"] = [0, 0]
	current_data["asteroids"]["common_asteroid"]["spawn"]["chance_thresholds"] = [last_upper_threshold + 1, 10000]
	
func set_asteroid_tiers_chance_thresholds() -> void:
	var last_upper_threshold: int = 0
	var lower_threshold: int
	for tier in range (2, 6):
		if current_data["asteroids"]["tiers"][tier]["spawn_unlock_day"] <= current_data.game.day:
			lower_threshold = last_upper_threshold + 1
			last_upper_threshold = lower_threshold + (current_data["asteroids"]["tiers"][tier]["spawn_chance"] * 100)
			current_data["asteroids"]["tiers"][tier]["spawn_chance_thresholds"] = [lower_threshold, last_upper_threshold]
		else:
			current_data["asteroids"]["tiers"][tier]["spawn_chance_thresholds"] = [0, 0]
	current_data["asteroids"]["tiers"][1]["spawn_chance_thresholds"] = [last_upper_threshold + 1, 10000]

func set_asteroid_shield_chance_thresholds() -> void:
	var last_upper_threshold: int = 0
	var lower_threshold: int
	for tier in range (1, 6):
		if current_data["asteroids"]["tiers"][tier]["shield_unlock_day"] <= current_data.game.day:
			lower_threshold = last_upper_threshold + 1
			last_upper_threshold = lower_threshold + (current_data["asteroids"]["tiers"][tier]["shield_chance"] * 100)
			current_data["asteroids"]["tiers"][tier]["shield_chance_thresholds"] = [lower_threshold, last_upper_threshold]
		else:
			current_data["asteroids"]["tiers"][tier]["shield_chance_thresholds"] = [0, 0]
	
func set_general_asteroids_data() -> void:
	current_data.asteroids.general.spawn_delay = current_data.asteroids.general.base_spawn_delay - (current_data.game.day * current_data.asteroids.general.spawn_delay_daily_decline)
	current_data.asteroids.general.speed = current_data.asteroids.general.base_speed + (current_data.game.day * current_data.asteroids.general.speed_daily_growth_rate)
	current_data.asteroids.general.asteroids_total = current_data.asteroids.general.asteroids_initial_number + (current_data.game.day * current_data.asteroids.general.asteroids_number_daily_growth_rate)
	current_data.asteroids.general.asteroids_left = current_data.asteroids.general.asteroids_total
	# gdy gra zapisza sie w dowolonym momencie to alive sie zbuguje dlatego zawsze reset
	current_data.asteroids.general.asteroids_alive = 0
	
func clear_and_set_new_specialisation_bonuses() -> void:
	erase_additive_stats("specialisation")
	var current_data_dict: Dictionary
	var initial_data_dict: Dictionary
	match current_data.game.player_specialisation:
		"pyrotechnist":
			for receiver in ["cannon", "plasma_barrage", "orbital_strike", "gravity_well"]:
				current_data_dict = get_data_source_dictionary(receiver, "current")
				initial_data_dict = get_data_source_dictionary(receiver, "initial")
				current_data_dict.additive_statistics.specialisation = {}
				current_data_dict.additive_statistics.specialisation.explosion = {}
				current_data_dict.additive_statistics.specialisation.explosion.area_of_effect = initial_data_dict.explosion.area_of_effect * SPECIALISATION_BONUSES.pyrotechnist.area_of_effect_of_basic_attack_and_abilities
				if receiver != "gravity_well": current_data_dict.additive_statistics.specialisation.explosion.damage = initial_data_dict.explosion.damage * SPECIALISATION_BONUSES.pyrotechnist.damage_of_basic_attack_and_abilities
		"engineer":
			current_data.structures.cannon.additive_statistics.specialisation = {}
			current_data.structures.cannon.additive_statistics.specialisation.reload_time = initial_data.structures.cannon.reload_time * SPECIALISATION_BONUSES.engineer.reload_time
			current_data.structures.cannon.additive_statistics.specialisation.capacity = initial_data.structures.cannon.capacity * SPECIALISATION_BONUSES.engineer.capacity
		"gunslinger":
			current_data.structures.cannon.additive_statistics.specialisation = {}
			current_data.structures.cannon.additive_statistics.specialisation.attack_speed = initial_data.structures.cannon.attack_speed * SPECIALISATION_BONUSES.gunslinger.attack_speed
			current_data.structures.cannon.additive_statistics.specialisation.projectile_speed = initial_data.structures.cannon.projectile_speed * SPECIALISATION_BONUSES.gunslinger.projectile_speed
		"strategist":
			var receivers: Array[String] = ["fever", "gravity_well", "stasis_field"]
			for buff in current_data.buffs: receivers.append(buff)
			for receiver in receivers:
				current_data_dict = get_data_source_dictionary(receiver, "current")
				initial_data_dict = get_data_source_dictionary(receiver, "initial")
				current_data_dict.additive_statistics.specialisation = {}
				if receiver == "gravity_well":
					current_data_dict.additive_statistics.specialisation.explosion = {}
					current_data_dict.additive_statistics.specialisation.explosion.duration = initial_data_dict.explosion.duration * SPECIALISATION_BONUSES.strategist.abilities_buffs_and_fever_duration
				else:
					current_data_dict.additive_statistics.specialisation.duration = initial_data_dict.duration * SPECIALISATION_BONUSES.strategist.abilities_buffs_and_fever_duration
			for ability in current_data.abilities:
				if !current_data.abilities[ability].additive_statistics.has("specialisation"): current_data.abilities[ability].additive_statistics.specialisation = {}
				current_data.abilities[ability].additive_statistics.specialisation.cooldown = initial_data.abilities[ability].cooldown * SPECIALISATION_BONUSES.strategist.ability_cooldowns
		"executor":
			current_data.structures.cannon.additive_statistics.specialisation = {}
			current_data.structures.cannon.additive_statistics.specialisation.explosion = {}
			current_data.structures.cannon.additive_statistics.specialisation.explosion.critical_hit_chance = initial_data.structures.cannon.explosion.critical_hit_chance * SPECIALISATION_BONUSES.executor.critical_hit_chance
			current_data.structures.cannon.additive_statistics.specialisation.explosion.critical_hit_damage_thresholds = [0.0, 0.0]
			current_data.structures.cannon.additive_statistics.specialisation.explosion.critical_hit_damage_thresholds[0] = initial_data.structures.cannon.explosion.critical_hit_damage_thresholds[0] * SPECIALISATION_BONUSES.executor.critical_hit_damage
			current_data.structures.cannon.additive_statistics.specialisation.explosion.critical_hit_damage_thresholds[1] = initial_data.structures.cannon.explosion.critical_hit_damage_thresholds[1] * SPECIALISATION_BONUSES.executor.critical_hit_damage
		"sentinel":
			var receivers: Array[String] = ["left_laser_turret", "right_laser_turret", "left_pulse_barrier", "right_pulse_barrier"]
			for receiver in receivers:
				current_data_dict = get_data_source_dictionary(receiver, "current")
				initial_data_dict = get_data_source_dictionary(receiver, "initial")
				current_data_dict.additive_statistics.specialisation = {}
				current_data_dict.additive_statistics.specialisation.attack_speed = initial_data_dict.attack_speed * SPECIALISATION_BONUSES.sentinel.all_lasers_and_barriers_values
				current_data_dict.additive_statistics.specialisation.attack_range = initial_data_dict.attack_range * SPECIALISATION_BONUSES.sentinel.all_lasers_and_barriers_values
				current_data_dict.additive_statistics.specialisation.damage = initial_data_dict.damage * SPECIALISATION_BONUSES.sentinel.all_lasers_and_barriers_values
		"collectioner":
			current_data.resources.additive_statistics.specialisation = {}
			current_data.resources.additive_statistics.specialisation.shard_drop_chance = initial_data.resources.shard_drop_chance * SPECIALISATION_BONUSES.collectioner.shards_drop_chance
	
func clear_and_set_new_structure_bonuses() -> void:
	erase_additive_stats("structures")
	for structure in current_data.structures:
		if current_data.structures[structure].has("bonuses_for_other_objects") and current_data.structures[structure].active:
			current_data.structures[structure]["bonuses_for_other_objects"]["base_bonus"] = current_data.structures[structure]["bonuses_for_other_objects"]["growth_rate"] * current_data.structures[structure]["bonuses_for_other_objects"]["base_growth_rate_multiplier"]
			var growth_rate_multiplier: int = current_data.structures[structure].active_days
			if current_data.structures[structure].active_days > current_data.structures[structure]["bonuses_for_other_objects"]["max_growth_rate_multiplier"]: growth_rate_multiplier = current_data.structures[structure]["bonuses_for_other_objects"]["max_growth_rate_multiplier"]
			current_data.structures[structure]["bonuses_for_other_objects"]["total_growth_rate_multiplier"] = current_data.structures[structure]["bonuses_for_other_objects"]["base_growth_rate_multiplier"] + growth_rate_multiplier
			current_data.structures[structure]["bonuses_for_other_objects"]["growth_rate_bonus"] = current_data.structures[structure]["bonuses_for_other_objects"]["growth_rate"] * growth_rate_multiplier
			current_data.structures[structure]["bonuses_for_other_objects"]["total_bonus"] = current_data.structures[structure]["bonuses_for_other_objects"]["base_bonus"] + current_data.structures[structure]["bonuses_for_other_objects"]["growth_rate_bonus"]
			for receiver in current_data.structures[structure]["bonuses_for_other_objects"]["receivers"]:
				var receiver_current_data: Dictionary = get_data_source_dictionary(receiver, "current")
				var receiver_initial_data: Dictionary = get_data_source_dictionary(receiver, "initial")
				if !receiver_current_data.additive_statistics.has("structures"):
					receiver_current_data.additive_statistics.structures = {}
				for stat_array in current_data.structures[structure]["bonuses_for_other_objects"]["statistic_structures"]:
					var stat_to_add: Variant = get_value_from_dict(stat_array, receiver_initial_data)
					if stat_to_add is Array:
						stat_to_add[0] *= current_data.structures[structure]["bonuses_for_other_objects"]["total_bonus"] / 100.0
						stat_to_add[1] *= current_data.structures[structure]["bonuses_for_other_objects"]["total_bonus"] / 100.0
					else:
						stat_to_add *= current_data.structures[structure]["bonuses_for_other_objects"]["total_bonus"] / 100.0
					add_stat_to_object(true, stat_to_add, stat_array, receiver_current_data["additive_statistics"]["structures"])

func clear_and_set_new_fever_bonuses_and_requirement() -> void:
	var data_adjust_occurences: int = floor(current_data.game.day / current_data.fever.data_adjust_days_interval)
	var current_percent_bonus: int = current_data.fever.initial_percent_bonus + (current_data.fever.bonus_percent_increase_rate * data_adjust_occurences)
	current_data.fever.current_percent_bonus = current_percent_bonus
	current_data.structures.cannon.additive_statistics.fever = {}
	current_data.structures.left_laser_turret.additive_statistics.fever = {}
	current_data.structures.right_laser_turret.additive_statistics.fever = {}
	current_data.structures.left_pulse_barrier.additive_statistics.fever = {}
	current_data.structures.right_pulse_barrier.additive_statistics.fever = {}
	current_data.structures.cannon.additive_statistics.fever = {}
	current_data.structures.cannon.additive_statistics.fever.attack_speed = initial_data.structures.cannon.attack_speed * (current_percent_bonus / 100.0)
	current_data.structures.cannon.additive_statistics.fever.projectile_speed = initial_data.structures.cannon.projectile_speed * (current_percent_bonus / 100.0)
	current_data.structures.cannon.additive_statistics.fever.reload_time = initial_data.structures.cannon.reload_time * (current_percent_bonus / 100.0)
	current_data.structures.left_laser_turret.additive_statistics.fever.attack_speed = initial_data.structures.left_laser_turret.attack_speed * (current_percent_bonus / 100.0)
	current_data.structures.right_laser_turret.additive_statistics.fever.attack_speed = initial_data.structures.right_laser_turret.attack_speed * (current_percent_bonus / 100.0)
	current_data.structures.left_pulse_barrier.additive_statistics.fever.attack_speed = initial_data.structures.left_pulse_barrier.attack_speed * (current_percent_bonus / 100.0)
	current_data.structures.right_pulse_barrier.additive_statistics.fever.attack_speed = initial_data.structures.right_pulse_barrier.attack_speed * (current_percent_bonus / 100.0)
	var current_damage_requirement: int = current_data.fever.initial_damage_requirement
	for i in range (1, data_adjust_occurences + 1): 
		current_damage_requirement += int((current_data.fever.damage_percent_increase_rate / 100.0) * current_damage_requirement)
	current_data.fever.current_damage_requirement = current_damage_requirement

func get_composition_color(data_dict: Dictionary) -> Color:
	var composition_color: Color
	if current_data.fever.enabled and data_dict.has("fever_composition_color"): composition_color = data_dict.fever_composition_color
	else: composition_color = data_dict.composition_color
	return composition_color

func get_save_path(type: String) -> String:
	var path_to_return: String
	if type == "game": path_to_return = initial_config.save_path + "_" + str(initial_config.save_slot) + ".save"
	elif type == "config": path_to_return = initial_config.config_path + ".save"
	return path_to_return

func get_current_date():
	var current_date = Time.get_date_dict_from_system()
	return str(current_date.day) + "-" + str(current_date.month) + "-" + str(current_date.year)

func get_data_source_dictionary(data_source: String, data_dict_to_check: String) -> Dictionary:
	# glebokosc maks 2 np structures -> cannon
	var data_dict: Dictionary
	if data_dict_to_check == "current": data_dict = current_data
	elif data_dict_to_check == "initial": data_dict = initial_data
	var dict_to_return: Dictionary
	if data_dict.has(data_source): dict_to_return = data_dict[data_source]
	else: 
		for sub_dict in data_dict:
			if data_dict[sub_dict].has(data_source):
				dict_to_return = data_dict[sub_dict][data_source]
				break
	return dict_to_return

func get_value_from_dict(stat_array: Array, dict_to_use: Dictionary) -> Variant:
	var value_to_return: Variant
	if stat_array.size() == 1: 
		value_to_return = dict_to_use[stat_array[0]]
	else:
		for i in range(0, stat_array.size()):
			if dict_to_use[stat_array[i]] is Dictionary:
				dict_to_use = dict_to_use[stat_array[i]]
		value_to_return = dict_to_use[stat_array[stat_array.size() - 1]]
	# podanie array z dict to referencja dlatego \/
	if value_to_return is Array: 
		return value_to_return.duplicate(true)
	else:
		return value_to_return

func get_statistic_verb(stat: String) -> String:
	var verb_to_return: String = "Increases"
	if stat in ["cooldown", "reload_time"]: verb_to_return = "Decreases"
	return verb_to_return

func get_sub_dicts_with_additive_stats() -> Array[Dictionary]:
	# głebokość 1 np game, rewards / głębokość 2 jeśli 1 pełni funkcję grupy
	var array_to_return: Array[Dictionary]
	for dict in current_data:
		var current_depth: Dictionary = current_data[dict]
		if current_depth.has("additive_statistics"):
			array_to_return.append(current_depth)
		else:
			for sub_dict in current_depth:
				if current_depth[sub_dict] is Dictionary:
					if current_depth[sub_dict].has("additive_statistics"):
						array_to_return.append(current_depth[sub_dict])
	return array_to_return

func add_stat_to_object(add: bool, stat_value: Variant, stat_structure: Array, data_dict: Dictionary) -> void:
	var stat_to_add: Variant
	if stat_value is Array:
		stat_to_add = stat_value.duplicate(true)
	else:
		stat_to_add = stat_value
		
	var statistics_summed_inversely: Array[String] = ["reload_time", "cooldown"]
	if stat_to_add is not bool:
		if add:
			if stat_structure[stat_structure.size() - 1] in statistics_summed_inversely and stat_to_add >= 0.0: stat_to_add *= -1.0
		else:
			if stat_to_add is Array:
				stat_to_add[0] *= -1.0
				stat_to_add[1] *= -1.0
			else:
				if !stat_structure[stat_structure.size() - 1] in statistics_summed_inversely or stat_to_add <= 0.0: stat_to_add *= -1.0
			
	for i in range(0, stat_structure.size()):
		if i != stat_structure.size() - 1:
			if !data_dict.has(stat_structure[i]):
				data_dict[stat_structure[i]] = {}
			data_dict = data_dict[stat_structure[i]]
		else:
			if stat_to_add is Array:
				if !data_dict.has(stat_structure[i]): data_dict[stat_structure[i]] = [0.0, 0.0]
				data_dict[stat_structure[i]][0] += stat_to_add[0]
				data_dict[stat_structure[i]][1] += stat_to_add[1]
			elif stat_to_add is bool:
				data_dict[stat_structure[i]] = stat_to_add
			else:
				if !data_dict.has(stat_structure[i]): data_dict[stat_structure[i]] = 0.0
				data_dict[stat_structure[i]] += stat_to_add

func add_additive_stats(add: bool, category: String) -> void:
	for dict in sub_dicts_with_additive_stats:
		if dict["additive_statistics"].has(category):
			for first_category_element in dict.additive_statistics[category]:
				var current_depth: Dictionary = dict.additive_statistics[category]
				if current_depth[first_category_element] is Dictionary:
					current_depth = current_depth[first_category_element]
					for second_category_element in current_depth:
						add_stat_to_object(add, current_depth[second_category_element], [first_category_element, second_category_element], dict)
				else:
					add_stat_to_object(add, current_depth[first_category_element], [first_category_element], dict)
					
func include_additive_stats(include: bool, scope: String) -> void:
	var categories: Array[String]
	if scope == "all":
		for category in ["tree_upgrades", "blessings", "offerings", "structures", "fever", "buffs", "specialisation"]:
			categories.append(category)
	else:
		categories.append(scope)
		
	for category in categories:
		if include:
			if category not in current_data.game.included_additive_stats: 
				current_data.game.included_additive_stats.append(category)
				add_additive_stats(true, category)
		else:
			if category in current_data.game.included_additive_stats:
				current_data.game.included_additive_stats.erase(category)
				add_additive_stats(false, category)
			
func erase_additive_stats(group: String) -> void:
	for dict in sub_dicts_with_additive_stats:
		if dict["additive_statistics"].has(group): dict["additive_statistics"].erase(group)

func get_message_box(send_from: String, message_source: Dictionary) -> Control:
	var new_message_box: Control = MESSAGE_BOX.instantiate()
	new_message_box.message_source = message_source
	new_message_box.sender = message_senders[send_from]
	new_message_box.place = get_place(send_from)
	return new_message_box
	
func get_place(send_from: String) -> String:
	var string_to_return: String
	match send_from:
		"console": 
			string_to_return = "Upgrade Console"
		"game":
			if GlobalScript.current_data.game.day < 11: string_to_return = "Power Plant"
	string_to_return = PLANET_NAME + ": " + string_to_return
	return string_to_return
