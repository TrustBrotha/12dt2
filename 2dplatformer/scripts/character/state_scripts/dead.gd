extends State


# stops most of the ways the character can interact with the world
# plays death animation / sound / call for the death screen to appear
func on_enter():
	character.velocity.x = 0
	character.velocity.y = 0
	character.collision_layer = 4
	character.collision_layer != 2
	character.collision_mask != 3
	character.collision_mask != 2
	character.collision_mask != 4
	get_parent().get_parent().get_parent().get_node("HUD").dead = true
	
	get_parent().get_parent().get_node("enemyhitbox")\
			.get_node("hitbox_collision").disabled = true
	character.animated_sprite.play("death")
	var death_sound = randi_range(1,2)
	character.play_sound("death%s"%death_sound)


# applies gravity incase player dies while in the air
func state_process(delta):
	character.gravity_applying(delta)

	
