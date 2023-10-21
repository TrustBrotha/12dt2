extends CharacterBody2D

#603,282
var all_options = ["power_up","idle","move","turn_left_to_right","turn_right_to_left","death","burst_attack","ground_punch","lazer_attack","spin","steam_burst"]
var left_to_do = ["turn_left_to_right","turn_right_to_left","death"]
# Called when the node enters the scene tree for the first time.
@onready var next_animation = "power_up"
@onready var attack_areas = $turnables/attack_hitboxes.get_children()
@onready var particle_effect_folder = $particle_folder.get_children()
@export var boulder_scene : PackedScene
var damage = -20
var knockback = 150
var debuff = "clear"
var immune = false
var immunity_timer_called = false
var immune_effect_called = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var moving = false
var accel = 10
var speedchange = 1
var player_infront = false
var player_under = false
var player_to_the_right = true
var player_to_the_left = false
var wait_timer_called = false
var health = 1000
var dead = false
func _ready():
	get_parent().get_node("HUD").get_node("boss_health_bar").visible = true
	$turnables/AnimatedSprite2D.play("power_up")
	next_animation = "idle"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0 and dead == false:
		dead = true
		$turnables/AnimatedSprite2D.play("death")
		get_parent().get_node("HUD").get_node("boss_health_bar").visible = false
		GlobalVar.golem_defeated = true
		get_parent().close_door = false
	if dead == true and $turnables/AnimatedSprite2D.animation != "death":
		$turnables/AnimatedSprite2D.play("death")
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	if moving == true:
		if player_to_the_right == true:
			velocity.x += 1 * accel * speedchange
			velocity.x = lerpf(velocity.x, 0 , 0.1)
		elif player_to_the_left == true:
			velocity.x -= 1 * accel * speedchange
			velocity.x = lerpf(velocity.x, 0 , 0.1)
	elif moving == false:
		velocity.x = lerpf(velocity.x, 0 , 0.1)
	immunity()
	apply_debuffs()
	get_parent().get_node("HUD").get_node("boss_health_bar").value = (health/10)
	
	move_and_slide()

func _on_decision_timer_timeout():
	action_decision()
	$turnables/AnimatedSprite2D.play(next_animation)
	wait_timer_called = false






func immunity():
	if immune == true and immunity_timer_called == false:
		immunity_timer_called = true
		$immunity_frame_timer.start()
		$hitbox/CollisionShape2D.disabled = true
	elif immune == false:
		$hitbox/CollisionShape2D.disabled = false
	
	if $hitbox/CollisionShape2D.disabled == true:
		if immune_effect_called == false:
			$turnables/AnimatedSprite2D.modulate = Color(100,100,100)
			$damaged_effect_timer.start()
			immune_effect_called = true
	elif $hitbox/CollisionShape2D.disabled == false:
		immune_effect_called = false

func _on_damaged_effect_timer_timeout():
	$turnables/AnimatedSprite2D.modulate = Color(1,1,1)

func _on_immunity_frame_timer_timeout():
	immune = false
	immunity_timer_called = false








func action_decision():
	if player_infront == true:
		var options = ["steam_burst","lazer_attack"]
		var choice = randi_range(0,1)
		next_animation = options[choice]
		if next_animation == "steam_burst":
			$attack_collision_timer.wait_time = 0.8333
			$attack_collision_timer.start()
		elif next_animation == "lazer_attack":
			$attack_collision_timer.wait_time = 0.9166
			$attack_collision_timer.start()
		
	
	
	elif player_under == true:
		var options = ["burst_attack","burst_attack","ground_punch","ground_punch","spin"]
		var choice = randi_range(0,4)
		next_animation = options[choice]
		if next_animation == "burst_attack":
			$attack_collision_timer.wait_time = 0.5833
			$attack_collision_timer.start()
		elif next_animation == "ground_punch":
			$attack_collision_timer.wait_time = 0.8333
			$attack_collision_timer.start()
			
	
	
	elif player_under == true and player_infront == true:
		print("player_under and player_infront")
	
	elif player_under == false and player_infront == false:
		var options = ["move","move","move","ground_punch","ground_punch","idle",]
		var choice = randi_range(0,5)
		var temp = options[choice]
		if temp == "move":
			moving = true
		else:
			moving = false
		next_animation = options[choice]
		if next_animation == "ground_punch":
			$attack_collision_timer.wait_time = 0.8333
			$attack_collision_timer.start()

func _on_animated_sprite_2d_animation_finished():
	if dead == false:
		if global_position.x < get_parent().get_node("player").global_position.x:
			player_to_the_right = true
			$turnables.scale.x = 1
			player_to_the_left = false
		if global_position.x >= get_parent().get_node("player").global_position.x:
			player_to_the_left = true
			$turnables.scale.x = -1
			player_to_the_right = false
		$turnables/AnimatedSprite2D.play("idle")
		if wait_timer_called == false:
			$decision_wait_timer.start()
			wait_timer_called = true

func create_boulder():
	var boulder = boulder_scene.instantiate()
	boulder.position.y = -330
	boulder.xpos = get_parent().get_node("player").global_position.x
	$turnables/projectiles.add_child(boulder)











func _on_infront_area_entered(area):
	if area.is_in_group("player"):
		player_infront = true
		if moving == true:
			$turnables/AnimatedSprite2D.play("1_frame")
			moving = false

func _on_infront_area_exited(area):
	if area.is_in_group("player"):
		player_infront = false

func _on_under_area_entered(area):
	if area.is_in_group("player"):
		player_under = true

func _on_under_area_exited(area):
	if area.is_in_group("player"):
		player_under = false





func _on_attack_collision_timer_timeout():
	if $turnables/AnimatedSprite2D.animation == "steam_burst":
		$turnables/attack_hitboxes/steam_burst/collision.disabled = false
		$attack_collision_deletion.wait_time = 0.1666
		$attack_collision_deletion.start()
	elif $turnables/AnimatedSprite2D.animation == "lazer_attack":
		$turnables/attack_hitboxes/lazer_attack/collision.disabled = false
		$attack_collision_deletion.wait_time = 0.1666
		$attack_collision_deletion.start()
	elif $turnables/AnimatedSprite2D.animation == "burst_attack":
		$turnables/attack_hitboxes/burst_attack/collision.disabled = false
		$attack_collision_deletion.wait_time = 0.1666
		$attack_collision_deletion.start()
	elif $turnables/AnimatedSprite2D.animation == "ground_punch":
		$turnables/attack_hitboxes/ground_punch/collision.disabled = false
		$attack_collision_deletion.wait_time = 0.3333
		$attack_collision_deletion.start()
		create_boulder()


func _on_attack_collision_deletion_timeout():
	for area in attack_areas:
		area.get_node("collision").disabled = true





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
	if spell_scene.global_position.x >= global_position.x:
		velocity.x += -spell_scene.knockback
	elif spell_scene.global_position.x < global_position.x:
		velocity.x += spell_scene.knockback
	
	health -= spell_scene.damage
	
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

func apply_debuffs():
	if debuff != "clear":
		if debuff == "burning":
			health -= 0.25
			$particle_folder/burning_particles.emitting = true
		elif debuff == "wet":
			speedchange = 0.5
			$particle_folder/water_particles.emitting = true
		elif debuff == "shocked":
			pass
		elif debuff == "stunned":
			pass
		elif debuff == "frozen":
			pass





func _on_debuff_timer_timeout():
	debuff = "clear"
	speedchange = 1
	for effect in particle_effect_folder:
		if effect.emitting == true:
			effect.emitting = false
