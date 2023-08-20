extends GPUParticles2D
var deletion_wait_time = 0.6

#placeholder values
var knockback = 0
var damage = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_collision_timer_timeout():
	$Area2D/CollisionShape2D.disabled = false
	$collision_deletion.start()


func _on_collision_deletion_timeout():
	$Area2D/CollisionShape2D.disabled = true
