extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("sword", 1)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#	position = get_node("root/world/player/weapon_spawn").global_position


func _on_is_meleeing_timeout():
	queue_free()
