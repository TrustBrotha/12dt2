extends State

class_name wall_state
@export var vert_jump_force = -300.0
@export var hori_jump_force = 250
@export var immunity_state_var : State
@export var ground_state_var : State
@export var air_state_var : State
@export var dash_state_var : State

func state_process(delta):
	character.wall_check()
	character.gravity_applying(delta)
	if(character.is_on_floor()):
		next_state = ground_state_var
	if(character.near_wall == false and !character.is_on_floor()):
		next_state = air_state_var
	
	if(character.is_on_wall()):
		if character.animation_lock == false:
			character.animated_sprite.play("wall_slide")
		character.velocity.y = int(lerpf((character.velocity.y),0.0,0.3))
	
	if(character.taken_damage == true):
		next_state = immunity_state_var

func state_input(event : InputEvent):
	if(event.is_action_pressed("jump")):
		if character.near_left_wall:
			character.velocity.x = hori_jump_force
			character.velocity.y = vert_jump_force
		elif character.near_right_wall:
			character.velocity.x = -hori_jump_force
			character.velocity.y = vert_jump_force
		if character.animation_lock == false:
			character.animated_sprite.scale.x *= -1
			character.animated_sprite.play("jump")
			character.play_sound("jump")
	if(event.is_action_released("jump") and character.velocity.y < 0):
		character.velocity.y /= 2
		character.velocity.x /= 2
	if(event.is_action_pressed("dash") and GlobalVar.dash_unlocked):
		next_state = dash_state_var

func on_exit():
	character.previous_state = "wall"

func on_enter():
	character.can_dash = true
	character.animation_lock = false
