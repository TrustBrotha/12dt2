#need to change checking whether on walls from is_on_wall to a raycast
#need to make jump_force change with how long you hold space
#need to fix bug when jumping on wall sending you flying up or down
#need to 
#
#
#
#

extends CharacterBody2D
@export var sword_scene: PackedScene
@export var fireball_scene: PackedScene
@export var jump_force = 1000.0
@export var maxspeed = 500.0
@export var acceleration = 50
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
#var sword = sword_scene.instantiate()

func _physics_process(delta):
	# Handle Jump.
	movement_states(delta)
	basic_movement()
	wall_slide()
	dash()
	weapon_spawn_location()
	abilities()
	melee()
	
	
	move_and_slide()
	print(last_direction)



func movement_states(delta):
	
	if is_on_floor() and movement_state != "dash":
		movement_state = "normal"
	if is_on_wall() and !is_on_floor():
		movement_state = "wall"
	
	if movement_state == "normal":
		can_move = true
		velocity.x = clamp(velocity.x,-maxspeed,maxspeed)
		can_jump_wall = false
		
		if is_on_floor():
			can_jump = true
			coyote_timer_floor_already_called = false
		
		if !is_on_floor():
			velocity.y += 2 * gravity * delta
			if velocity.y > 2000:
				velocity.y = 2000
			if coyote_timer_floor_already_called == false:
				if velocity.y >= 0:
					get_node("/root/world/player/coyote_timer_floor").start()
					coyote_timer_floor_already_called = true  
				elif velocity.y < 0:
					can_jump = false
		
		if Input.is_action_just_pressed("jump") and can_jump == true:
			velocity.y = -jump_force
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y /= 2
	
	elif movement_state == "dash":
		can_move = false
		velocity.x = clamp(velocity.x,-(5000),(5000))
		#no gravity
		velocity.y = 0
	
	elif movement_state == "wall":
		can_move = true
		velocity.x = clamp(velocity.x,-(1.3*maxspeed),(1.3*maxspeed))
		
		if is_on_wall():
			can_jump_wall = true
			coyote_timer_wall_already_called = false
			if Input.is_action_just_pressed("jump"):
				if Input.is_action_pressed("move_right"):
					velocity.x = -0.75*jump_force 
					velocity.y = -jump_force
				if Input.is_action_pressed("move_left"):
					velocity.x = 0.75*jump_force 
					velocity.y = -jump_force
		
		if not is_on_wall():
			if coyote_timer_wall_already_called == false:
				get_node("/root/world/player/coyote_timer_wall").start()
				coyote_timer_wall_already_called = true 
		
		if Input.is_action_just_pressed("jump") and can_jump_wall == true:
			velocity.y = -jump_force
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y /= 2
			velocity.x /= 4
			
		#gravity
		if not is_on_floor():
			velocity.y += 2 * gravity * delta
			if velocity.y > 2000:
				velocity.y = 2000
	
	elif movement_state == "casting":
		can_move = false
		velocity.y = 0

func basic_movement():
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	if can_move == true:
		if direction:
			velocity.x += direction * acceleration
			last_direction = direction
		else:
			velocity.x = lerpf(velocity.x,0.0,0.2)
			#velocity.x = move_toward(velocity.x, 0, speed) #same thing written differently

func wall_slide():
	if is_on_wall():
		if Input.is_action_pressed("move_right"):
			velocity.y = lerpf(velocity.y,0.0,0.2)
		if Input.is_action_pressed("move_left"):
			velocity.y = lerpf(velocity.y,0.0,0.2)

func dash():
	if Input.is_action_just_pressed("dash") and can_dash:
		movement_state = "dash"
		get_node("/root/world/player/is_dashing").start()
		velocity.x += last_direction * 2000
		can_dash = false

func abilities():
	if Input.is_action_just_pressed("ranged") and can_cast == true:
		movement_state = "casting"
		$is_casting.start()
		var fireball = fireball_scene.instantiate()
		fireball.position = $weapon_spawn.global_position
		fireball.rotation = 0
		fireball.scale.x = 1 * last_direction
		add_sibling(fireball)
		can_cast = false

func weapon_spawn_location():
	$weapon_spawn.position.x = 75 * last_direction

func melee():
	if Input.is_action_just_pressed("melee") and can_melee == true:
		var sword = sword_scene.instantiate()
		sword.position = $weapon_spawn.position
		sword.rotation = 0
		sword.scale.x = 1 * last_direction
		add_child(sword)
		can_melee = false
		$melee_cooldown.start()

func _on_is_dashing_timeout():
	movement_state = "normal"
	get_node("/root/world/player/dash_cooldown").start()

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
