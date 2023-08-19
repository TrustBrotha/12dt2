extends GPUParticles2D
var deletion_wait_time = 0.2
var extension_time = false
@export var collision_scene:PackedScene
var timer_called = false
var charge_decrease = 2
#placeholder values
var knockback = 0
var damage = 50
var hitbox_speed = 3
var hitbox_direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var hitbox_direction = get_parent().get_node("player").last_direction
	var hitbox = collision_scene.instantiate()
	hitbox.rotation = rotation
	hitbox.speed = hitbox_speed * hitbox_direction
	hitbox.position = position
	hitbox.scale *= 0.7
	hitbox.vert_speed = 50
	add_sibling(hitbox)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if extension_time == true and timer_called == false:
		timer_called = true
		$Timer.start()


func _on_collision_timer_timeout():
	if emitting == true:
		var hitbox = collision_scene.instantiate()
		hitbox.rotation = rotation
		hitbox.speed = hitbox_speed * hitbox_direction
		hitbox.position = position
		hitbox.scale *= 0.7
		hitbox.vert_speed = 50
		add_sibling(hitbox)


func _on_timer_timeout():
	queue_free()
