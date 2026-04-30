extends Node2D

var speed: float
var stage: int = 0

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_visible_on_screen_notifier_2d_screen_entered():
	stage += 1

func _on_visible_on_screen_notifier_2d_screen_exited():
	if stage == 1:
		queue_free()
