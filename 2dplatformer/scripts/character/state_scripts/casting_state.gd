extends State
@export var air_state_var : State
@export var ground_state_var : State
@export var immunity_state_var : State


# Called when the node enters the scene tree for the first time.
func on_enter():
	# controls exiting the casting state
	character.exit_cast = false
	
	# starts the process of creating spells if allowed to
	if character.can_cast == true:
		character.start_spells()
	else:
		if character.is_on_floor():
			next_state = ground_state_var
		elif !character.is_on_floor():
			next_state = air_state_var


# controlls physics for different spells types, checks connections to different states
func state_process(delta):
	if character.spell_type == "stream":
		can_move_state = false
		character.velocity.x = 0
		character.velocity.y = 0
	if character.spell_type == "burst" or character.exit_cast == true:
		
		if character.is_on_floor():
			next_state = ground_state_var
		elif !character.is_on_floor():
			next_state = air_state_var
	
	if(character.taken_damage == true):
		next_state = immunity_state_var


# cancels stream spells and leaves casting state
func state_input(event : InputEvent):
	if(event.is_action_released("cast")):
		character.cast_released()
		if character.is_on_floor():
			next_state = ground_state_var
		elif !character.is_on_floor():
			next_state = air_state_var


func on_exit():
	character.previous_state = "casting"
	character.cast_released()
