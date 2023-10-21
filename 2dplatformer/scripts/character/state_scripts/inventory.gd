extends State

@export var ground_state_var : State
@export var immunity_state_var : State
@export var air_state_var : State


# stops momentum, turns of HUD and adds inventory scene to root.
# controls animation
func on_enter():
	character.velocity.x = 0
	
	get_parent().get_parent().get_parent().get_node("HUD").visible = false
	if character.is_on_floor():
		character.animated_sprite.play("idle")
	elif !character.is_on_floor():
		character.animated_sprite.play("fall_start")
	
	
	var inventory = character.inventory_scene.instantiate()
	inventory.set_name("inventory")
	get_parent().get_parent().get_parent().add_child(inventory)


# applies gravity and checks the connection to the immunity state. Also checks it the player
# has reached the ground or not for playing animations
func state_process(delta):
	character.gravity_applying(delta)
	if(character.taken_damage == true):
		next_state = immunity_state_var
	if character.is_on_floor():
		character.animated_sprite.play("idle")


# if the inventory button is pressed again
func state_input(event : InputEvent):
	if(event.is_action_pressed("inventory")):
		if character.is_on_floor():
			next_state = ground_state_var
		elif !character.is_on_floor():
			next_state = air_state_var


func on_exit():
	get_parent().get_parent().get_parent().get_node("HUD").visible = true
	get_parent().get_parent().get_parent().get_node("HUD").sprite_update()
	character.set_spells()
	get_parent().get_parent().get_parent().get_node("inventory").queue_free()
