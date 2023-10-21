extends State

class_name air_state
@export var double_jump_force = 275.0
@export var coyote_jump_force = 275.0

@export var ground_state_var : State
@export var wall_state_var : State
@export var dash_state_var : State
@export var casting_state_var : State
@export var immunity_state_var : State
@export var inventory_state_var : State

var max_hori_speed = 125
var has_double_jumped = false
var dash_animation_called = false


# checks connections to other states, applies gravity, fixes animation issue
func state_process(delta):
	if(character.is_on_floor()):
		next_state = ground_state_var
	
	character.wall_check()
	
	if(character.near_wall == true and character.velocity.y > 0 and GlobalVar.wall_jump_unlocked):
		next_state = wall_state_var
	
	character.gravity_applying(delta)
	character.velocity.x = clamp(character.velocity.x,-max_hori_speed,max_hori_speed)
	
	if(character.taken_damage == true):
		next_state = immunity_state_var
	
	if(character.previous_state == "dash" and character.velocity.y >0):
		if dash_animation_called == false:
			if character.animation_lock == false:
				character.animated_sprite.play("fall_start")
				dash_animation_called = true


# checks connections to other states, makes the character do some actions based on some inputs
func state_input(event : InputEvent):
	if character.coyote_jump == false:
		if(event.is_action_pressed("jump") and !has_double_jumped):
			double_jump()
	
	elif character.coyote_jump == true:
		if(event.is_action_pressed("jump")):
			character.velocity.y = -coyote_jump_force
			character.animated_sprite.play("jump")
			character.play_sound("jump")
	
	if(event.is_action_pressed("dash") and character.can_dash and GlobalVar.dash_unlocked):
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
	
	if(event.is_action_pressed("inventory")):
		next_state = inventory_state_var


# resets double jump
func on_exit():
	if(next_state == ground_state_var or next_state == wall_state_var):
		has_double_jumped = false
		character.previous_state = "air"


# applies force from double jump
func double_jump():
	if GlobalVar.double_jump_unlocked:
		character.velocity.y = -double_jump_force
		has_double_jumped = true
		character.animated_sprite.stop()
		character.animated_sprite.play("jump")
		character.play_sound("jump")


# controls animation
func on_enter():
	dash_animation_called = false
	if(character.previous_state == "ground" and character.velocity.y >0):
		if character.animation_lock == false:
			character.animated_sprite.play("fall_start")
		character.coyote_jump = true
		character.coyote_time()
	elif(character.previous_state == "casting" or character.previous_state == "wall"):
#		if character.animated_sprite.animation != "jump":
		if character.animation_lock == false:
			character.animated_sprite.play("fall_start")
	
	
