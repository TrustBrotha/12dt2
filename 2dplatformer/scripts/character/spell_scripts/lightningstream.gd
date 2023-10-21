extends Node2D


var charge_decrease = 2
var hitbox_direction = 1

var emit = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("dash"):
		emit = false
	
	
	if emit == false:
		queue_free()
	
	
#	print($Timer.time_left)



func _on_timer_timeout():
	queue_free()
