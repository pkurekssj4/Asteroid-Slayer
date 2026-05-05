extends Node2D

var destination_y: int
var speed: float = 150.0
var speed_decline_per_second: float = 22.0

func _ready() -> void:
	$TrailParticles.emitting = true
	$ExplosionParticles.amount_ratio = (randf_range(0.3, 1.0))
	#$LaunchSound.play()

func _physics_process(delta: float) -> void:
	if position.y >= destination_y:
		position -= transform.y * speed * delta
	speed -= speed_decline_per_second * delta
	
func _process(_delta: float) -> void:
	if position.y <= destination_y:
		set_process(false)
		AudioBus.play("firework_explosion")
		$TrailParticles.emitting = false
		$ExplosionParticles.emitting = true
		$ExplosionParticles.modulate = Color (randf_range(1, 3), randf_range(1, 3), randf_range(1, 3), 2)
		
func _on_explosion_particles_finished() -> void:
	queue_free()
