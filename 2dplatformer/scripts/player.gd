extends CharacterBody2D

# defines the state machine to me manipulated as a variable
@onready var state_machine : CharacterStateMachine = $character_state_machine

# defines lists based on scene tree
@onready var right_wall_check_folder := $wall_check_folder/right_wall_check_folder.get_children()
@onready var left_wall_check_folder := $wall_check_folder/left_wall_check_folder.get_children()
@onready var safe_floor_folder := $safe_floor_check_folder.get_children()
@onready var chargerbar_folder = get_parent().get_node("HUD")\
		.get_node("spell_charge_bar_folder").get_children()

# defines nodes to be used by state machine
@onready var animated_sprite : AnimatedSprite2D = $player_sprite
@onready var hitbox_collision : CollisionShape2D = $enemyhitbox/hitbox_collision

# gets scenes which are instantiatied
@export var inventory_scene : PackedScene
@export var spell_audio_scene : PackedScene
@export var audio_player : PackedScene

# sets some values
@export var jump_force = 250.0
@export var maxspeed = 125
@export var acceleration = 30
@export var health = 2000
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# saved direction used by state machine
var last_direction = 1

# if true changes to immunity state
var taken_damage = false

# saves knockback values so it can be used by immunity state
var knockback
var knockback_direction = 1

# control for reseting position when falling into spikes
var safe_ground = Vector2.ZERO
var reset_position = false
var screen_target_opacity = 1

# spell variables used in state machine
var saved_spell_input
var equiped_spells = []
var spell1
var spell2
var spell3
var spell4
var spell5
var saved_spell
var losing_charge = false
var can_cast = true
var spell_type
var charge_lock
var exit_cast = false

# walling sound effect control
var audio_timer_called = false

# control for wall state
var near_wall = false
var near_right_wall = false
var near_left_wall = false

# control for dash state
var can_dash = true 
var is_dashing_now = false
var ground_can_dash = true

# saves whether or not can coyote jump
var coyote_jump = false

# saves previous state from state machine
var previous_state = ""

# controls animation
var moving = false
var animation_lock = false
var combo1_called = false
var combo2_called = false
var combo3_called = false


# runs some functions before any thing else has the chance to do anything
func _ready():
	set_spells()
	camera_update()
	if GlobalVar.play_respawn_sound == true:
		play_sound("respawn")
		GlobalVar.play_respawn_sound = false
	safe_ground = global_position


func _physics_process(delta):
	HUD_update()
	basic_movement()
	sprite_position()
	screen_effects()
	play_walk_sound()
	move_and_slide()


#limits the camera based on data from the level node
func camera_update():
	$Camera2D.limit_left = get_parent().camera_limit_left
	$Camera2D.limit_right = get_parent().camera_limit_right
	$Camera2D.limit_top = get_parent().camera_limit_up
	$Camera2D.limit_bottom = get_parent().camera_limit_down


# called on start and from inventory, gets data about spells from GlobalVar
func set_spells():
	equiped_spells = GlobalVar.equipped_spells
	spell1 = load("res://scenes/spells/%s.tscn" %equiped_spells[0])
	spell2 = load("res://scenes/spells/%s.tscn" %equiped_spells[1])
	spell3 = load("res://scenes/spells/%s.tscn" %equiped_spells[2])
	spell4 = load("res://scenes/spells/%s.tscn" %equiped_spells[3])
	spell5 = load("res://scenes/spells/%s.tscn" %equiped_spells[4])


# controls when the walk sound plays
func play_walk_sound():
	if $player_sprite.animation == "run" and audio_timer_called == false:
		$timers/walk_sound_timer.wait_time = float(4.5)/12
		audio_timer_called = true
		var audio = audio_player.instantiate()
		audio.stream = load("res://assets/sounds/walk_sound.mp3")
		$sounds.add_child(audio)
		$timers/walk_sound_timer.start()


# creates audio player nodes for sound effects
func play_sound(sound):
	var audio = audio_player.instantiate()
	audio.stream = load("res://assets/sounds/%s_sound.mp3"%sound)
	$sounds.add_child(audio)


# controls the charge bar values and the debug labels
func HUD_update():
	get_parent().get_node("HUD").get_node("state_debug_label").text\
			 = "state = " + state_machine.current_state.name
	get_parent().get_node("HUD").get_node("fps_debug_label").text\
			 = "fps = " + str(Engine.get_frames_per_second())
	
	for bar in chargerbar_folder:
