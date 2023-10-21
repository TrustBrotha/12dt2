extends Area2D

var speed = 200
var xpos = 1

var vel = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
# makes volume same as everything else
func _ready():
	$hit_sound.volume_db = GlobalVar.sound_effect_volume
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# makes boulder fall and locks x axis, which would move otherwise due to
# being a child of the golem boss
func _process(delta):
	vel.y += speed * delta
	global_position.y += vel.y * delta * 2
	global_position.x = xpos


# effect when boulder collides with the environment
func _on_body_entered(body):
	speed = 0
	$hit_sound.play()
	$GPUParticles2D.emitting = true
	$deletion_timer.start()
	$CollisionShape2D.call_deferred("queue_free")


# deletes itself once finished for optimisation reasons
func _on_deletion_timer_timeout():
	queue_free()
