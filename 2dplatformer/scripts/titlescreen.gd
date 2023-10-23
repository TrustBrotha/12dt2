extends Control

var page = "title"

@onready var screens = $screens.get_children()

var screen_modes = ["FULLSCREEN","MAXIMIZED"]
var selected_mode_position = 0
var selected_mode : String

# Called when the node enters the scene tree for the first time.
func _ready():
	theme.default_font_size = GlobalVar.font_size
	GlobalVar.speed_run_timer_on = false
	MusicPlayer.play_menu_music()
	GlobalVar.character_health = 100
	$screens/title/speed_run_time_label.text = GlobalVar.finish_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# controls page visiblilty
	parallax_background(delta)
	if page == "title":
		page_visibility("title")
	elif page == "settings":
		page_visibility("settings")
	elif page == "key_binds":
		page_visibility("key_binds")
	elif page == "audio_settings":
		page_visibility("audio_settings")
	elif page == "visual_settings":
		page_visibility("visual_settings")
	elif page == "credits":
		page_visibility("credits")
	
	
	# controls label text
	$screens/audio_settings/GridContainer/music_volume.text = "Volume: " \
			+ str(GlobalVar.music_volume + 15)
	$screens/audio_settings/GridContainer/sfx_volume.text = "Volume: " \
			+ str(GlobalVar.sound_effect_volume)
	$screens/visual_settings/GridContainer/font_size2.text = "Size: " \
			+ str(GlobalVar.font_size - 17)
	theme.default_font_size = GlobalVar.font_size
	$screens/visual_settings/GridContainer2/change_screen_mode.text


# controls what page is visible
func page_visibility(wanted_screen):
	for screen in screens:
		if screen.name != wanted_screen:
			screen.visible = false
		elif screen.name == wanted_screen:
			screen.visible = true




# controll parallax scroll
func parallax_background(delta):
	$ParallaxBackground2/trees.motion_offset.x += -90 * delta
	$ParallaxBackground2/mountains_close.motion_offset.x += -45 * delta
	$ParallaxBackground2/mountains_far.motion_offset.x += -30 * delta
	$ParallaxBackground2/clouds_close.motion_offset.x += -20 * delta
	$ParallaxBackground2/clouds_far.motion_offset.x += -10 * delta


# starts game
func _on_play_pressed():
	if GlobalVar.respawn_point_reached == false:
		GlobalVar.last_level = "none"
	get_tree().change_scene_to_file("res://scenes/levels/f_start.tscn")
	if GlobalVar.respawn_point_reached == true:
		GlobalVar.respawn()
	GlobalVar.speed_run_timer_on = true
	MusicPlayer.play_forest_music()
	


# button page changes
func _on_settings_pressed():
	page = "settings"


func _on_quit_pressed():
	get_tree().quit()


func _on_back_pressed():
	page = "title"


func _on_credits_back_pressed():
	page = "title"


func _on_key_binds_pressed():
	page = "key_binds"


func _on_back_kebind_pressed():
	page = "settings"


func _on_audio_pressed():
	page = "audio_settings"


func _on_audio_back_pressed():
	page = "settings"


func _on_visual_pressed():
	page = "visual_settings"


func _on_back_visual_pressed():
	page = "settings"


func _on_credits_pressed():
	page = "credits"


func _on_music_volume_down_pressed():
	GlobalVar.music_volume -=3


func _on_music_volume_up_pressed():
	GlobalVar.music_volume +=3


func _on_sfx_volume_down_pressed():
	GlobalVar.sound_effect_volume -=3


func _on_sfx_volume_up_pressed():
	GlobalVar.sound_effect_volume +=3


func _on_font_size_down_pressed():
	GlobalVar.font_size -= 2


func _on_font_size_up_pressed():
	GlobalVar.font_size += 2


func _on_change_screen_mode_pressed():
	selected_mode_position += 1
	if selected_mode_position > 1:
		selected_mode_position = 0
	selected_mode = screen_modes[selected_mode_position]
	$screens/visual_settings/GridContainer2/change_screen_mode.text = selected_mode


func _on_apply_screen_mode_pressed():
	if selected_mode == "FULLSCREEN":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif selected_mode == "MAXIMIZED":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
#	elif selected_mode == "WINDOWED":
#		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)






func _on_reset_pressed():
	GlobalVar.reset()
