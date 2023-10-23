extends Node2D

var knockback = 0
var damage = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	$deletion_timer.wait_time = float(16)/12
	$deletion_timer.start()
	$AnimatedSprite2D.play("default")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $RayCast2D.is_colliding():
		var collision_point = $RayCast2D.get_collision_point()
		global_position = collision_point
		$RayCast2D.enabled = false


func _on_deletion_timer_timeout():
	queue_free()


func _on_collision_on_timer_timeout():
	$Area2D/CollisionPolygon2D.disabled = false
	$collision_off_timer.start()


func _on_collision_off_timer_timeout():
	$Area2D/CollisionPolygon2D.disabled = true
