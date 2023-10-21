extends Node2D

var camera_limit_left = 106
var camera_limit_right = 2568
var camera_limit_up = -1015
var camera_limit_down = 150

var fade_to_black = false
var fade_from_black = true
var target_level = "none"


@export var bird_scene : PackedScene


@export var pickup_scene : PackedScene
@onready var room_change_areas = $room_changes.get_children()
var zoom = "in"


# Called when the node enters the scene tree for the first time.
# moves player to correct door, checks what needs to be created from globalvar
func _ready():
	get_node("HUD").get_node("screen_effect").modulate.a = 1
	$updraft/updraft_sound.volume_db = GlobalVar.sound_effect_volume
	$player.get_node("Camera2D").position_smoothing_enabled = false
	GlobalVar.current_level = "flarge"
	if GlobalVar.last_level == "f3":
		$player.global_position = Vector2(135,0)
	elif GlobalVar.last_level == "f4":
		$player.global_position = Vector2(2535,-128)
	
	# calls pickup creation
	if GlobalVar.wall_jump_unlocked == false:
		create_pickup("movement","wall_climb",Vector2(1807,-539))
	if "airburst" not in GlobalVar.discovered_spells:
		create_pickup("spell","airburst",Vector2(1343,-475))
	if "flarge_key" not in GlobalVar.discovered_keys:
		create_pickup("key","flarge_key",Vector2(959,-427))
	
	# spawns boids 
	var num_of_birds = randi_range(30,60)
	for i in range(num_of_birds):
		var bird = bird_scene.instantiate()
		bird.position.x = $bird_spawn.position.x + randf_range(-20,20)
		bird.position.y = $bird_spawn.position.y + randf_range(-20,20)
		add_child(bird)


# creates a pickup which when picked up changes unlocks in globalvar
func create_pickup(type,unlock,pickup_position):
	var pickup = pickup_scene.instantiate()
	pickup.type = type
	pickup.unlock = unlock
	pickup.name = unlock
	pickup.global_position = pickup_position
	add_child(pickup)
	move_child(get_node(unlock),get_node("walls_floor").get_index())


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
	
	if zoom == "out":
		$player/Camera2D.zoom = lerp($player/Camera2D.zoom, Vector2(1,1),0.01)
	elif zoom == "in":
		$player/Camera2D.zoom = lerp($player/Camera2D.zoom, Vector2(2.75,2.75),0.01)


# door detections
func _on_flarge_f_3_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "flarge"
		fade_to_black = true
		target_level = "res://scenes/levels/f_3.tscn"


func _on_flarge_f_4_area_entered(area):
	if area.is_in_group("player"):
		GlobalVar.last_level = "flarge"
		fade_to_black = true
		target_level = "res://scenes/levels/f_4.tscn"


# controls when the doors become active after entering room
func _on_change_room_timer_timeout():
	for area in room_change_areas:
		area.get_node("CollisionShape2D").disabled = false


# controls sound of updraft
func _on_updraft_area_entered(area):
	if area.is_in_group("player"):
		$updraft/updraft_sound.play()
