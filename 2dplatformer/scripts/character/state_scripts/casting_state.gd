extends State
@export var air_state_var : State
@export var ground_state_var : State
@export var immunity_state_var : State


# Called when the node enters the scene tree for the first time.
func on_enter():
	if character.can_cast == true:
		character.start_spells()
		character.can_cast = false
	else:
		if character.is_on_floor():
			next_state = ground_state_var
		elif !character.is_on_floor():
			next_state = air_state_var


func state_process(delta):
#	character.spells()
	if character.spell_type == "stream":
		can_move_state = false
		character.velocity.x = 0
		character.velocity.y = 0
	if character.spell_type == "burst":
		if character.is_on_floor():
			next_state = ground_state_var
		elif !character.is_on_floor():
			next_state = air_state_var
	
	if(character.taken_damage == true):
		next_state = immunity_state_var


func state_input(event : InputEvent):
	if(event.is_action_released("cast")):
		character.cast_released()
		if character.is_on_floor():
			next_state = ground_state_var
		elif !character.is_on_floor():
			next_state = air_state_var


func on_exit():
	character.previous_state = "casting"
