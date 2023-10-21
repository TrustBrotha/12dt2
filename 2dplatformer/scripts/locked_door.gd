extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if GlobalVar.boss_door_finished == true:
		$door_bottom.position.y = 42
		$door_top.position.y = -25


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if "f5_key" in GlobalVar.discovered_keys:
		$rock.modulate.a = lerpf($rock.modulate.a, 0.7, 0.05)
		$rock.play("default")
	if "flarge_key" in GlobalVar.discovered_keys:
		$rock2.modulate.a = lerpf($rock2.modulate.a, 0.7, 0.05)
		$rock2.play("default")
	if "f4_key" in GlobalVar.discovered_keys:
		$rock3.modulate.a = lerpf($rock3.modulate.a, 0.7, 0.05)
		$rock3.play("default")
	
	if GlobalVar.boss_door_open == true:
		$door_bottom.position.y = lerpf($door_bottom.position.y, 43,0.01)
		$door_top.position.y = lerpf($door_top.position.y, -26,0.01)
		shake()
		if $door_bottom.position.y >= 41:
			$bottom_poof.emitting = true
			$top_poof.emitting = true
			GlobalVar.boss_door_finished = true
			GlobalVar.boss_door_open = false

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



func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		if "f5_key" in GlobalVar.discovered_keys:
			if "flarge_key" in GlobalVar.discovered_keys:
				if "f4_key" in GlobalVar.discovered_keys:
					if GlobalVar.boss_door_finished == false:
						GlobalVar.boss_door_open = true
