extends State

@export var ground_state_var : State
@export var air_state_var : State
@export var dead_state_var : State
var knockback = 200



func on_enter():
	character.play_sound("player_hit")
	# if player isn't dead then the player is sent backwards from the knockback
	# and collision is turned off. 
	if GlobalVar.character_health > 0:
		character.velocity.x = character.knockback_direction * character.knockback
		character.velocity.y = -1.5 * character.knockback
		
		character.collision_layer = 4
		character.collision_layer != 2
		character.collision_mask != 3
		# when timer runs out collision back to normal and sets taken damage to false
		character.get_node("timers").get_node("immunity_frame_timer").start()
		character.hitbox_collision.disabled = true
		character.animated_sprite.play("damaged")
	# however if the character is dead from the last hit, then the state is pushed
	# onto the dead state
	elif GlobalVar.character_health <= 0:
		next_state = dead_state_var


# applies gravity and once timer runs out changes state
func state_process(delta):
	character.gravity_applying(delta)
	
	if(character.taken_damage == false):
		if character.is_on_floor():
			next_state = ground_state_var
		elif !character.is_on_floor():
			next_state = air_state_var
	
	
	
	
