extends State

class_name air_state
@export var double_jump_force = 200.0
@export var coyote_jump_force = 250.0

@export var ground_state_var : State
@export var landing_state_var : State
@export var wall_state_var : State
@export var dash_state_var : State
@export var casting_state_var : State
@export var immunity_state_var : State

var max_hori_speed = 125
var has_double_jumped = false

func state_process(delta):
	if(character.is_on_floor()):
		next_state = ground_state_var
	
	character.wall_check()
	
	if(character.near_wall == true and character.velocity.y > 0):
		next_state = wall_state_var
	
	character.gravity_applying(delta)
	character.velocity.x = clamp(character.velocity.x,-max_hori_speed,max_hori_speed)
	
	if(character.taken_damage == true):
		next_state = immunity_state_var

func state_input(event : InputEvent):
	if character.coyote_jump == false:
		if(event.is_action_pressed("jump") and !has_double_jumped):
			double_jump()
	
	elif character.coyote_jump == true:
		if(event.is_action_pressed("jump")):
			character.velocity.y = -coyote_jump_force
			character.animated_sprite.play("jump")
	
	if(event.is_action_pressed("dash") and character.can_dash):
		next_state = dash_state_var
	if(event.is_action_released("jump") and character.velocity.y < 0):
		character.velocity.y /= 2
	
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

func on_exit():
	if(next_state == ground_state_var or next_state == wall_state_var):
		has_double_jumped = false
		character.previous_state = "air"
	

func double_jump():
	character.velocity.y = -double_jump_force
	has_double_jumped = true
	character.animated_sprite.stop()
	character.animated_sprite.play("jump")

func on_enter():
	if(character.previous_state == "ground" and character.velocity.y >0):
		if character.animation_lock == false:
			character.animated_sprite.play("fall_start")
		character.coyote_jump = true
		character.coyote_time()
	if(character.previous_state == "casting" or character.previous_state == "wall"):
		if character.animated_sprite.animation != "jump":
			character.animated_sprite.play("fall_start")
