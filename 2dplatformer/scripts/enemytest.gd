extends CharacterBody2D


const accel = 10
const jump_velocity = -400.0

@onready var particle_effect_folder = $paricle_folder.get_children()


var speedchange = 1
var moving = true
var direction = 1
var health = 1000
var debuff = "clear"
var damage = -10
var knockback = 300
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


func _physics_process(delta):
#	print($Control/healthbar.value)
#	print($AnimatedSprite2D.animation)
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if $Control/healthbar.value <= 0:
		$AnimatedSprite2D.play("death")
		
	
	
	pathfinding()
	states()
	immunity()
	apply_debuffs()
	move_and_slide()


func pathfinding():
	if $raycastfloorcheck.is_colliding() == false:
		direction *= -1
	elif $raycastwallcheck.is_colliding() == true:
		if $raycastfloorcheck.get_collider().is_in_group("tile"):
			direction *= -1

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

func attack():
	if attack_timer_called == false:
		velocity.x = 0
		$attack_timer.start() 
		attack_timer_called = true
	if $attack_timer.time_left <= $attack_timer.wait_time / 2:
		velocity.x += 40 * direction

func _on_attack_timer_timeout():
	movement_state = "moving"

func _on_vision_area_entered(area):
	if area.is_in_group("player") and attack_lock == false:
		attack_lock = true
		movement_state = "attack"
		velocity.x = 0.1 * direction
		$AnimatedSprite2D.play("attack")

func _on_vision_area_exited(area):
	if area.is_in_group("player"):
		attack_timer_called = false
		attack_lock = false
		movement_state = "moving"



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
	


func _on_hitbox_area_entered(area):
	if immune == false:
		if area.is_in_group("stream_collision"):
			immune = true
			var spell_scene = area
			apply_spell(spell_scene)
			
		elif area.is_in_group("burst_collision"):
			immune = true
			var spell_scene = area.get_parent()
			apply_spell(spell_scene)


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
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("water"):
			debuff = "wet"
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("lightning"):
			debuff = "shocked"
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("earth"):
			debuff = "stunned"
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("ice"):
			debuff = "frozen"
			$debuff_cooldown.start()

#func damaged():
	
	

func apply_debuffs():
	if debuff != "clear":
		if debuff == "burning":
			$Control/healthbar.value -= 0.25
			$paricle_folder/burning_particles.emitting = true
		elif debuff == "wet":
			speedchange = 0.5
			$paricle_folder/water_particles.emitting = true
		elif debuff == "shocked":
			pass
		elif debuff == "stunned":
			pass
		elif debuff == "frozen":
			pass


func _on_debuff_cooldown_timeout():
	debuff = "clear"
	speedchange = 1
	for effect in particle_effect_folder:
		if effect.emitting == true:
			effect.emitting = false

func _on_animated_sprite_2d_animation_finished():
	animation_lock = false
	if movement_state == "damaged":
		movement_state = "moving"
	if $AnimatedSprite2D.animation == "death":
		queue_free()








