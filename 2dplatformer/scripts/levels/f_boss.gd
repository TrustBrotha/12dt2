extends Node2D

var camera_limit_left = -880
var camera_limit_right = 415
var camera_limit_up = -9999999
var camera_limit_down = 9999999

var fade_to_black = false
var fade_from_black = true
var target_level = "none"

var close_door = false

@onready var room_change_areas = $room_changes.get_children()
@export var boss_scene : PackedScene
var boss_spawned = false
var zoom = "in"
var zoom_lock = false


# Called when the node enters the scene tree for the first time.
# moves player to correct door, checks what needs to be created from globalvar
func _ready():
	get_node("HUD").get_node("screen_effect").modulate.a = 1
	$player.get_node("Camera2D").position_smoothing_enabled = false
	GlobalVar.current_level = "fboss"
	if GlobalVar.last_level == "f4":
		$player.global_position = Vector2(385,0)
	elif GlobalVar.last_level == "ffinal":
		$player.global_position = Vector2(-848,0)
	
	if GlobalVar.golem_defeated == false:
		$golem_dead.visible = true
		$golem_dead.play("asleep")
	elif GlobalVar.golem_defeated == true:
		$golem_dead.visible = true
		$golem_dead.play("dead")
		move_child(get_node("golem_dead"),get_node("player").get_index())


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
	
	
	if (
			$player.global_position.x > $zoom_left.global_position.x
			and $player.global_position.x < $zoom_right.global_position.x
	):
		zoom = "out"
	elif (
			$player.global_position.x < $zoom_left.global_position.x
			or $player.global_position.x > $zoom_right.global_position.x
	):
		zoom = "in"
		if zoom_lock == true:
			zoom_lock = false
	
	if $player.global_position.x < $boss_trigger.global_position.x and boss_spawned == false:
		
		if GlobalVar.golem_defeated == false:
			close_door = true
			boss_spawned = true
			var golem = boss_scene.instantiate()
			golem.global_position = $boss_spawn.global_position
			add_child(golem)
			move_child(get_node("golem"),get_node("walls_floor").get_index())
			$golem_dead.visible = false
	
	if close_door == true:
		$doors.global_position.y = lerpf($doors.global_position.y,0,0.1)
	elif close_door == false:
		$doors.global_position.y = lerpf($doors.global_position.y,65,0.1)
	
	
	
	if (
			$player.global_position.x < $zoom_lock.global_position.x
			and GlobalVar.fboss_zoom_lock_called == false
	):
		zoom_lock = true
		GlobalVar.fboss_zoom_lock_called = true
	
	
	if zoom == "out":
		$player/Camera2D.zoom = lerp($player/Camera2D.zoom, Vector2(1.8,1.8),0.03)
	elif zoom == "in":
		$player/Camera2D.zoom = lerp($player/Camera2D.zoom, Vector2(2.75,2.75),0.03)
	
	if zoom_lock == true:
		camera_limit_left = -470
		camera_limit_right = 270
		$player.camera_update()
	elif zoom_lock == false:
		camera_limit_left = -880
		camera_limit_right = 415
		$player.camera_update()


# door detections
func _on_fboss_f_4_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "fboss"
		fade_to_black = true
		target_level = "res://scenes/levels/f_4.tscn"


func _on_fboss_ffinal_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.speed_run_timer_on = false
		GlobalVar.last_level = "fboss"
		fade_to_black = true
		GlobalVar.finish_time = GlobalVar.stopwatch_display
		target_level = "res://scenes/title_screen_scenes/titlescreen.tscn"


# controls when the doors become active after entering room
func _on_change_room_timer_timeout():
	for area in room_change_areas:
		area.get_node("CollisionShape2D").disabled = false
