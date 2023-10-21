extends AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready():
	volume_db = GlobalVar.sound_effect_volume
	play()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_finished():
	queue_free()
