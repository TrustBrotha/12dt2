extends AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
# makes volume the same all all of the others
func _ready():
	volume_db = GlobalVar.sound_effect_volume
	play()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# when finished is deleted for optimisation reasons
func _on_finished():
	queue_free()
