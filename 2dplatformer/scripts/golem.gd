extends CharacterBody2D

# Called when the node enters the scene tree for the first time.
@onready var next_animation = "power_up"
@onready var attack_areas = $turnables/attack_hitboxes.get_children()
@onready var particle_effect_folder = $particle_folder.get_children()
@export var boulder_scene : PackedScene
@export var audio_scene : PackedScene
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
var frost_buildup = 0
@onready var current_sound_effect_nodes = $audio.get_children()
var current_sound_effects = []


func _ready():
	# controls sound / visuals
	MusicPlayer.play_boss_music()
	$golem_hover.play()
	$golem_hover.volume_db = GlobalVar.sound_effect_volume
	play_sound("golem_power_up")
	get_parent().get_node("HUD").get_node("boss_health_bar").visible = true
	$turnables/AnimatedSprite2D.play("power_up")
	next_animation = "idle"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_sound_effect_nodes = $audio.get_children()
	current_sound_effects = []
	# controls sound
	for i in current_sound_effect_nodes:
		current_sound_effects.append(i.name)
	
	# controls if dead
	if health <= 0 and dead == false:
		dead = true
		play_sound("golem_death")
		$golem_hover.stop()
		$turnables/AnimatedSprite2D.play("death")
		get_parent().get_node("HUD").get_node("boss_health_bar").visible = false
		GlobalVar.golem_defeated = true
		get_parent().close_door = false
		MusicPlayer.fade_out = true
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
	
	if frost_buildup >= 100:
		debuff = "frozen"
		$debuff_cooldown.wait_time = 4
		$debuff_cooldown.start()
		$particle_folder/frozen_particles1.emitting = true
		$particle_folder/frozen_particles2.emitting = true
		$particle_folder/frozen_particles3.emitting = true
		frost_buildup = 0
	
	
	immunity()
	apply_debuffs()
	get_parent().get_node("HUD").get_node("boss_health_bar").value = (float(health)/10)
	
	
	move_and_slide()

# calls for decision to be made
func _on_decision_timer_timeout():
	action_decision()
	$turnables/AnimatedSprite2D.play(next_animation)
	wait_timer_called = false


# instanciates sounds
func play_sound(sound):
	var audio = audio_scene.instantiate()
	audio.stream = load("res://assets/sounds/%s_sound.mp3"%sound)
	audio.name = sound
	$audio.add_child(audio)


# controlls immunity
func immunity():
	if immune == true and immunity_timer_called == false:
		immunity_timer_called = true
		$immunity_frame_timer.start()
		$hitbox/CollisionShape2D.disabled = true
	elif immune == false:
		$hitbox/CollisionShape2D.disabled = false
	
	if $hitbox/CollisionShape2D.disabled == true:
		if immune_effect_called == false:
			color_white()
			$turnables/AnimatedSprite2D.modulate = Color(100,100,100)
			$damaged_effect_timer.start()
			play_sound("golem_hit")
			immune_effect_called = true
	elif $hitbox/CollisionShape2D.disabled == false:
		immune_effect_called = false


# controls colour of golem
func _on_damaged_effect_timer_timeout():
	color_normal()
	$turnables/AnimatedSprite2D.modulate = Color(1,1,1)

# controls immunity
func _on_immunity_frame_timer_timeout():
	immune = false
	immunity_timer_called = false


# controls colour of golem
func color_white():
	for i in range(7):
		$turnables/AnimatedSprite2D.material\
				.set("shader_parameter/newcolor%s"%(i+1),Color8(1000,1000,1000))


# controls colour of golem
func color_normal():
	var color_list = [
		Color8(27,38,30),Color8(42,62,51),Color8(64,88,111),
		Color8(59,108,101),Color8(58,108,101),Color8(64,88,111),Color8(75,138,153)
	]
	for i in range(7):
		$turnables/AnimatedSprite2D.material\
				.set("shader_parameter/newcolor%s"%(i+1),color_list[i])


# decision making code
func action_decision():
	if player_infront == true:
		var options = ["steam_burst","lazer_attack"]
		var choice = randi_range(0,1)
		next_animation = options[choice]
		if next_animation == "steam_burst":
			$attack_collision_timer.wait_time = 0.8333
			$attack_collision_timer.start()
			play_sound("golem_rock")
			
		elif next_animation == "lazer_attack":
			$attack_collision_timer.wait_time = 0.9166
			$attack_collision_timer.start()
			play_sound("golem_rock")
		
	
	
	elif player_under == true:
		var options = ["burst_attack","burst_attack","ground_punch","ground_punch","spin"]
		var choice = randi_range(0,4)
		next_animation = options[choice]
		if next_animation == "burst_attack":
			$attack_collision_timer.wait_time = 0.5833
			$attack_collision_timer.start()
			play_sound("golem_rock")
		elif next_animation == "ground_punch":
			$attack_collision_timer.wait_time = 0.8333
			$attack_collision_timer.start()
			play_sound("golem_rock")
		elif next_animation == "spin":
			play_sound("golem_rock")
			
	
	
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
			play_sound("golem_rock")


