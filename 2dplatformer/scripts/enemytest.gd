extends CharacterBody2D


const speed = 50.0
const jump_velocity = -400.0
var speedchange = 1
var moving = true
var direction = 1
var health = 1000
var debuff = "clear"


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	#movement
	$raycastfloorcheck.position.x = direction * 80
	$raycastwallcheck.scale.x = direction
	$raycastwallcheck.scale.y = direction
	if $raycastfloorcheck.is_colliding() == false:
		direction *= -1
	elif $raycastwallcheck.is_colliding() == true:
		direction *= -1
		
	if moving == true:
		velocity.x = direction * speed * speedchange
	
	if health <= 0:
		queue_free()
	
	manage_debuffs()

	move_and_slide()



func _on_area_2d_area_entered(area):
	#note, the effect_tests will be replaced when animated sprites are added, thus the timer will also be removed and changed to on animation end.
	
	
	if area.has_meta("weapon"):
		health -= 50
	
	if area.has_meta("fire") and debuff == "clear":
		$fire_effect_test.visible = true
		$debuff_cooldown.start()
		debuff = "burning"
	elif area.has_meta("water") and debuff == "clear":
		$water_effect_test.visible = true
		$debuff_cooldown.start()
		debuff = "wet"
	elif area.has_meta("lightning") and debuff == "clear":
		$lightning_effect_test.visible = true
		$debuff_cooldown.start()
		debuff = "electrocuted"
	elif (area.has_meta("fire") and debuff == "wet") or (area.has_meta("water") and debuff == "burning"):
		$steam_effect_test.visible = true
		$debuff_cooldown.start()
		debuff = "steam"
	#more combos added here

func manage_debuffs():
	if debuff == "burning":
		health -= 1
	elif debuff == "wet":
		speedchange = 0.3
	elif debuff == "electrocuted":
		speedchange = 0.5
	elif debuff == "steam":
		health -= 100
		debuff = "clear"
		$fire_effect_test.visible = false
		$water_effect_test.visible = false

func _on_debuff_cooldown_timeout():
	debuff = "clear"
	$steam_effect_test.visible = false
	$fire_effect_test.visible = false
	$water_effect_test.visible = false
	$lightning_effect_test.visible = false
	speedchange = 1
	
