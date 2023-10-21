extends Area2D

var speed = 200
var xpos = 1

var vel = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	global_position.y += vel * delta
	
	vel.y += speed * delta
	global_position.y += vel.y * delta * 2
	
	
	
	global_position.x = xpos





func _on_body_entered(body):
	print("hit")
	speed = 0
	$GPUParticles2D.emitting = true
	$deletion_timer.start()
	$CollisionShape2D.call_deferred("queue_free")


func _on_deletion_timer_timeout():
	queue_free()
