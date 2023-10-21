extends Node2D
@export var boid_scene: PackedScene


@export var inventory_scene: PackedScene
var inventory_open = false
var can_open_inventory = false
var force_leave = false

var screen_size
var numofboids = 0
var boidscreated = []
var boidonscreen = 0

var camera_limit_left = -324
var camera_limit_right = 720
var camera_limit_up = -500
var camera_limit_down = 48
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if can_open_inventory == true:
		if Input.is_action_just_pressed("inventory") and inventory_open == false:
			var inventory = inventory_scene.instantiate()
			inventory.set_name("inventory")
			add_child(inventory)
			inventory_open = true
	elif inventory_open == true:
		if Input.is_action_just_pressed("inventory") or Input.is_action_just_pressed("exit") or force_leave == true:
			get_node("inventory").queue_free()
			inventory_open = false
	
	
	
	boidonscreen = len(boidscreated)
	if boidonscreen < numofboids:
		var boid = boid_scene.instantiate()
#		var boid_spawn_x = randf_range(margin, (screen_size.x - margin))
#		var boid_spawn_y = randf_range(margin, (screen_size.y - margin))
		var boid_spawn_x = $player.position.x
		var boid_spawn_y = $player.position.y
		boid.position.x = boid_spawn_x
		boid.position.y = boid_spawn_y
		boid.rotation = randf_range(0,2*PI)
		add_child(boid)
		boidonscreen += 1
		boidscreated.append(boid)
	elif boidonscreen > numofboids:
		if len(boidscreated) > 0:
			var lastboid = boidscreated.pop_back()
			lastboid.queue_free()


func _on_finish_area_entered(area):
	if area.is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/title_screen_scenes/titlescreen.tscn")
