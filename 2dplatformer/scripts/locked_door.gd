extends Node2D


# Called when the node enters the scene tree for the first time.
# plays the rock animations / volume set
func _ready():
	$rock.play("on")
	$rock2.play("on")
	$rock3.play("on")
	$stone_sound.volume_db = GlobalVar.sound_effect_volume
	if GlobalVar.boss_door_finished == true:
		$door_bottom.position.y = 42
		$door_top.position.y = -25



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# checks if keys discovered and if they are turns on rock effects
	if "f5_key" in GlobalVar.discovered_keys:
		$rock.modulate.a = lerpf($rock.modulate.a, 0.7, 0.05)
	if "flarge_key" in GlobalVar.discovered_keys:
		$rock2.modulate.a = lerpf($rock2.modulate.a, 0.7, 0.05)
	if "f4_key" in GlobalVar.discovered_keys:
		$rock3.modulate.a = lerpf($rock3.modulate.a, 0.7, 0.05)
		if GlobalVar.close_key_picked_up == false:
			$stone_sound.stream = load("res://assets/sounds/stone_power_on_sound.mp3")
			$stone_sound.play()
			GlobalVar.close_key_picked_up = true
	
	
	if GlobalVar.boss_door_open == true:
		$door_bottom.position.y = lerpf($door_bottom.position.y, 43,0.01)
		$door_top.position.y = lerpf($door_top.position.y, -26,0.01)
		shake()
		if $door_bottom.position.y >= 41:
			$stone_sound.stream = load("res://assets/sounds/golem_punch_sound.mp3")
			$stone_sound.play()
			$rumble_timer.stop()
			$bottom_poof.emitting = true
			$top_poof.emitting = true
			GlobalVar.boss_door_finished = true
			GlobalVar.boss_door_open = false


# controls the door shaking when opening
func shake():
	$door_bottom.position.x += randf_range(-0.5,0.5)
	if $door_bottom.global_position.x <= 49:
		$door_bottom.global_position.x = 49.1
	elif $door_bottom.global_position.x >= 51:
		$door_bottom.global_position.x = 50.9
	$door_top.position.x += randf_range(-0.5,0.5)
	if $door_top.global_position.x <= 49:
		$door_top.global_position.x = 49.1
	elif $door_top.global_position.x >= 51:
		$door_top.global_position.x = 50.9


# detects when the player wants to open the door
func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		if (
				"f5_key" in GlobalVar.discovered_keys and
				"flarge_key" in GlobalVar.discovered_keys and
				"f4_key" in GlobalVar.discovered_keys and
				GlobalVar.boss_door_finished == false
			):
			
			$stone_sound.stream = load("res://assets/sounds/golem_rock_sound.mp3")
			$stone_sound.play()
			$rumble_timer.start()
			GlobalVar.boss_door_open = true


# plays the crumbling sound while opening
func _on_rumble_timer_timeout():
	$stone_sound.stream = load("res://assets/sounds/golem_rock_sound.mp3")
	$stone_sound.play()
	$rumble_timer.start()
