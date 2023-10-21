extends State

@export var ground_state_var : State
@export var immunity_state_var : State

func on_enter():
	character.velocity.x = 0
	
	get_parent().get_parent().get_parent().get_node("HUD").visible = false
	character.animated_sprite.play("idle")
	
	var inventory = character.inventory_scene.instantiate()
	inventory.set_name("inventory")
	get_parent().get_parent().get_parent().add_child(inventory)

func state_process(delta):
	if(character.taken_damage == true):
		next_state = immunity_state_var

func state_input(event : InputEvent):
	if(event.is_action_pressed("inventory")) or (event.is_action_pressed("exit")):
		next_state = ground_state_var
		

func on_exit():
	get_parent().get_parent().get_parent().get_node("HUD").visible = true
	get_parent().get_parent().get_parent().get_node("HUD").sprite_update()
	character.set_spells()
	get_parent().get_parent().get_parent().get_node("inventory").queue_free()
