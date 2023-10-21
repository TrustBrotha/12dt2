extends Node2D

var camera_limit_left = -690
var camera_limit_right = 630
var camera_limit_up = -9999999
var camera_limit_down = 9999999

var fade_to_black = false
var fade_from_black = true
var target_level = "none"

@export var pickup_scene : PackedScene
@onready var room_change_areas = $room_changes.get_children()
# Called when the node enters the scene tree for the first time.
func _ready():
	$player.get_node("Camera2D").position_smoothing_enabled = false
	GlobalVar.current_level = "fstart"
	if GlobalVar.last_level == "none":
		pass
	elif GlobalVar.last_level == "f1":
		$player.global_position = Vector2(-650,909)
	elif GlobalVar.last_level == "f2":
		$player.global_position = Vector2(600,896)
	if GlobalVar.dash_unlocked == false:
		create_pickup()
	get_node("HUD").get_node("screen_effect").modulate.a = 1

func create_pickup():
	var pickup = pickup_scene.instantiate()
	pickup.type = "movement"
	pickup.unlock = "dash"
	pickup.name = "dash"
	pickup.global_position = Vector2(-472,581)
	add_child(pickup)
	move_child(get_node("dash"),get_node("walls_floor").get_index())

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


func _on_fstart_f_1_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "fstart"
		fade_to_black = true
		target_level = "res://scenes/levels/f_1.tscn"


func _on_fstart_f_2_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "fstart"
		fade_to_black = true
		target_level = "res://scenes/levels/f_2.tscn"


func _on_change_room_timer_timeout():
	for area in room_change_areas:
		area.get_node("CollisionShape2D").disabled = false
