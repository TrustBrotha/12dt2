extends Node2D

var camera_limit_left = -9999999
var camera_limit_right = 320
var camera_limit_up = -9999999
var camera_limit_down = 9999999

var fade_to_black = false
var fade_from_black = true
var target_level = "none"

@export var inventory_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	$player.get_node("Camera2D").position_smoothing_enabled = false
	GlobalVar.current_level = "ffinal"
	get_node("HUD").get_node("screen_effect").modulate.a = 1


func _process(delta):
	$player.get_node("Camera2D").position_smoothing_enabled = true
	if fade_from_black == true:
		get_node("HUD").get_node("screen_effect").modulate.a = lerpf(get_node("HUD").get_node("screen_effect").modulate.a, 0, 0.2)
		if get_node("HUD").get_node("screen_effect").modulate.a <= 0.05:
			get_node("HUD").get_node("screen_effect").modulate.a = 0
			fade_from_black = false
	
	if fade_to_black == true:
		get_node("HUD").get_node("screen_effect").modulate.a = lerpf(get_node("HUD").get_node("screen_effect").modulate.a, 1, 0.2)
	
	if get_node("HUD").get_node("screen_effect").modulate.a >= 0.9:
		if target_level != "none":
			get_tree().change_scene_to_file(target_level)





func _on_ffinal_fboss_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "ffinal"
		fade_to_black = true
		target_level = "res://scenes/levels/f_boss.tscn"


func _on_ffinal_titlescreen_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "ffinal"
		fade_to_black = true
		target_level = "res://scenes/title_screen_scenes/titlescreen.tscn"
