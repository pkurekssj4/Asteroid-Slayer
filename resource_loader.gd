extends Node
const PRELOADED_RESOURCES: Dictionary = {
	"asteroid_1": preload("res://asteroids/asteroid1.tscn"),
	"asteroid_2": preload("res://asteroids/asteroid2.tscn"),
	"asteroid_3": preload("res://asteroids/asteroid3.tscn"),
	"asteroid_4": preload("res://asteroids/asteroid4.tscn"),
	"asteroid_5": preload("res://asteroids/asteroid5.tscn"),
	"asteroid_6": preload("res://asteroids/asteroid6.tscn"),
	"asteroid_7": preload("res://asteroids/asteroid7.tscn"),
	"asteroid_8": preload("res://asteroids/asteroid8.tscn"),
	"asteroid_9": preload("res://asteroids/asteroid9.tscn"),
	"asteroid_10": preload("res://asteroids/asteroid10.tscn"),
	"asteroid_11": preload("res://asteroids/asteroid11.tscn"),
	"asteroid_12": preload("res://asteroids/asteroid12.tscn"),
	"asteroid_13": preload("res://asteroids/asteroid13.tscn"),
	"asteroid_14": preload("res://asteroids/asteroid14.tscn"),
	"asteroid_15": preload("res://asteroids/asteroid15.tscn"),
	"asteroid_shield": preload("res://asteroids/asteroid_shield.tscn"),
	"round_explosion": preload("res://cannon/round_explosion.tscn"),
	"cross_explosion": preload("res://asteroids/cross_explosion.tscn"),
	"ordinary_projectile_explosion_particles": preload("res://ordinary_projectile_explosion_particles.tscn"),
	"orbital_strike_projectile_explosion_particles": preload("res://cannon/orbital_strike_projectile_explosion_particles.tscn"),
	"orbital_strike_projectile_following_particles": preload("res://cannon/orbital_strike_projectile_following_particles.tscn"),
	"projectile": preload("res://cannon/projectile.tscn"),
	"muzzle_flash": preload("res://cannon/muzzle_flash.tscn"),
	"muzzle_flash_particles": preload("res://cannon/muzzle_flash_particles.tscn"),
	"asteroid_damaged_particles": preload("res://asteroids/asteroid_damaged_particles.tscn"),
	"asteroid_destroyed_particles": preload("res://asteroids/asteroid_destroyed_particles.tscn"),
	"ordinary_asteroid_following_particles": preload("res://ordinary_asteroid_following_particles.tscn"),
	"ordinary_asteroid_following_particles_smoke": preload("res://ordinary_asteroid_following_particles_smoke.tscn"),
	"ribbons_asteroid_following_particles": preload("res://ribbons_asteroid_following_particles.tscn"),
	"shockwave_asteroid_pulsing": preload("res://shockwave_asteroid_pulsing.tscn"),
	"following_gas_particles": preload("res://following_gas_particles.tscn"),
	"following_snow_particles": preload("res://following_snow_particles.tscn"),
	"plasma_asteroid_following_particles": preload("res://plasma_asteroid_following_particles.tscn"),
	"gravity_well_rings": preload("res://gravity_well_rings.tscn"),
	"gravity_well_particles": preload("res://gravity_well_particles.tscn"),
	"gravity_well_projectile_following_particles": preload("res://cannon/gravity_well_projectile_following_particles.tscn"),
	"asteroid_destroyed_ring": preload("res://asteroid_destroyed_ring.tscn"),
	"structure_damaged_smoke_particles": preload("res://structure_damaged_smoke_particles.tscn"),
	"structure_destroyed_fire_particles": preload("res://structure_destroyed_fire_particles.tscn"),
	"structure_destroyed_explosion_particles": preload("res://structure_destroyed_explosion_particles.tscn"),
	"shield_damaged_particles": preload("res://asteroids/shield_damaged_particles.tscn"),
	"shield_destroyed_particles": preload("res://asteroids/shield_destroyed_particles.tscn"),
	"resource_credit_icon": preload("res://resource_icons/resource_credit.png")
}

const PRELOADED_SHADERS: Dictionary[String, Shader] = {
	"asteroid_flashing": preload("res://shaders/asteroid_flashing.gdshader"),
	"gravity_well_waving": preload("res://shaders/gravity_well_waving.gdshader"),
	"ending_text_waving": preload("res://shaders/ending_text_waving.gdshader"),
	"fever_progress_bar": preload("res://shaders/fever_progress_bar.gdshader")
}

const PRELOADED_SCRIPTS: Dictionary[String, Script] = {
	"electric_discharge_visual_effect": preload("res://modules/electric_discharge_visual_effect.gd"),
	"laser_turrets_ray_caster": preload("res://laser_turret/ray_caster.gd"),
	"pulse_barriers_shockwave": preload("res://pulse_barrier/shockwave.gd"),
	"small_text_event": preload("res://small_text_event.gd")
}

func get_resource(scene_name: String) -> Variant:
	return PRELOADED_RESOURCES[scene_name]
	
func get_shader(shader_name: String) -> Shader:
	return PRELOADED_SHADERS[shader_name]

func get_scriptt(script_name: String) -> Script:
	return PRELOADED_SCRIPTS[script_name]
