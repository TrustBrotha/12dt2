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
func _ready():
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
func _process(delta):
	if Input.is_action_just_pressed("dash"):
		emit = false
	
	
	if emit == false and timer_called == false:
		cancel()
		timer_called = true


func cancel():
	$firestream.emitting = false
	$deletion_timer.wait_time = $firestream.lifetime
	$deletion_timer.start()


func _on_deletion_timer_timeout():
	queue_free()

func _on_collision_timer_timeout():
	if $firestream.emitting == true:
		var hitbox = collision_scene.instantiate()
		hitbox.speed = hitbox_speed * hitbox_direction
		hitbox.position = position
		hitbox.add_to_group("fire")
		hitbox.damage = damage
		hitbox.knockback = knockback
		add_sibling(hitbox)


