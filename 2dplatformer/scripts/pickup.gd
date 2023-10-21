extends Node2D
@export var type : String
@export var unlock : String

var picked_up = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# makes same volume as everything else
	$AudioStreamPlayer2D.volume_db = GlobalVar.sound_effect_volume
	
	# controls lights
	$PointLight2D.enabled = true
	$PointLight2D2.enabled = true
	$PointLight2D3.enabled = true
	$GPUParticles2D.emitting = true
	$GPUParticles2D2.emitting = true
	
	# controls colour of pickup
	if type == "spell":
		$PointLight2D.modulate = Color(0,1,1)
		$PointLight2D2.modulate = Color(0,1,1)
		$PointLight2D3.modulate = Color(0,1,1)
		$GPUParticles2D.modulate = Color(0.3,1,1)
		$GPUParticles2D2.modulate = Color(0,1,1)
	
	elif type == "movement":
		$PointLight2D.modulate = Color8(244, 253, 21)
		$PointLight2D2.modulate = Color8(244, 253, 21)
		$PointLight2D3.modulate = Color8(244, 253, 21)
		$GPUParticles2D.modulate = Color8(244, 253, 21)
		$GPUParticles2D2.modulate = Color8(244, 253, 120)
	
	elif type == "key":
		$PointLight2D.modulate = Color(0,1,0)
		$PointLight2D2.modulate = Color(0,1,0)
		$PointLight2D3.modulate = Color(0,1,0)
		$GPUParticles2D.modulate = Color(0,1,0)
		$GPUParticles2D2.modulate = Color(0,1,0.17)
		
	else:
		pass


# detects if player picks up the pickup and applies visual effects
func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		if picked_up == false:
			picked_up = true
			if type == "spell":
				GlobalVar.discovered_spells.append(unlock)
			elif type == "movement":
				GlobalVar.discovered_movement.append(unlock)
				GlobalVar.update_movement()
			elif type == "key":
				GlobalVar.discovered_keys.append(unlock)
			$AudioStreamPlayer2D.play()
			
			$GPUParticles2D3.emitting = true
			$PointLight2D.enabled = false
			$PointLight2D2.enabled = false
			$PointLight2D3.enabled = false
			$GPUParticles2D.emitting = false
			$GPUParticles2D2.emitting = false
			$deletion_timer.wait_time = $GPUParticles2D3.lifetime
			$deletion_timer.start()


# deletes once finished for optimisation reasons
func _on_deletion_timer_timeout():
	queue_free()