#		var bar_temp : ProgressBar = bar
		bar.value += 0.5
		if bar.value == 100:
			bar.hide()
		elif bar.value != 100:
			bar.show()
		if bar.value <= 2:
			cast_released()
	if losing_charge == true:
		if Input.is_action_pressed("spell1") and charge_lock == "spell1":
			get_parent().get_node("HUD").get_node("spell_charge_bar_folder")\
					.get_node("spell1_charge_bar").value -= saved_spell.charge_decrease
		if Input.is_action_pressed("spell2") and charge_lock == "spell2":
			get_parent().get_node("HUD").get_node("spell_charge_bar_folder")\
					.get_node("spell2_charge_bar").value -= saved_spell.charge_decrease
		if Input.is_action_pressed("spell3") and charge_lock == "spell3":
			get_parent().get_node("HUD").get_node("spell_charge_bar_folder")\
					.get_node("spell3_charge_bar").value -= saved_spell.charge_decrease
		if Input.is_action_pressed("spell4") and charge_lock == "spell4":
			get_parent().get_node("HUD").get_node("spell_charge_bar_folder")\
					.get_node("spell4_charge_bar").value -= saved_spell.charge_decrease
		if Input.is_action_pressed("spell5") and charge_lock == "spell5":
			get_parent().get_node("HUD").get_node("spell_charge_bar_folder")\
					.get_node("spell5_charge_bar").value -= saved_spell.charge_decrease


# called from casting state
func start_spells():
	if saved_spell_input == "spell1":
		var spell = spell1.instantiate()
		spell_creation(spell)
		charge_lock = "spell1"

	elif saved_spell_input == "spell2":
		var spell = spell2.instantiate()
		spell_creation(spell)
		charge_lock = "spell2"

	elif saved_spell_input == "spell3":
		var spell = spell3.instantiate()
		spell_creation(spell)
		charge_lock = "spell3"

	elif saved_spell_input == "spell4":
		var spell = spell4.instantiate()
		spell_creation(spell)
		charge_lock = "spell4"

	elif saved_spell_input == "spell5":
		var spell = spell5.instantiate()
		spell_creation(spell)
		charge_lock = "spell5"


#called from multiple places, stops spells forcibly
func cast_released():
	if saved_spell == null:
		pass
	
	elif saved_spell.is_in_group("stream"):
		saved_spell.emit = false
		$timers/spell_cooldown.start()
#		get_node("stream_sound").queue_free()
		saved_spell = null
		losing_charge = false
		exit_cast = true


# plays spell's audio, spawns the spell, reorders the spells position in the scene for
# visual layers, combo controls.
func spell_creation(spell):
	if spell.name != "empty":
		if spell.is_in_group("burst"):
			var spell_audio_player = spell_audio_scene.instantiate()
			spell_audio_player.stream = load("res://assets/sounds/%s_sound.mp3"%spell.name)
			add_child(spell_audio_player)
	
	$spell_spawn.position.x = 16 * last_direction
	$spell_spawn.position.y = -16
	spell.global_position = $spell_spawn.global_position
	spell.scale.x = last_direction
	add_sibling(spell)
	get_parent().move_child(spell,3)
	
	if spell.is_in_group("burst"):
		can_cast = false
		animation_lock = true
		if combo1_called == false:
			animated_sprite.play("combo1")
			$timers/can_cast_combo_timer.wait_time = 0.42
			$timers/can_cast_combo_timer.start()
			combo1_called = true
			$timers/combo_timer.start()

		elif combo2_called == false and $timers/combo_timer.time_left > 0:
			animated_sprite.play("combo2")
			$timers/can_cast_combo_timer.wait_time = 0.5
			$timers/can_cast_combo_timer.start()
			combo2_called = true
			$timers/combo_timer.start()

		elif combo3_called == false and $timers/combo_timer.time_left > 0:
			animated_sprite.play("combo3")
			$timers/can_cast_combo_timer.wait_time = 0.66667
			$timers/can_cast_combo_timer.start()
			combo2_called = false
			combo1_called = false
			$timers/combo_timer.stop()
		spell_type = "burst"
	
	elif spell.is_in_group("stream"):
		animated_sprite.play("combo3_start")
		animation_lock = true
		spell.hitbox_direction = last_direction
		saved_spell = spell
		spell_type = "stream"
		losing_charge = true


# controls tha basic left / right movement of the player
func basic_movement():
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	# checks if can move and if so accelerates player
	if state_machine.check_if_can_move():
		if direction:
			last_direction = direction
			if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
				velocity.x += direction * acceleration
				moving = true
		# if no inputs then deccelerates player
		else:
			velocity.x = int(lerpf(velocity.x,0.0,0.2))
			moving = false


# flips sprite based on direction and adjusts position so sprites line up with walls / collision
func sprite_position():
	$player_sprite.scale.x = -last_direction
	if last_direction == -1:
		$player_sprite.position.x = 5
	elif last_direction == 1:
		$player_sprite.position.x = -5
	
	if $player_sprite.animation == "wall_slide":
		$player_sprite.position.x -= 3 * last_direction
	else:
		$player_sprite.position.x -= 0 * last_direction


# the wall check function is called from the air state, each frame the number of detections
# is reset. If at least one of the raycasts collides then the player is near a wall and
# depending on which side of the player the colliding raycast is on will
# dictate which wall the player is near. If no raycasts collide then
# the player is not near any wall
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


