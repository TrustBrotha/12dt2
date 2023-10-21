extends Node2D
@export var collision_scene:PackedScene

var timer_called = false

var charge_decrease = 2

#placeholder values
var knockback = 0
var damage = 10
var hitbox_speed = 4
var hitbox_direction = 1

var emit = true


# Called when the node enters the scene tree for the first time.
# plays visual effects, creates the first collision instance of the trail.
func _ready():
	# starts sound effect
	$AudioStreamPlayer.volume_db = GlobalVar.sound_effect_volume - 5
	$AudioStreamPlayer.play()
	$firestream.emitting = true
	hitbox_direction = get_parent().get_node("player").last_direction
	var hitbox = collision_scene.instantiate()
	hitbox.speed = hitbox_speed * hitbox_direction
	hitbox.position = position
	hitbox.add_to_group("fire")
	hitbox.damage = damage
	hitbox.knockback = knockback
	add_sibling(hitbox)


# Called every frame. 'delta' is the elapsed time since the previous frame.
# checks if should delete itself
func _process(delta):
	if emit == false and timer_called == false:
		cancel()
		timer_called = true


# stops creation of spell effects
func cancel():
	$AudioStreamPlayer.stop()
	$firestream.emitting = false
	$deletion_timer.wait_time = $firestream.lifetime
	$deletion_timer.start()


# once particles have decayed, deletes scene
func _on_deletion_timer_timeout():
	queue_free()


# adds a collision scene every set amount of time to
# create a collision shape similar to the particle effects
func _on_collision_timer_timeout():
	if $firestream.emitting == true:
		var hitbox = collision_scene.instantiate()
		hitbox.speed = hitbox_speed * hitbox_direction
		hitbox.position = position
		hitbox.add_to_group("fire")
		hitbox.damage = damage
		hitbox.knockback = knockback
		add_sibling(hitbox)


