#need to change checking whether on walls from is_on_wall to a raycast
#add knockback when hit
#add health to player
#UI
#
#

extends CharacterBody2D
@onready var state_machine : CharacterStateMachine = $character_state_machine
@onready var right_wall_check_folder := $wall_check_folder/right_wall_check_folder.get_children()
@onready var left_wall_check_folder := $wall_check_folder/left_wall_check_folder.get_children()

@export var firesword_scene: PackedScene
@export var watersword_scene: PackedScene
@export var lightningsword_scene: PackedScene
@export var fireball_scene: PackedScene
@export var waterball_scene: PackedScene
@export var lightningball_scene: PackedScene

@export var jump_force = 250.0
@export var maxspeed = 125
@export var acceleration = 30
@export var health = 2000
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Get the gravity from the project settings to be synced with RigidBody nodes.
var movement_state = "normal"
var last_direction = 1


var can_melee = true
var can_cast = true
var coyote_timer_floor_already_called = false
var coyote_timer_wall_already_called = false
var loadout_selected = 1
var loadouts = ["fire", "water", "lightning"]
var currentloadout

var near_wall = false
var near_right_wall = false
var near_left_wall = false

var can_dash = true 
var is_dashing_now = false

var coyote_jump = false
var previous_state = ""
#var sword = sword_scene.instantiate()

func _physics_process(delta):
	# Handle Jump.
	basic_movement()
	
	weapon_spawn_location()
	loadout()
	abilities()
	
	healthcheck()
	
	move_and_slide()



func movement_states(delta):
	if movement_state == "casting":

#		can_move = false
		velocity.y = 0
		velocity.x = 0
		
	elif movement_state == "swimming":

		velocity.x = clamp(velocity.x,(-0.25 *maxspeed),(0.25 *maxspeed))
		velocity.y = clamp(velocity.y,(-0.25 *maxspeed),(0.25 *maxspeed))
#		can_jump = false
		if Input.is_action_pressed("up") or Input.is_action_pressed("jump"):
			velocity.y -= acceleration
		elif Input.is_action_pressed("down"):
			velocity.y += acceleration
		else:
			velocity.y = int(lerpf(velocity.y,0.0,0.2))

func basic_movement():
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	if state_machine.check_if_can_move():
		if direction:
			last_direction = direction
			if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
				velocity.x += direction * acceleration
		else:
			velocity.x = int(lerpf(velocity.x,0.0,0.2))


func weapon_spawn_location():
	$weapon_spawn.position.x = 85 * last_direction
	$weapon_spawn.position.y = -75


func loadout():
	#selecting loadout position
	if Input.is_action_just_released("loadout_up"):
		loadout_selected += 1
	elif Input.is_action_just_released("loadout_down"):
		loadout_selected -= 1
		
	if loadout_selected > 3:
		loadout_selected = 1
	elif loadout_selected < 1:
		loadout_selected = 3
	
	currentloadout = loadouts[loadout_selected-1]

func melee_spawning(sword):
	if Input.is_action_pressed("up"):
		sword.position.x = $weapon_spawn.position.x - (85 * last_direction)
		sword.position.y = ($weapon_spawn.position.y - 100)
		sword.rotation = -90
	elif Input.is_action_pressed("down"):
		sword.position.x = $weapon_spawn.position.x - (85 * last_direction)
		sword.position.y = ($weapon_spawn.position.y + 95)
		sword.rotation = 90
	else:
		sword.position = $weapon_spawn.position
		sword.rotation = 0
	sword.scale.x = 1 * last_direction
	add_child(sword)
	can_melee = false
	$melee_cooldown.start()

func abilities():
	#make so can only cast when melee animation finished
	if Input.is_action_just_pressed("ranged") and can_cast == true:
		if currentloadout == "fire":
			var ball = fireball_scene.instantiate()
			ranged_spawning(ball)
		elif currentloadout == "water":
			var ball = waterball_scene.instantiate()
			ranged_spawning(ball)
		elif currentloadout == "lightning":
			var ball = lightningball_scene.instantiate()
			ranged_spawning(ball)
	if Input.is_action_just_pressed("melee") and can_melee == true:
		if currentloadout == "fire":
			var sword = firesword_scene.instantiate()
			melee_spawning(sword)
		elif currentloadout == "water":
			var sword = watersword_scene.instantiate()
			melee_spawning(sword)
		elif currentloadout == "lightning":
			var sword = lightningsword_scene.instantiate()
			melee_spawning(sword)

func ranged_spawning(ball):
	movement_state = "casting"
	$is_casting.start()
	ball.position = $weapon_spawn.global_position
	ball.rotation = 0
	ball.scale.x = 1 * last_direction
	add_sibling(ball)
	can_cast = false



func healthcheck():
	if health <= 0:
		pass





func _on_coyote_timer_floor_timeout():
	pass
#	can_jump = false

func _on_melee_cooldown_timeout():
	can_melee = true

func _on_is_casting_timeout():
	movement_state = "normal"
	$casting_cooldown.start()

func _on_casting_cooldown_timeout():
	can_cast = true

func _on_enemyhitbox_area_entered(area):
	if area.has_meta("enemy"):
		velocity += 10 * (global_position - area.global_position)
		health -= 100
		if health > 0:
			get_node("/root/testlevel/player/Control/healthtemp").text = "health: " + str(health)
		elif health <= 0:
			get_node("/root/testlevel/player/Control/healthtemp").text = "epic death message"
	if area.has_meta("waterarea"):
		movement_state = "swimming"

func _on_enemyhitbox_area_exited(area):
	if area.has_meta("waterarea"):
		movement_state = "normal"
	else:
		pass




func wall_check():
	var num_of_false_check = 0
	
	for check in right_wall_check_folder:
		var ray : RayCast2D = check
		if ray.is_colliding():
			near_wall = true
			near_right_wall = true
			break
		elif !ray.is_colliding():
			num_of_false_check +=1
			near_right_wall = false
	
	for check in left_wall_check_folder:
		var ray : RayCast2D = check
		if ray.is_colliding():
			near_wall = true
			near_left_wall = true
			break
		elif !ray.is_colliding():
			num_of_false_check +=1
			near_left_wall = false
	
	if num_of_false_check == 4:
		near_wall = false


func gravity_applying(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 2000:
			velocity.y = 2000


func dash_start():
	$timers/is_dashing.start()

func _on_is_dashing_timeout():
	is_dashing_now = false


func coyote_time():
	$timers/coyote_timer.start()

func _on_coyote_timer_timeout():
	coyote_jump = false