# fliping control
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


# spawning boulder from ground punch attack
func create_boulder():
	var boulder = boulder_scene.instantiate()
	boulder.position.y = -330
	boulder.xpos = get_parent().get_node("player").global_position.x
	$turnables/projectiles.add_child(boulder)

# player detection
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




# controlling attack collision
func _on_attack_collision_timer_timeout():
	if $turnables/AnimatedSprite2D.animation == "steam_burst":
		$turnables/attack_hitboxes/steam_burst/collision.disabled = false
		$attack_collision_deletion.wait_time = 0.1666
		$attack_collision_deletion.start()
		
		if "golem_rock" in current_sound_effects:
			$audio.get_node("golem_rock").queue_free()
		
		play_sound("golem_steam")
	
	elif $turnables/AnimatedSprite2D.animation == "lazer_attack":
		$turnables/attack_hitboxes/lazer_attack/collision.disabled = false
		$attack_collision_deletion.wait_time = 0.1666
		$attack_collision_deletion.start()
		
		if "golem_rock" in current_sound_effects:
			$audio.get_node("golem_rock").queue_free()
		
		play_sound("golem_lazer")

	elif $turnables/AnimatedSprite2D.animation == "burst_attack":
		$turnables/attack_hitboxes/burst_attack/collision.disabled = false
		$attack_collision_deletion.wait_time = 0.1666
		$attack_collision_deletion.start()
		
		if "golem_rock" in current_sound_effects:
			$audio.get_node("golem_rock").queue_free()
			
		play_sound("golem_punch")
		
	elif $turnables/AnimatedSprite2D.animation == "ground_punch":
		$turnables/attack_hitboxes/ground_punch/collision.disabled = false
		$attack_collision_deletion.wait_time = 0.3333
		$attack_collision_deletion.start()
		
		if "golem_rock" in current_sound_effects:
			$audio.get_node("golem_rock").queue_free()
		
		play_sound("golem_punch")
		
		create_boulder()


func _on_attack_collision_deletion_timeout():
	for area in attack_areas:
		area.get_node("collision").disabled = true


# controls spell effect
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
			$debuff_cooldown.wait_time = 1
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("water"):
			debuff = "wet"
			$debuff_cooldown.wait_time = 2
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("lightning"):
			debuff = "shocked"
			$debuff_cooldown.wait_time = 0.5
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("earth"):
			debuff = "stunned"
			$debuff_cooldown.wait_time = 0.25
			$debuff_cooldown.start()
		elif spell_scene.is_in_group("ice"):
			frost_buildup += 10


# controls what debuffs do each frame
func apply_debuffs():
	if debuff != "clear":
		if debuff == "burning":
			health -= 0.25
			$particle_folder/burning_particles.emitting = true
		elif debuff == "wet":
			speedchange = 0.5
			$particle_folder/water_particles.emitting = true
		elif debuff == "shocked":
			$particle_folder/shocked_particles.emitting = true
			$turnables/vision_hitboxes/infront/infront_collision.disabled = true
			$turnables/vision_hitboxes/under/under_collision.disabled = true
		elif debuff == "stunned":
			if dead != true:
				$turnables/AnimatedSprite2D.play("stun")
			$particle_folder/stun_particles1.emitting = true
			$particle_folder/stun_particles2.emitting = true
			
		elif debuff == "frozen":
			speedchange = 0
			$turnables/vision_hitboxes/infront/infront_collision.disabled = true
			$turnables/vision_hitboxes/under/under_collision.disabled = true


# clears debuffs
func _on_debuff_timer_timeout():
	debuff = "clear"
	speedchange = 1
	$turnables/vision_hitboxes/infront/infront_collision.disabled = false
	$turnables/vision_hitboxes/under/under_collision.disabled = false
	for effect in particle_effect_folder:
		if effect.emitting == true:
			effect.emitting = false


func _on_golem_sounds_finished():
	pass # Replace with function body.


# loops hover sound
func _on_golem_hover_finished():
	$golem_hover.play()
