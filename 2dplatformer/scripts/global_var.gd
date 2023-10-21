extends Node

var equipped_spells = ["empty","empty","empty","empty","empty"]
var character_health = 100
var last_level = "none"
var current_level = "none"
var fboss_zoom_lock_called = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset():
	equipped_spells = ["empty","empty","empty","empty","empty"]
	character_health = 100
