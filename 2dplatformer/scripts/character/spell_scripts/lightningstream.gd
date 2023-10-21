extends Node2D

var knockback = 0
var damage = 10

var charge_decrease = 2

var timer_called = false
var hitbox_direction
var emit = true
@onready var sprites = $animated_sprites.get_children()
# Called when the node enters the scene tree for the first time.
func _ready():
	for sprite in sprites:
		sprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("dash"):
		emit = false
	
	
	if emit == false and timer_called == false:
		cancel()
		timer_called = true







func cancel():
	for sprite in sprites:
		sprite.visible = false
	$deletion_timer.wait_time = 0.1
	$deletion_timer.start()


func _on_deletion_timer_timeout():
	queue_free()


