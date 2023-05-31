#need to change checking whether on walls from is_on_wall to a raycast
#need to make jump_force change with how long you hold space
#need to fix bug when jumping on wall sending you flying up or down
#need to 
#
#
#
#

extends CharacterBody2D

@export var jump_force = 700.0
@export var maxspeed = 500.0
@export var acceleration = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Get the gravity from the project settings to be synced with RigidBody nodes.
var movement_state = "normal"
var last_direction
var can_move = true
var can_dash = true 

func _physics_process(delta):
	# Add the gravity.


	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	if is_on_wall():
		movement_state = "wall"
		if Input.is_action_just_pressed("jump") and Input.is_action_pressed("move_right"):
			velocity.x = -jump_force 
			velocity.y = -jump_force
		if Input.is_action_just_pressed("jump") and Input.is_action_pressed("move_left"):
			velocity.x = jump_force 
			velocity.y = -jump_force
		
	
	#different states of movement
	if movement_state == "normal":
		can_move = true
		velocity.x = clamp(velocity.x,-maxspeed,maxspeed)
		
		#gravity
		if not is_on_floor():
			velocity.y += 1.5 * gravity * delta
			if velocity.y > 2000:
				velocity.y = 2000
	
	elif movement_state == "dash":
		can_move = false
		velocity.x = clamp(velocity.x,-(5000),(5000))
		#gravity
		velocity.y = 0
	
	elif movement_state == "wall":
		can_move = true
		velocity.x = clamp(velocity.x,-(1.3*maxspeed),(1.3*maxspeed))
		
		#gravity
		if not is_on_floor():
			velocity.y += 1.5 * gravity * delta
			if velocity.y > 2000:
				velocity.y = 2000
		
	
	
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	if can_move == true:
		if direction:
			velocity.x += direction * acceleration
			last_direction = direction
		else:
			velocity.x = lerpf(velocity.x,0.0,0.2)
			#velocity.x = move_toward(velocity.x, 0, speed) #same thing written differently
	
	#sliding down wall
	if is_on_wall():
		if Input.is_action_pressed("move_right"):
			velocity.y = lerpf(velocity.y,0.0,0.1)
		if Input.is_action_pressed("move_left"):
			velocity.y = lerpf(velocity.y,0.0,0.1)
	
	#dash
	if Input.is_action_just_pressed("dash") and can_dash:
		movement_state = "dash"
		get_node("/root/world/player/is_dashing").start()
		velocity.x += last_direction * 2000
		
	
	
	move_and_slide()
	print(velocity)
	print(can_dash)


func _on_is_dashing_timeout():
	movement_state = "normal"
	get_node("/root/world/player/dash_cooldown").start()
	can_dash = false

func _on_dash_cooldown_timeout():
	can_dash = true
