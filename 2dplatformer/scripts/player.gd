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
@onready var chargerbar_folder = get_parent().get_node("HUD").get_node("spell_charge_bar_folder").get_children()
@onready var animated_sprite : AnimatedSprite2D = $player_sprite
@onready var hitbox_collision : CollisionShape2D = $enemyhitbox/hitbox_collision
@onready var safe_floor_folder := $safe_floor_check_folder.get_children()

@export var inventory_scene : PackedScene
@export var spell_audio_scene : PackedScene
@export var audio_player : PackedScene
@export var jump_force = 250.0
@export var maxspeed = 125
@export var acceleration = 30
@export var health = 2000
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Get the gravity from the project settings to be synced with RigidBody nodes.
var movement_state = "normal"
var last_direction = 1
var health_change
var taken_damage = false
var knockback
var knockback_direction = 1

var safe_ground = Vector2.ZERO
var reset_position = false
var screen_target_opacity = 1

var saved_spell_input
var equiped_spells = []
var spell1
var spell2
var spell3
var spell4
var spell5
var created_spells = []
var saved_spell
var losing_charge = false
var can_cast = true
var casting = false
var spell_movement = false
var stop_stream = false
var spell_type
var charge_lock
var exit_cast = false

var audio_timer_called = false

var near_wall = false
var near_right_wall = false
var near_left_wall = false

var can_dash = true 
var is_dashing_now = false
var ground_can_dash = true

var coyote_jump = false
var previous_state = ""

var moving = false
var animation_lock = false
var combo1_called = false
var combo2_called = false
var combo3_called = false
#var sword = sword_scene.instantiate()

func _ready():
	set_spells()
	camera_update()
	if GlobalVar.play_respawn_sound == true:
		play_sound("respawn")
		GlobalVar.play_respawn_sound = false

func camera_update():
	$Camera2D.limit_left = get_parent().camera_limit_left
	$Camera2D.limit_right = get_parent().camera_limit_right
	$Camera2D.limit_top = get_parent().camera_limit_up
	$Camera2D.limit_bottom = get_parent().camera_limit_down


func _physics_process(delta):
	HUD_update()
	basic_movement()
	sprite_position()
	healthcheck()
	screen_effects()
	play_walk_sound()
	move_and_slide()
	


func set_spells():
	equiped_spells = GlobalVar.equipped_spells

	spell1 = load("res://scenes/spells/%s.tscn" %equiped_spells[0])
	spell2 = load("res://scenes/spells/%s.tscn" %equiped_spells[1])
	spell3 = load("res://scenes/spells/%s.tscn" %equiped_spells[2])
	spell4 = load("res://scenes/spells/%s.tscn" %equiped_spells[3])
	spell5 = load("res://scenes/spells/%s.tscn" %equiped_spells[4])

func play_walk_sound():
	if $player_sprite.animation == "run" and audio_timer_called == false:
		$timers/walk_sound_timer.wait_time = float(4.5)/12
		audio_timer_called = true
		var audio = audio_player.instantiate()
		audio.stream = load("res://assets/sounds/walk_sound.mp3")
		$sounds.add_child(audio)
		$timers/walk_sound_timer.start()

func play_sound(sound):
	var audio = audio_player.instantiate()
	audio.stream = load("res://assets/sounds/%s_sound.mp3"%sound)
	$sounds.add_child(audio)

func _on_sound_timer_timeout():
	audio_timer_called = false

func HUD_update():
	get_parent().get_node("HUD").get_node("state_debug_label").text = "state = " + state_machine.current_state.name
	get_parent().get_node("HUD").get_node("fps_debug_label").text = "fps = " + str(Engine.get_frames_per_second())
	
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
			get_parent().get_node("HUD").get_node("spell_charge_bar_folder").get_node("spell1_charge_bar").value -= saved_spell.charge_decrease
		if Input.is_action_pressed("spell2") and charge_lock == "spell2":
			get_parent().get_node("HUD").get_node("spell_charge_bar_folder").get_node("spell2_charge_bar").value -= saved_spell.charge_decrease
		if Input.is_action_pressed("spell3") and charge_lock == "spell3":
			get_parent().get_node("HUD").get_node("spell_charge_bar_folder").get_node("spell3_charge_bar").value -= saved_spell.charge_decrease
		if Input.is_action_pressed("spell4") and charge_lock == "spell4":
			get_parent().get_node("HUD").get_node("spell_charge_bar_folder").get_node("spell4_charge_bar").value -= saved_spell.charge_decrease
		if Input.is_action_pressed("spell5") and charge_lock == "spell5":
			get_parent().get_node("HUD").get_node("spell_charge_bar_folder").get_node("spell5_charge_bar").value -= saved_spell.charge_decrease

func start_spells(): #plays once when entering casting state
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

func cast_released():
	if saved_spell == null:
		pass
	
	elif saved_spell.is_in_group("stream"):
		saved_spell.emit = false
		$timers/spell_cooldown.start()
		get_node("stream_sound").queue_free()
		saved_spell = null
		losing_charge = false
		exit_cast = true


func spell_creation(spell):
	if spell.name != "empty":
		var spell_audio_player = spell_audio_scene.instantiate()
		
		spell_audio_player.stream = load("res://assets/sounds/%s_sound.mp3"%spell.name)
		if spell.is_in_group("stream"):
			spell_audio_player.name = "stream_sound"
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


