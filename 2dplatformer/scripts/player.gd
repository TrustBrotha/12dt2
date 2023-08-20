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


@export var jump_force = 250.0
@export var maxspeed = 125
@export var acceleration = 30
@export var health = 2000
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Get the gravity from the project settings to be synced with RigidBody nodes.
var movement_state = "normal"
var last_direction = 1
var health_change
var taken_damage = false

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

var near_wall = false
var near_right_wall = false
var near_left_wall = false

var can_dash = true 
var is_dashing_now = false

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

func _physics_process(delta):
	HUD_update()
	basic_movement()
	sprite_position()
	healthcheck()
	screen_effects()
	move_and_slide()


func set_spells():
	var all_spells = ["fireburst", "airburst", "firestream", "waterstream", "lightningstream"]
	equiped_spells = ["fireburst", "airburst", "firestream", "waterstream", "lightningstream"]

	spell1 = load("res://scenes/spells/%s.tscn" %equiped_spells[0])
	spell2 = load("res://scenes/spells/%s.tscn" %equiped_spells[1])
	spell3 = load("res://scenes/spells/%s.tscn" %equiped_spells[2])
	spell4 = load("res://scenes/spells/%s.tscn" %equiped_spells[3])
	spell5 = load("res://scenes/spells/%s.tscn" %equiped_spells[4])



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
		if saved_spell is GPUParticles2D:
			saved_spell.emitting = false
		elif saved_spell is AnimatedSprite2D:
			saved_spell.stop()
			saved_spell.hide()
		$timers/spell_timer.wait_time = saved_spell.deletion_wait_time
		$timers/spell_timer.start()
		$timers/spell_cooldown.start()
		saved_spell = null
		losing_charge = false

func spell_creation(spell):
	$spell_spawn.position.x = 16 * last_direction
	$spell_spawn.position.y = -16
	spell.global_position = $spell_spawn.global_position
	spell.scale.x = last_direction
	add_sibling(spell)
#	get_parent().move_child(spell,3)
	created_spells.append(spell)
	
	if spell is GPUParticles2D:
		spell.emitting = true
	if spell.is_in_group("burst"):
		can_cast = false
		animation_lock = true
		if combo1_called == false:
			animated_sprite.play("combo1")
			combo1_called = true
			$timers/combo_timer.start()
			
		elif combo2_called == false and $timers/combo_timer.time_left > 0:
			animated_sprite.play("combo2")
			combo2_called = true
			$timers/combo_timer.start()
			
		elif combo3_called == false and $timers/combo_timer.time_left > 0:
			animated_sprite.play("combo3")
			combo2_called = false
			combo1_called = false
			$timers/combo_timer.stop()
		
		$timers/spell_timer.wait_time = spell.deletion_wait_time
		$timers/spell_timer.start()
		spell_type = "burst"
	elif spell.is_in_group("stream"):
		animated_sprite.play("combo3_start")
		animation_lock = true
		spell.hitbox_direction = last_direction
		saved_spell = spell
		spell_type = "stream"
		losing_charge = true

func _on_spell_timer_timeout():
	for spell in created_spells:
		if spell.is_in_group("burst"):
			spell.queue_free()
			created_spells.erase(spell)

		elif spell.is_in_group("stream"):
			created_spells.erase(spell)
			spell.extension_time = true

func basic_movement():
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	if state_machine.check_if_can_move():
		if direction:
			last_direction = direction
			if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
				velocity.x += direction * acceleration
				moving = true
		
		
		else:
			velocity.x = int(lerpf(velocity.x,0.0,0.2))
			moving = false

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


func safe_ground_check():
	var num_of_safe_checks = 0
	for check in safe_floor_folder:
		if check.is_colliding():
			num_of_safe_checks += 1
		else:
			pass
	if num_of_safe_checks == 2:
		safe_ground = global_position

func gravity_applying(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 2000:
			velocity.y = 2000




func healthcheck():
	if get_parent().get_node("HUD").get_node("health_bar").value <= 0:
		get_tree().change_scene_to_file("res://scenes/title_screen_scenes/titlescreen.tscn")


func health_update():
	if health_change != null:
		get_parent().get_node("HUD").get_node("health_bar").value += health_change




func _on_enemyhitbox_area_entered(area):
	if area.is_in_group("enemy") and taken_damage == false:
		health_change = area.get_parent().damage
		var knockback = area.get_parent().knockback
		velocity.x = -last_direction * knockback
		velocity.y = -knockback
		taken_damage = true
		
		health_update()
	
	elif area.is_in_group("environment_threat"):
		health_change = -10
		var knockback = 200
		velocity.x = -last_direction * 2 * knockback
		velocity.y = -knockback
		taken_damage = true
		health_update()
		reset_position = true
		
	elif area.is_in_group("finish_line"):
		get_tree().change_scene_to_file("res://scenes/title_screen_scenes/titlescreen.tscn")

func screen_effects():
	if reset_position == true:
		
		get_parent().get_node("environment_effect").modulate.a = lerpf(get_parent().get_node("environment_effect").modulate.a, screen_target_opacity, 0.3)
		
		if get_parent().get_node("environment_effect").modulate.a > 0.3:
			if safe_ground != null:
				global_position = safe_ground
				velocity.x = 0
				velocity.y = 0
		if get_parent().get_node("environment_effect").modulate.a > 0.95:
			screen_target_opacity = 0
			$timers/screen_effect_timer.start()

func _on_screen_effect_timer_timeout():
	get_parent().get_node("environment_effect").modulate.a = 0
	reset_position = false
	screen_target_opacity = 1


func _on_enemyhitbox_area_exited(area):
	pass








#timing checks



func dash_start():
	$timers/is_dashing.start()

func _on_is_dashing_timeout():
	is_dashing_now = false

func coyote_time():
	$timers/coyote_timer.start()

func _on_coyote_timer_timeout():
	coyote_jump = false

func _on_player_sprite_animation_finished():
	animation_lock = false
	if can_cast == false:
		can_cast = true

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





