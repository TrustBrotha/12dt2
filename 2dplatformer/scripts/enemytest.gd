extends CharacterBody2D


const speed = 50.0
const jump_velocity = -400.0
var speedchange = 1
var moving = true
var direction = 1
var health = 1000
var debuff = "clear"
var damage = -10
var knockback = 300

var movement_state = "moving"
var animation_lock = false
var attack_lock = false
var attack_timer_called = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	damage = -10


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if health <= 0:
		queue_free()
	
	
	
	pathfinding()
	states()
	
	
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
	if movement_state == "attack":
		$raycastwallcheck.enabled = false
		attack()


func movement():
	$raycastfloorcheck.position.x = direction * 16
	$raycastwallcheck.scale.y = direction
	$vision/vision_shape.position.x = 26 * direction
	$AnimatedSprite2D.scale.x = -direction
	if animation_lock == false:
		$AnimatedSprite2D.play("move")
		animation_lock = true
	
	
	
	velocity.x = direction * speed * speedchange
	

func attack():
	if attack_timer_called == false:
		$attack_timer.start()
		attack_timer_called = true
	velocity.x += 10 * direction

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






func _on_area_2d_area_entered(area):
	#note, the effect_tests will be replaced when animated sprites are added, thus the timer will also be removed and changed to on animation end.
	
	pass
	
#	if area.has_meta("weapon"):
#		health -= 50
#
#	if area.has_meta("fire") and debuff == "clear":
#		$fire_effect_test.visible = true
#		$debuff_cooldown.start()
#		debuff = "burning"
#	elif area.has_meta("water") and debuff == "clear":
#		$water_effect_test.visible = true
#		$debuff_cooldown.start()
#		debuff = "wet"
#	elif area.has_meta("lightning") and debuff == "clear":
#		$lightning_effect_test.visible = true
#		$debuff_cooldown.start()
#		debuff = "electrocuted"
#	elif (area.has_meta("fire") and debuff == "wet") or (area.has_meta("water") and debuff == "burning"):
#		$steam_effect_test.visible = true
#		$debuff_cooldown.start()
#		debuff = "steam"
#	#more combos added here
#
#func manage_debuffs():
#	if debuff == "burning":
#		health -= 1
#	elif debuff == "wet":
#		speedchange = 0.3
#	elif debuff == "electrocuted":
#		speedchange = 0.5
#	elif debuff == "steam":
#		health -= 100
#		debuff = "clear"
#		$fire_effect_test.visible = false
#		$water_effect_test.visible = false
#
#func _on_debuff_cooldown_timeout():
#	debuff = "clear"
#	$steam_effect_test.visible = false
#	$fire_effect_test.visible = false
#	$water_effect_test.visible = false
#	$lightning_effect_test.visible = false
#	speedchange = 1
#








func _on_animated_sprite_2d_animation_finished():
	animation_lock = false



