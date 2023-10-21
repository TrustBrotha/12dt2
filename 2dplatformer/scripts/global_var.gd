extends Node

var equipped_spells = ["empty","empty","empty","empty","empty"]
var discovered_spells = []
# "fireburst","waterstream","firestream","airburst"

var discovered_movement = []
var discovered_keys = []
# "f5_key","f4_key","flarge_key"
var character_health = 100
var last_level = "none"
var current_level = "none"

var respawn_room = "res://scenes/title_screen_scenes/fstart.tscn"
var fboss_zoom_lock_called = false
var boss_door_open = false
var boss_door_finished = false

var double_jump_unlocked = false
var dash_unlocked = false
var wall_jump_unlocked = false

var f1_wall_broken = false
var golem_defeated = false
var respawn_point_reached = false
var speed_run_timer_on = false
var speen_run_timer_enabled = true
var time_elapsed = 0
var stopwatch_display : String
var finish_time = ""

var music_volume = -15
var sound_effect_volume = 0
var close_key_picked_up = false #f4 locked door

var play_respawn_sound = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	print(sound_effect_volume)
#	print(music_volume)
	music_volume = clamp(music_volume,-30,0)
	sound_effect_volume = clamp(sound_effect_volume,-15,15)
	if speen_run_timer_enabled == true:
		if speed_run_timer_on == true:
			time_elapsed += delta
			var milli = fmod(time_elapsed,1)*1000
			var secs = fmod(time_elapsed, 60)
			var mins = fmod(time_elapsed, 60*60)/60
			
			stopwatch_display = "%02d : %02d : %03d" % [mins,secs,milli]

func reset():
	character_health = 100

func update_movement():
	for movement in discovered_movement:
		if movement == "dash":
			dash_unlocked = true
		elif movement == "double_jump":
			double_jump_unlocked = true
		elif movement == "wall_climb":
			wall_jump_unlocked = true
		else:
			pass

func respawn():
	reset()
	last_level = "dead"
	get_tree().change_scene_to_file(respawn_room)
	play_respawn_sound = true
