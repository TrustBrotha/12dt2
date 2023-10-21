extends CharacterBody2D


const accel = 5
const jump_velocity = -400.0

@onready var particle_effect_folder = $paricle_folder.get_children()

var frost_buildup = 0
var speedchange = 1
var moving = true
var direction = 1
var health = 1000
var debuff = "clear"
var damage = -10
var knockback = 170
var immune = false
var immunity_frames_called = false

var movement_state = "moving"
var animation_lock = false
var attack_lock = false
var attack_timer_called = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	damage = -10
	$slime_audio.volume_db = GlobalVar.sound_effect_volume - 5
	$slime_audio.stream = load("res://assets/sounds/slime_move_sound.mp3")
	$slime_audio.play()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#check if dead
	if $Control/healthbar.value <= 0:
		$hitbox/hitbox_collision.disabled = true
		$vision/vision_shape.disabled = true
		$AnimatedSprite2D.play("death")
	
	# debuff check
	if frost_buildup >= 50:
		debuff = "frozen"
		$debuff_cooldown.wait_time = 2
		$debuff_cooldown.start()
		$paricle_folder/frozen_particles1.emitting = true
		$paricle_folder/frozen_particles2.emitting = true
		$paricle_folder/frozen_particles3.emitting = true
		frost_buildup = 0
	
	# check if dead if not run like normal
	if $Control/healthbar.value <= 0:
		$hitbox/hitbox_collision.disabled = true
		$vision/vision_shape.disabled = true
		$AnimatedSprite2D.play("death")
	
	elif $Control/healthbar.value > 0:
		pathfinding()
		states()
		immunity()
		apply_debuffs()
	move_and_slide()


# flipping if sees wall / edge
func pathfinding():
	if $raycastfloorcheck.is_colliding() == false:
		direction *= -1
	elif $raycastwallcheck.is_colliding() == true:
		if $raycastfloorcheck.get_collider().is_in_group("tile"):
			direction *= -1


#controls physics
func states():
	if movement_state == "moving":
		$raycastwallcheck.enabled = true
		movement()
	elif movement_state == "attack":
		$raycastwallcheck.enabled = false
		attack()
	elif movement_state == "damaged":
		pass
#		$raycastwallcheck.enabled = true
#		movement()


#controls how the slime accelerates 
func movement():
	$raycastfloorcheck.position.x = direction * 16
	$raycastwallcheck.scale.y = direction
	$vision/vision_shape.position.x = 26 * direction
	$AnimatedSprite2D.scale.x = -direction
	if animation_lock == false:
		$AnimatedSprite2D.play("move")
		animation_lock = true
	
	velocity.x += direction * accel * speedchange
	velocity.x = lerpf(velocity.x, 0 , 0.1)


# controls how the attacking works
func attack():
	if attack_timer_called == false:
		velocity.x = 0
		$attack_timer.start() 
		attack_timer_called = true
	if $attack_timer.time_left <= $attack_timer.wait_time / 2:
		velocity.x += 40 * direction


# once finished attacking returns to normal
func _on_attack_timer_timeout():
	movement_state = "moving"
	attack_timer_called = false
	$attack_cooldown_timer.start()


# controls when can attack
func _on_attack_cooldown_timer_timeout():
	attack_lock = false


# detection for when to attack
func _on_vision_area_entered(area):
	if area.is_in_group("player") and attack_lock == false:
		attack_lock = true
		movement_state = "attack"
		velocity.x = 0.1 * direction
		$AnimatedSprite2D.play("attack")
		$slime_audio.stream = load("res://assets/sounds/slime_hiss_sound.mp3")
		$slime_audio.play()


# control for if immune or not and conrolling hitboxes
func immunity():
	if immune == true and immunity_frames_called == false:
		immunity_frames_called = true
		$immunity_frame_timer.start()
		$hitbox/hitbox_collision.disabled = true
	elif immune == false:
		$hitbox/hitbox_collision.disabled = false



func _on_immunity_frame_timer_timeout():
	immune = false
	immunity_frames_called = false


# detection for spells / environment / player
func _on_hitbox_area_entered(area):
	if immune == false:
		if area.is_in_group("stream_collision"):
			immune = true
			var spell_scene = area
			apply_spell(spell_scene)
			$slime_audio.stream = load("res://assets/sounds/slime_hit_sound.mp3")
			$slime_audio.play()
		elif area.is_in_group("burst_collision"):
			immune = true
			var spell_scene = area.get_parent()
			apply_spell(spell_scene)
			$slime_audio.stream = load("res://assets/sounds/slime_hit_sound.mp3")
			$slime_audio.play()
		
	if area.is_in_group("environment_threat"):
		$Control/healthbar.value = 0
		$slime_audio.stream = load("res://assets/sounds/slime_hit_sound.mp3")
		$slime_audio.play()
	if area.is_in_group("player"):
		velocity.x = 0


# applying the effect of the spell
func apply_spell(spell_scene):
	$AnimatedSprite2D.play("damaged")
	if spell_scene.global_position.x >= global_position.x:
		velocity.x += -spell_scene.knockback
	elif spell_scene.global_position.x < global_position.x:
		velocity.x += spell_scene.knockback
	
	$Control/healthbar.value -= spell_scene.damage
	
	if debuff == "clear":
		if spell_scene.is_in_group("fire"):
			debuff = "burning"
			$debuff_cooldown.wait_time = 1
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("water"):
			debuff = "wet"
			$debuff_cooldown.wait_time = 2
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("lightning"):
			debuff = "shocked"
			$debuff_cooldown.wait_time = 1
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("earth"):
			debuff = "stunned"
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("ice"):
			frost_buildup += 10


# applying the effect of each debuff
func apply_debuffs():
	if debuff != "clear":
		if debuff == "burning":
			$Control/healthbar.value -= 0.25
			$paricle_folder/burning_particles.emitting = true
		elif debuff == "wet":
			speedchange = 0.5
			$paricle_folder/water_particles.emitting = true
		elif debuff == "shocked":
			$paricle_folder/shocked_particles.emitting = true
			$vision/vision_shape.disabled = true
		elif debuff == "stunned":
			pass
		elif debuff == "frozen":
			speedchange = 0
			$vision/vision_shape.disabled = true


# reseting debuffs
func _on_debuff_cooldown_timeout():
	debuff = "clear"
	speedchange = 1
	if $vision/vision_shape.disabled == true:
		$vision/vision_shape.disabled = false
	for effect in particle_effect_folder:
		if effect.emitting == true:
			effect.emitting = false


# controlling animation
func _on_animated_sprite_2d_animation_finished():
	animation_lock = false
	if movement_state == "damaged":
		movement_state = "moving"
	if $AnimatedSprite2D.animation == "death":
		queue_free()






func _on_hit_effect_timer_timeout():
	pass # Replace with function body.


# controls slime more sound loop
func _on_audio_stream_player_2d_finished():
	$slime_audio.stream = load("res://assets/sounds/slime_move_sound.mp3")
	$slime_audio.play()
