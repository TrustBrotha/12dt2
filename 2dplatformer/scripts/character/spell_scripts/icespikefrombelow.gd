extends Node2D

#placeholder values
var knockback = 0
var damage = 10
var position_changed = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$deletion_timer.wait_time = float(23)/12
	$deletion_timer.start()
	$sprite.play("ice_spike_up")
	global_position.y += 16


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_collision_timer_timeout():
	$Area2D/CollisionShape2D.disabled = false
	$collision_off_timer.start()


func _on_deletion_timer_timeout():
	queue_free()




func _on_collision_off_timer_timeout():
	$Area2D/CollisionShape2D.disabled = true


func _on_vision_off_timer_timeout():
	$range/CollisionShape2D.disabled = true


func _on_range_body_entered(body):
	if body.is_in_group("enemy") or body.is_in_group("boss"):
		var target_speed = body.velocity.x
		var target_position = body.global_position
		target_position.x += (0.5 * target_speed)
		if position_changed == false:
			global_position = target_position
			position_changed = true
