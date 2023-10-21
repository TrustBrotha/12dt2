extends Node2D

var knockback = 0
var damage = 10

var charge_decrease = 2

var timer_called = false
var hitbox_direction
var emit = true
@onready var sprites = $animated_sprites.get_children()


# Called when the node enters the scene tree for the first time.
# starts visual effects
func _ready():
	# starts sound effect
	$AudioStreamPlayer.volume_db = GlobalVar.sound_effect_volume - 5
	$AudioStreamPlayer.play()
	for sprite in sprites:
		sprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
# checks if should delete itself
func _process(delta):
	if emit == false and timer_called == false:
		cancel()
		timer_called = true


# deletes visual effects
func cancel():
	for sprite in sprites:
		sprite.visible = false
	$deletion_timer.wait_time = 0.1
	$deletion_timer.start()
	$AudioStreamPlayer.stop()


# deletes scene soon after
func _on_deletion_timer_timeout():
	queue_free()


