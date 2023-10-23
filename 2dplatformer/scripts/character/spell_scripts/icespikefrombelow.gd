extends Node2D

#placeholder values
var knockback = 0
var damage = 10
var position_changed = false


# Called when the node enters the scene tree for the first time.
# plays the visual effects of the spell and starts the deletion clock
func _ready():
	$deletion_timer.wait_time = float(23)/12
	$deletion_timer.start()
	$sprite.play("ice_spike_up")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $RayCast2D.is_colliding():
		var collision_point = $RayCast2D.get_collision_point()
		global_position = collision_point
		$RayCast2D.enabled = false


# once visual effects line up with being fully cast, enable collision
func _on_collision_timer_timeout():
	$Area2D/CollisionShape2D.disabled = false
	$collision_off_timer.start()


#once animation finished, delete scene
func _on_deletion_timer_timeout():
	queue_free()


# once collision has been on for a time, turn it off again
func _on_collision_off_timer_timeout():
	$Area2D/CollisionShape2D.disabled = true


# turns off vision soon after spawned in
func _on_vision_off_timer_timeout():
	$range/CollisionShape2D.disabled = true


# if an enemy is within range of the spell, teleports beneath them
func _on_range_body_entered(body):
	if body.is_in_group("enemy") or body.is_in_group("boss"):
		var target_speed = body.velocity.x
		var target_position = body.global_position
		target_position.x += (0.5 * target_speed)
		if position_changed == false:
			global_position = target_position
			position_changed = true
