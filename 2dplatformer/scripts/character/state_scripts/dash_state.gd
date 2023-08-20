extends State

class_name dash_state
@export var ground_state_var : State
@export var air_state_var : State

# Called when the node enters the scene tree for the first time.
func on_enter():
	character.collision_layer = 4
	character.collision_layer != 2
	character.collision_mask != 3
	character.get_node("timers").get_node("immunity_frame_timer").start()
	character.hitbox_collision.disabled = true
	
	character.animation_lock = false
	character.animated_sprite.play("dash_loop")
	character.can_dash = false
	character.is_dashing_now = true
	character.dash_start()

func on_exit():
	character.animated_sprite.play("dash_end")
	character.animation_lock = true
	character.velocity.x = character.last_direction * character.maxspeed
	character.previous_state = "dash"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func state_process(delta):
	if character.is_dashing_now == true:
		character.velocity.y = 0
		character.velocity.x += character.last_direction * 100
	elif character.is_dashing_now == false:
		if !character.is_on_floor():
			next_state = air_state_var
		elif character.is_on_floor():
			next_state = ground_state_var
