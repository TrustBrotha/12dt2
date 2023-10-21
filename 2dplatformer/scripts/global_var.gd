extends Node

var equipped_spells = ["empty","empty","empty","empty","empty"]
var discovered_spells = ["fireburst","waterstream","firestream"]
# "fireburst","waterstream","firestream","airburst"

var discovered_movement = []
var discovered_keys = ["f5_key","f4_key","flarge_key"]
# "f5_key","f4_key","flarge_key"
var character_health = 100
var last_level = "none"
var current_level = "none"

var respawn_room = "res://scenes/title_screen_scenes/titlescreen.tscn"
var fboss_zoom_lock_called = false
var boss_door_open = false
var boss_door_finished = false

var double_jump_unlocked = true
var dash_unlocked = true
var wall_jump_unlocked = true

var f1_wall_broken = false
var golem_defeated = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
