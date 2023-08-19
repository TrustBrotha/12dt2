extends State

class_name ground_state

@export var jump_force = 250.0

@export var air_state_var : State
@export var dash_state_var : State
@export var casting_state_var : State

var max_hori_speed = 125
var state_can_dash = true

func state_process(delta):
	
	character.gravity_applying(delta)
	if(!character.is_on_floor()):
		next_state = air_state_var
	character.velocity.x = clamp(character.velocity.x,-max_hori_speed,max_hori_speed)

func on_enter():
	character.can_dash = true
	


func state_input(event : InputEvent):
	if(event.is_action_pressed("jump")):
		jump()
	if(event.is_action_pressed("dash") and character.can_dash and state_can_dash):
		next_state = dash_state_var
	if(event.is_action_pressed("cast")):
		if(event.is_action_pressed("spell1")):
			character.saved_spell_input = "spell1"
		elif(event.is_action_pressed("spell2")):
			character.saved_spell_input = "spell2"
		elif(event.is_action_pressed("spell3")):
			character.saved_spell_input = "spell3"
		elif(event.is_action_pressed("spell4")):
			character.saved_spell_input = "spell4"
		elif(event.is_action_pressed("spell5")):
			character.saved_spell_input = "spell5"
		next_state = casting_state_var


func jump():
	character.velocity.y = -jump_force
	next_state = air_state_var

func on_exit():
	character.previous_state = "ground"
	

