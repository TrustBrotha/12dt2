extends State

class_name dash_state
@export var ground_state_var : State
@export var air_state_var : State

# Called when the node enters the scene tree for the first time.
func on_enter():
	character.can_dash = false
	character.is_dashing_now = true
	character.dash_start()

func on_exit():
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