# the safe ground check function is called from the air state, each frame the number of
# detections is reset. If all of the raycasts are colliding then the player's position is
# saved so it can return there is needed.
func safe_ground_check():
	var num_of_safe_checks = 0
	for check in safe_floor_folder:
		if check.is_colliding():
			num_of_safe_checks += 1
		else:
			pass
	if num_of_safe_checks == 2:
		safe_ground = global_position


# called from multiple states. If the player isnt on the ground accelerates them down
func gravity_applying(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 750:
			velocity.y = 750


# changes the players health
func health_update(health_change):
	if health_change != null:
		GlobalVar.character_health += health_change
		get_parent().get_node("HUD").get_node("health_bar").value = GlobalVar.character_health


# checks what has entered the player's hitbox and applies what should happen based on that.
func _on_enemyhitbox_area_entered(area):
	if area.is_in_group("enemy") and taken_damage == false:
		# get_parent as the data is stored in the characterbody, which the area is a child of
		var health_change = area.get_parent().damage
		knockback = area.get_parent().knockback
		# applies knockback
		if area.global_position.x < global_position.x:
			knockback_direction = 1
		elif area.global_position.x >= global_position.x:
			knockback_direction = -1
		# this changes the state to immunity
		taken_damage = true
		
		# applies the damage dealt
		health_update(health_change)
	
	elif area.is_in_group("boss") and taken_damage == false:
		# get_parents as data is stored in characterbody
		var health_change = area.get_parent().get_parent().get_parent().damage
		knockback = area.get_parent().get_parent().get_parent().knockback
		# applies knockback
		if area.get_parent().get_parent().get_parent().global_position.x < global_position.x:
			knockback_direction = 1
		elif area.get_parent().get_parent().get_parent().global_position.x >= global_position.x:
			knockback_direction = -1
		# this changes the state to immunity
		taken_damage = true
		
		# applies the damage dealt
		health_update(health_change)
	
	# if enters spikes / thorns
	elif area.is_in_group("environment_threat"):
		var health_change = -10
		knockback = 200
		velocity.x = -last_direction * 2 * knockback
		velocity.y = -knockback
		taken_damage = true
		health_update(health_change)
		# moves the player to the saved position from the safe ground check function
		reset_position = true
	
	# if enters an updraft sends the player into the air
	elif area.is_in_group("updraft"):
		velocity.y = -1100
		$player_sprite.play("fall_start")
		animation_lock = true


# if the player is reseting its position from entering thorns then the
# screen will flash black so the player can't see the teleport
func screen_effects():
	if reset_position == true:
		get_parent().get_node("HUD").get_node("screen_effect").modulate.a\
				= lerpf(get_parent().get_node("HUD").get_node("screen_effect")\
				.modulate.a, screen_target_opacity, 0.3)
		
		if get_parent().get_node("HUD").get_node("screen_effect").modulate.a > 0.3:
			if safe_ground != null:
				global_position = safe_ground
				velocity.x = 0
				velocity.y = 0
		if get_parent().get_node("HUD").get_node("screen_effect").modulate.a > 0.95:
			screen_target_opacity = 0
			$timers/screen_effect_timer.start()


# once the process of reset the player position has finished, resets everying
# so that it can happen again
func _on_screen_effect_timer_timeout():
	get_parent().get_node("HUD").get_node("screen_effect").modulate.a = 0
	reset_position = false
	screen_target_opacity = 1


# timing checks

# these 2 functions control the length of the dash
# called from dash state
func dash_start():
	$timers/is_dashing.start()


func _on_is_dashing_timeout():
	is_dashing_now = false
	$timers/dash_cooldown.start()


# controls when the player can coyote jump
# called from air state
func coyote_time():
	$timers/coyote_timer.start()


func _on_coyote_timer_timeout():
	coyote_jump = false


# when an animation finishes, allows for the next animation to play
func _on_player_sprite_animation_finished():
	animation_lock = false


# if the player takes too long to attack between combos, resets combo
func _on_combo_timer_timeout():
	combo3_called = false
	combo2_called = false
	combo1_called = false
	animation_lock = false


# controls how fast spells can be cast
func _on_spell_cooldown_timeout():
	can_cast = true


# resets collision once immunity finished
func _on_immunity_frame_timer_timeout():
	taken_damage = false
	collision_layer = 2
	collision_layer != 4
	collision_mask = 3
	if hitbox_collision.disabled == true:
		hitbox_collision.disabled = false


# controls timing on when can cast during combo
func _on_can_cast_combo_timer_timeout():
	if can_cast == false:
		can_cast = true


# stops being able to spam dash while on the ground
func _on_dash_cooldown_timeout():
	ground_can_dash = true

# controls the timing of footstep sounds
func _on_player_sprite_animation_changed():
	audio_timer_called = false


# controls the timing of footstep sounds
func _on_sound_timer_timeout():
	audio_timer_called = false
