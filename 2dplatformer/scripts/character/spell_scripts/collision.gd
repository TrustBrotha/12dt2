extends Area2D
var speed
var vert_speed = 1
var vel = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.x += speed
	vel.y += vert_speed * delta
	global_position.y += vel.y * delta


func _on_deletion_timer_timeout():
	queue_free()
