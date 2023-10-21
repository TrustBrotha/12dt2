extends Node2D

#placeholder values
var knockback = 0
var damage = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	$fireburst.emitting = true
	$deletion_timer.wait_time = $fireburst.lifetime
	$deletion_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_collision_timer_timeout():
	$Area2D/CollisionShape2D.disabled = false


func _on_deletion_timer_timeout():
	queue_free()
