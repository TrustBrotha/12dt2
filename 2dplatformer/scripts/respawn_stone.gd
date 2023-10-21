extends Node2D
@export var room : String
var in_player = false
var on = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$glow.play("default")
	$stone_sound.volume_db = GlobalVar.sound_effect_volume


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# controls prompt
	if in_player == true and on == false:
		$Control.visible = true
		# sets respawn room
		if Input.is_action_just_pressed("up"):
			GlobalVar.respawn_room = "res://scenes/levels/%s.tscn"%room
			GlobalVar.respawn_point_reached = true
			$stone_sound.play()
	
	
	elif in_player == false:
		$Control.visible = false
	
	# controls whether on or off
	if GlobalVar.respawn_room == "res://scenes/levels/%s.tscn"%room:
		on = true
	elif GlobalVar.respawn_room != "res://scenes/levels/%s.tscn"%room:
		on = false
	if on == true:
		$GPUParticles2D.emitting = false
		$glow.modulate.a = lerpf($glow.modulate.a, 0.8, 0.05)
	elif on == false:
		$GPUParticles2D.emitting = true
		$glow.modulate.a = lerpf($glow.modulate.a, 0, 0.05)


#player detection
func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		in_player = true


func _on_area_2d_area_exited(area):
	if area.is_in_group("player"):
		in_player = false
