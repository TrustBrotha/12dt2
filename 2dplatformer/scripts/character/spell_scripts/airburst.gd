extends Node2D

#placeholder values
var knockback = 500
var damage = 10

# Called when the node enters the scene tree for the first time.
# plays the visual effects of the spell and starts the deletion clock
func _ready():
	$airburst.emitting = true
	$deletion_timer.wait_time = $airburst.lifetime
	$deletion_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# once visual effects line up with being fully cast, enable collision
func _on_collision_timer_timeout():
	$Area2D/CollisionShape2D.disabled = false


#once all particles have decayed, delete scene
func _on_deletion_timer_timeout():
	queue_free()
