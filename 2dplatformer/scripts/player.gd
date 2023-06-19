#need to change checking whether on walls from is_on_wall to a raycast
#add knockback when hit
#add health to player
#UI
#
#

extends CharacterBody2D
@export var firesword_scene: PackedScene
@export var watersword_scene: PackedScene
@export var lightningsword_scene: PackedScene
@export var fireball_scene: PackedScene
@export var waterball_scene: PackedScene
@export var lightningball_scene: PackedScene
@export var jump_force = 250.0
@export var maxspeed = 75.0
@export var acceleration = 30
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Get the gravity from the project settings to be synced with RigidBody nodes.
var movement_state = "normal"
var last_direction = 1
var can_move = true
var can_dash = true 
var can_jump = true
var can_jump_wall = true
var is_dashing = false
var can_melee = true
var can_cast = true
var coyote_timer_floor_already_called = false
var coyote_timer_wall_already_called = false
var loadout_selected = 1
var loadouts = ["fire", "water", "lightning"]
var currentloadout
#var sword = sword_scene.instantiate()

func _physics_process(delta):
	# Handle Jump.
	movement_states(delta)
	basic_movement()
	dash()
	weapon_spawn_location()
	loadout()
	abilities()
	
	
	
	move_and_slide()
	print(last_direction)



func movement_states(delta):
	
	if is_on_floor() and movement_state != "dash":
		movement_state = "normal"
	if is_on_wall() and !is_on_floor() and velocity.y > 0:
		movement_state = "wall"
	
	if movement_state == "normal":
		can_move = true
#		velocity.x = clamp(velocity.x,-maxspeed,maxspeed)
		can_jump_wall = false
		
		if is_on_floor():
			can_jump = true
			coyote_timer_floor_already_called = false
		
		if !is_on_floor():
			velocity.y += gravity * delta
			if velocity.y > 2000:
				velocity.y = 2000
			if coyote_timer_floor_already_called == false:
				if velocity.y >= 0:
					$coyote_timer_floor.start()
					coyote_timer_floor_already_called = true  
				elif velocity.y < 0:
					can_jump = false
		
		if Input.is_action_just_pressed("jump") and can_jump == true:
			velocity.y = -jump_force
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y /= 2
	
	elif movement_state == "dash":
		#stops movement in either direction while also increasing max x speed
		can_move = false
		velocity.x = clamp(velocity.x,-(500),(500))
		
		#no gravity
		velocity.y = 0
		
		#makes hitting wall with dash more responsive
		if is_on_wall():
			movement_state = "wall"
	
	elif movement_state == "wall":
		can_move = true
		velocity.x = clamp(velocity.x,-(1*maxspeed),(1*maxspeed))
		
		#need to change to ray casts where if raycastleft = true, sends up and to the right, and if raycastright = true sends up and to the left
		if is_on_wall():
			can_jump_wall = true
			coyote_timer_wall_already_called = false
			if Input.is_action_pressed("move_right"):
				velocity.y = lerpf(velocity.y,0.0,0.25)
			if Input.is_action_pressed("move_left"):
				velocity.y = lerpf(velocity.y,0.0,0.25)
			
			if Input.is_action_just_pressed("jump"):
				if Input.is_action_pressed("move_right"):
					velocity.x = -1.5*jump_force 
					velocity.y = -2*jump_force
				if Input.is_action_pressed("move_left"):
					velocity.x = 1.5*jump_force 
					velocity.y = -2*jump_force
		
		if not is_on_wall():
			if coyote_timer_wall_already_called == false:
				$coyote_timer_wall.start()
				coyote_timer_wall_already_called = true 
		
		if Input.is_action_just_pressed("jump") and can_jump_wall == true:
			velocity.y = -jump_force
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y /= 2
			velocity.x /= 4
			
		#gravity
		if not is_on_floor():
			velocity.y += gravity * delta
			if velocity.y > 2000:
				velocity.y = 2000
	
	elif movement_state == "casting":
		can_move = false
		velocity.y = 0
		velocity.x = 0

func basic_movement():
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	if can_move == true:
		if direction:
			velocity.x += direction * acceleration
			last_direction = direction
			if velocity.x >= maxspeed:
				velocity.x = maxspeed
			elif velocity.x <= -maxspeed:
				velocity.x = -maxspeed
		else:
			velocity.x = lerpf(velocity.x,0.0,0.2)
			#velocity.x = move_toward(velocity.x, 0, speed) #same thing written differently


func dash():
	if Input.is_action_just_pressed("dash") and can_dash:
		movement_state = "dash"
		$is_dashing.start()
		velocity.x += last_direction * 500
		can_dash = false

func weapon_spawn_location():
	$weapon_spawn.position.x = 85 * last_direction
	$weapon_spawn.position.y = -75

func double_jump():
	pass

func loadout():
	#selecting loadout position
	if Input.is_action_just_pressed("loadout_up"):
		loadout_selected += 1
	elif Input.is_action_just_pressed("loadout_down"):
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

func ranged_spawning(ball):
	movement_state = "casting"
	$is_casting.start()
	ball.position = $weapon_spawn.global_position
	ball.rotation = 0
	ball.scale.x = 1 * last_direction
	add_sibling(ball)
	can_cast = false

func _on_is_dashing_timeout():
	movement_state = "normal"
	$dash_cooldown.start()

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_coyote_timer_wall_timeout():
	can_jump_wall = false

func _on_coyote_timer_floor_timeout():
	can_jump = false

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
		print("oww")
	
