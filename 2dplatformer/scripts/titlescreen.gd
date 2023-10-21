extends Control

var page = "title"

@onready var screens = $screens.get_children()



# Called when the node enters the scene tree for the first time.
func _ready():
	
	GlobalVar.speed_run_timer_on = false
	MusicPlayer.play_menu_music()
	GlobalVar.character_health = 100
	$screens/title/speed_run_time_label.text = GlobalVar.finish_time
	
#	GlobalVar.reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parallax_background(delta)
	if page == "title":
		page_visibility("title")
	elif page == "settings":
		page_visibility("settings")
	elif page == "key_binds":
		page_visibility("key_binds")
	elif page == "audio_settings":
		page_visibility("audio_settings")
	
	
	$screens/audio_settings/GridContainer/music_volume.text = "Volume: " + str(GlobalVar.music_volume + 15)
	$screens/audio_settings/GridContainer/sfx_volume.text = "Volume: " + str(GlobalVar.sound_effect_volume)


func page_visibility(wanted_screen):
	for screen in screens:
			if screen.name != wanted_screen:
				screen.visible = false
			elif screen.name == wanted_screen:
				screen.visible = true





func parallax_background(delta):
	$ParallaxBackground2/trees.motion_offset.x += -90 * delta
	$ParallaxBackground2/mountains_close.motion_offset.x += -45 * delta
	$ParallaxBackground2/mountains_far.motion_offset.x += -30 * delta
	$ParallaxBackground2/clouds_close.motion_offset.x += -20 * delta
	$ParallaxBackground2/clouds_far.motion_offset.x += -10 * delta


func _on_play_pressed():
	if GlobalVar.respawn_point_reached == false:
		GlobalVar.last_level = "none"
	get_tree().change_scene_to_file("res://scenes/levels/f_start.tscn")
	if GlobalVar.respawn_point_reached == true:
		GlobalVar.respawn()
	GlobalVar.speed_run_timer_on = true
	MusicPlayer.play_forest_music()
	


func _on_settings_pressed():
	page = "settings"


func _on_quit_pressed():
	get_tree().quit()


func _on_back_pressed():
	page = "title"



func _on_key_binds_pressed():
	page = "key_binds"


func _on_back_kebind_pressed():
	page = "settings"


func _on_audio_pressed():
	page = "audio_settings"


func _on_audio_back_pressed():
	page = "settings"



func _on_music_volume_down_pressed():
	GlobalVar.music_volume -=3


func _on_music_volume_up_pressed():
	GlobalVar.music_volume +=3




func _on_sfx_volume_down_pressed():
	GlobalVar.sound_effect_volume -=3



func _on_sfx_volume_up_pressed():
	GlobalVar.sound_effect_volume +=3