func basic_movement():
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	if state_machine.check_if_can_move():
		if direction:
			last_direction = direction
			if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
				velocity.x += direction * acceleration
				moving = true
		
		else: #if no input
			velocity.x = int(lerpf(velocity.x,0.0,0.2)) #decelerates the player towards zero
			moving = false #called in ground state for animations

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

func wall_check(): #called during air state
	var num_of_false_check = 0 #resets number of detections at the start of eacah frame
	
	for check in right_wall_check_folder: #runs for however many raycasts in the right wall check folder
		var ray : RayCast2D = check #sets var as a raycast2D
		if ray.is_colliding():
			near_wall = true
			near_right_wall = true
			break #stops wall check as it is true
		elif !ray.is_colliding():
			num_of_false_check +=1
			near_right_wall = false
	
	for check in left_wall_check_folder: #runs for however many raycasts in the left wall check folder
		var ray : RayCast2D = check #sets var as a raycast2D
		if ray.is_colliding():
			near_wall = true
			near_left_wall = true
			break #stops wall check as it is true
		elif !ray.is_colliding():
			num_of_false_check +=1
			near_left_wall = false
	
	if num_of_false_check == 4: #if all 4 checks return false then character is not near a wall
		near_wall = false


func safe_ground_check(): #searches for safe ground to return to if hit by environmental damaga
	#could optimize to run every 5 frames or so
	
	var num_of_safe_checks = 0 #resets number of detections at the start of eacah frame
	for check in safe_floor_folder: #runs for however many raycasts in the safe floor check folder
		if check.is_colliding():
			num_of_safe_checks += 1
		else:
			pass
	if num_of_safe_checks == 2: #if all of the checks return then the next line runs
		safe_ground = global_position #saves the position to return to if needed

func gravity_applying(delta):
	if !is_on_floor(): #checks if player is in the air
		velocity.y += gravity * delta #if true accelerates player down
		if velocity.y > 750:
			velocity.y = 750




func healthcheck():
	pass
#		pass
#		$enemyhitbox/hitbox_collision.disabled = true
#		get_tree().change_scene_to_file("res://scenes/title_screen_scenes/titlescreen.tscn")
#		GlobalVar.reset()


func health_update():
	if health_change != null:
		GlobalVar.character_health += health_change
		get_parent().get_node("HUD").get_node("health_bar").value = GlobalVar.character_health




func _on_enemyhitbox_area_entered(area):
	if area.is_in_group("enemy") and taken_damage == false:
		health_change = area.get_parent().damage
		knockback = area.get_parent().knockback
		if area.global_position.x < global_position.x:
			knockback_direction = 1
		elif area.global_position.x >= global_position.x:
			knockback_direction = -1
		taken_damage = true
		
		health_update()
	
	if area.is_in_group("boss") and taken_damage == false:
		health_change = area.get_parent().get_parent().get_parent().damage
		knockback = area.get_parent().get_parent().get_parent().knockback
		if area.get_parent().get_parent().get_parent().global_position.x < global_position.x:
			knockback_direction = 1
		elif area.get_parent().get_parent().get_parent().global_position.x >= global_position.x:
			knockback_direction = -1
		taken_damage = true
		
		health_update()
	
	elif area.is_in_group("environment_threat"):
		health_change = -10
		knockback = 200
		velocity.x = -last_direction * 2 * knockback
		velocity.y = -knockback
		taken_damage = true
		health_update()
		reset_position = true
		
	elif area.is_in_group("updraft"):
		velocity.y = -1100
		$player_sprite.play("fall_start")
		animation_lock = true

func screen_effects():
	if reset_position == true:
		get_parent().get_node("HUD").get_node("screen_effect").modulate.a = lerpf(get_parent().get_node("HUD").get_node("screen_effect").modulate.a, screen_target_opacity, 0.3)
		
		if get_parent().get_node("HUD").get_node("screen_effect").modulate.a > 0.3:
			if safe_ground != null:
				global_position = safe_ground
				velocity.x = 0
				velocity.y = 0
		if get_parent().get_node("HUD").get_node("screen_effect").modulate.a > 0.95:
			screen_target_opacity = 0
			$timers/screen_effect_timer.start()

func _on_screen_effect_timer_timeout():
	get_parent().get_node("HUD").get_node("screen_effect").modulate.a = 0
	reset_position = false
	screen_target_opacity = 1










#timing checks



func dash_start():
	$timers/is_dashing.start()

func _on_is_dashing_timeout():
	is_dashing_now = false
	$timers/dash_cooldown.start()

func coyote_time():
	$timers/coyote_timer.start()

func _on_coyote_timer_timeout():
	coyote_jump = false

func _on_player_sprite_animation_finished():
	animation_lock = false
	

func _on_combo_timer_timeout():
	combo3_called = false
	combo2_called = false
	combo1_called = false
	animation_lock = false

func _on_spell_cooldown_timeout():
	can_cast = true


func _on_immunity_frame_timer_timeout():
	taken_damage = false
	collision_layer = 2
	collision_layer != 4
	collision_mask = 3
	if hitbox_collision.disabled == true:
		hitbox_collision.disabled = false





func _on_can_cast_combo_timer_timeout():
	if can_cast == false:
		can_cast = true


func _on_dash_cooldown_timeout():
	ground_can_dash = true





func _on_player_sprite_animation_changed():
	audio_timer_called = false
