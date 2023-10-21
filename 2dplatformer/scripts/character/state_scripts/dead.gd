extends State


func on_enter():
	character.velocity.x = 0
	character.velocity.y = 0
	character.collision_layer = 4
	character.collision_layer != 2
	character.collision_mask != 3
	character.collision_mask != 2
	character.collision_mask != 4
#	character.animated_sprite.visible = false
	character.animated_sprite.play("death")
	get_parent().get_parent().get_parent().get_node("HUD").dead = true
	
	get_parent().get_parent().get_node("enemyhitbox").get_node("hitbox_collision").disabled = true
	character.animated_sprite.play("death")

func state_process(delta):
	character.gravity_applying(delta)

	
