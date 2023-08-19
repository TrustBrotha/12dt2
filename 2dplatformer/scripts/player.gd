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
@export var jump_force = 250.0
@export var maxspeed = 125
@export var acceleration = 30
@export var health = 2000
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Get the gravity from the project settings to be synced with RigidBody nodes.
var movement_state = "normal"
var last_direction = 1

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
#var sword = sword_scene.instantiate()

func _ready():
	set_spells()

func _physics_process(delta):
	
	HUD_update()
	basic_movement()
	healthcheck()
	move_and_slide()



func set_spells():
	var all_spells = ["fireburst", "airburst", "firestream", "waterstream", "lightningstream"]
	equiped_spells = ["firestream", "airburst", "firestream", "waterstream", "lightningstream"]

	spell1 = load("res://scenes/spells/%s.tscn" %equiped_spells[0])
	spell2 = load("res://scenes/spells/%s.tscn" %equiped_spells[1])
	spell3 = load("res://scenes/spells/%s.tscn" %equiped_spells[2])
	spell4 = load("res://scenes/spells/%s.tscn" %equiped_spells[3])
	spell5 = load("res://scenes/spells/%s.tscn" %equiped_spells[4])



func HUD_update():
	get_parent().get_node("HUD").get_node("state_debug_label").text = "state = " + state_machine.current_state.name
	
	
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
	$spell_spawn.position.x = 200 * last_direction
	$spell_spawn.position.y = -75
	spell.global_position = $spell_spawn.global_position
	spell.scale.x = last_direction
	add_sibling(spell)
	created_spells.append(spell)
	
	if spell is GPUParticles2D:
		spell.emitting = true
	if spell.is_in_group("burst"):
		$timers/spell_timer.wait_time = spell.deletion_wait_time
		$timers/spell_timer.start()
		$timers/spell_cooldown.start()
		spell_type = "burst"
	elif spell.is_in_group("stream"):
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


func _on_spell_cooldown_timeout():
	can_cast = true



#func movement_states(delta):
#	elif movement_state == "swimming":
#
#		velocity.x = clamp(velocity.x,(-0.25 *maxspeed),(0.25 *maxspeed))
#		velocity.y = clamp(velocity.y,(-0.25 *maxspeed),(0.25 *maxspeed))
##		can_jump = false
#		if Input.is_action_pressed("up") or Input.is_action_pressed("jump"):
#			velocity.y -= acceleration
#		elif Input.is_action_pressed("down"):
#			velocity.y += acceleration
#		else:
#			velocity.y = int(lerpf(velocity.y,0.0,0.2))

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









func healthcheck():
	if health <= 0:
		pass







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





