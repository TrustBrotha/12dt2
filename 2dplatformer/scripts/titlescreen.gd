extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	GlobalVar.reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/f_start.tscn")
	


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen_scenes/settings.tscn")


func _on_quit_pressed():
	get_tree().quit()
