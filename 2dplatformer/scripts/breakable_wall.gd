extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# plays the effects for deleting the wall
func destroyed():
	$TileMap.queue_free()
	$GPUParticles2D.emitting = true
	$deletion_timer.wait_time = $GPUParticles2D.lifetime
	$deletion_timer.start()
	GlobalVar.f1_wall_broken = true


# detection for when to delete the wall
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("spell") or area.is_in_group("spell"):
		$Area2D.queue_free()
		destroyed()


# removes the wall for optimisation purposes when particles finished decaying
func _on_deletion_timer_timeout():
	queue_free()
