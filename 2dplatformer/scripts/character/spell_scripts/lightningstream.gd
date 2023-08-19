extends AnimatedSprite2D
var deletion_wait_time = 0.01
var extension_time = false
var timer_called = false
var charge_decrease = 2
var hitbox_direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if extension_time == true and timer_called == false:
		timer_called = true
		$Timer.start()

#	print($Timer.time_left)



func _on_timer_timeout():
	queue_free()
