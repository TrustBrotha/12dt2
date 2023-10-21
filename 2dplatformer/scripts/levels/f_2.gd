extends Node2D

var camera_limit_left = -150
var camera_limit_right = 1300
var camera_limit_up = -225
var camera_limit_down = 9999999

var fade_to_black = false
var fade_from_black = true
var target_level = "none"
@export var pickup_scene : PackedScene
@onready var room_change_areas = $room_changes.get_children()


# Called when the node enters the scene tree for the first time.
# moves player to correct door, checks what needs to be created from globalvar
func _ready():
	get_node("HUD").get_node("screen_effect").modulate.a = 1
	$player.get_node("Camera2D").position_smoothing_enabled = false
	GlobalVar.current_level = "f2"
	if GlobalVar.last_level == "fstart":
		$player.global_position = Vector2(-115,0)
	elif GlobalVar.last_level == "f3":
		$player.global_position = Vector2(1096,-88)
	if "fireburst" not in GlobalVar.discovered_spells:
		create_pickup()


# creates a pickup which when picked up changes unlocks in globalvar
func create_pickup():
	var pickup = pickup_scene.instantiate()
	pickup.type = "spell"
	pickup.unlock = "fireburst"
	pickup.name = "fireburst"
	pickup.global_position = Vector2(520,-43)
	add_child(pickup)
	move_child(get_node("fireburst"),get_node("walls_floor").get_index())


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
func _on_f_2_fstart_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "f2"
		fade_to_black = true
		target_level = "res://scenes/levels/f_start.tscn"


func _on_f_2_f_3_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "f2"
		fade_to_black = true
		target_level = "res://scenes/levels/f_3.tscn"


# controls when the doors become active after entering room
func _on_change_room_timer_timeout():
	for area in room_change_areas:
		area.get_node("CollisionShape2D").disabled = false
