extends Node2D

var camera_limit_left = -580
var camera_limit_right = 225
var camera_limit_up = -9999999
var camera_limit_down = 115

var fade_to_black = false
var fade_from_black = true
var target_level = "none"
@onready var room_change_areas = $room_changes.get_children()
@export var pickup_scene : PackedScene


# Called when the node enters the scene tree for the first time.
# moves player to correct door, checks what needs to be created from globalvar
func _ready():
	get_node("HUD").get_node("screen_effect").modulate.a = 1
	$player.get_node("Camera2D").position_smoothing_enabled = false
	GlobalVar.current_level = "f3"
	if GlobalVar.last_level == "f2":
		$player.global_position = Vector2(40,0)
	elif GlobalVar.last_level == "flarge":
		$player.global_position = Vector2(192,0)
	if "firestream" not in GlobalVar.discovered_spells:
		create_pickup()


# creates a pickup which when picked up changes unlocks in globalvar
func create_pickup():
	var pickup = pickup_scene.instantiate()
	pickup.type = "spell"
	pickup.unlock = "firestream"
	pickup.name = "firestream"
	pickup.global_position = Vector2(-470,-30)
	add_child(pickup)
	move_child(get_node("firestream"),get_node("walls_floor").get_index())


# camera control, fade in / out control
func _process(delta):
	$player.get_node("Camera2D").position_smoothing_enabled = true
	if fade_from_black == true:
		get_node("HUD").get_node("screen_effect").modulate.a\
				 = lerpf(get_node("HUD").get_node("screen_effect").modulate.a, 0, 0.2)
		if get_node("HUD").get_node("screen_effect").modulate.a <= 0.05:
			get_node("HUD").get_node("screen_effect").modulate.a = 0
			fade_from_black = false
	
	
	if fade_to_black == true:
		get_node("HUD").get_node("screen_effect").modulate.a\
				 = lerpf(get_node("HUD").get_node("screen_effect").modulate.a, 1, 0.2)
	
	if get_node("HUD").get_node("screen_effect").modulate.a >= 0.9:
		if target_level != "none":
			get_tree().change_scene_to_file(target_level)


# door detections
func _on_f_3_f_2_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "f3"
		fade_to_black = true
		target_level = "res://scenes/levels/f_2.tscn"

func _on_f_3_flarge_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "f3"
		fade_to_black = true
		target_level = "res://scenes/levels/f_large.tscn"


# controls when the doors become active after entering room
func _on_change_room_timer_timeout():
	for area in room_change_areas:
		area.get_node("CollisionShape2D").disabled = false
