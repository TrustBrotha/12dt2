extends State
@export var air_state_var : State

# Called when the node enters the scene tree for the first time.
func on_enter():
	if character.can_cast == true:
		character.start_spells()
		character.can_cast = false
	else:
		next_state = air_state_var


func state_process(delta):
#	character.spells()
	if character.spell_type == "stream":
		can_move_state = false
		character.velocity.x = 0
		character.velocity.y = 0
	if character.spell_type == "burst":
		next_state = air_state_var
#	character.movement_in_spells()
#	if character.casting == false:
#		next_state = air_state_var


func state_input(event : InputEvent):
	if(event.is_action_pressed("temp")):
		next_state = air_state_var
	if(event.is_action_released("cast")):
		character.cast_released()
		next_state = air_state_var

	
	

#if Input.is_action_just_pressed("spell1") and len(created_spells) == 0:
#		var spell = spell1.instantiate()
#		spell_creation(spell)
#	elif Input.is_action_just_pressed("spell2") and len(created_spells) == 0:
#		var spell = spell2.instantiate()
#		spell_creation(spell)
#
#	elif Input.is_action_just_pressed("spell3") and len(created_spells) == 0:
#		var spell = spell3.instantiate()
#		spell_creation(spell)
