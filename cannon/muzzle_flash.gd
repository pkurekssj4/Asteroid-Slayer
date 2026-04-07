extends AnimatedSprite2D

func _ready():
	#$GPUParticles2D.emitting = true
	play()

func _on_animation_finished():
	queue_free()
