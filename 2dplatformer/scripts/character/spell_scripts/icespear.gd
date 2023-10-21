extends Node2D

var knockback = 50
var damage = 10

var direction = 1
var moving = true
# Called when the node enters the scene tree for the first time.
func _ready():
	direction = get_parent().get_node("player").last_direction
	$AnimatedSprite2D.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving:
		position.x += 300 * delta * direction


func _on_deletion_timer_timeout():
	queue_free()


func _on_area_2d_body_entered(body):
#	$GPUParticles2D.process_material.direction.x = direction * -1
	$GPUParticles2D.emitting = true
	moving = false
	$deletion_timer.wait_time = $GPUParticles2D.lifetime
	$deletion_timer.start()
