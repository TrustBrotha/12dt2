extends Node2D

var knockback = 0
var damage = 10

var charge_decrease = 17
var timer_called = false
var hitbox_direction
var emit = true

var chargebar_low = false
var position_in_spell_list

# Called when the node enters the scene tree for the first time.
func _ready():
	position_in_spell_list = GlobalVar.equipped_spells.find("heal")
	$heal_charge_sound.volume_db = GlobalVar.sound_effect_volume
	$heal_end_sound.volume_db = GlobalVar.sound_effect_volume
	$heal_charge_sound.play()
	get_parent().get_node("HUD").get_node("spell_charge_bar_folder")\
			.get_node("spell%s_charge_bar"%(position_in_spell_list+1)).value = 1000
	
	global_position = get_parent().get_node("player").global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	chargebar_low = false
	if emit == false:
		if get_parent().get_node("HUD").get_node("spell_charge_bar_folder")\
				.get_node("spell%s_charge_bar"%(position_in_spell_list+1)).value < 30:
			chargebar_low = true
		
		if chargebar_low == true:
			emit = true
			GlobalVar.character_health += 10
			$GPUParticles2D.emitting = true
			$deletion_timer.wait_time = $GPUParticles2D.lifetime
			$heal_end_sound.play()
			$heal_charge_sound.stop()
		emit = true
		cancel()


func cancel():
	$GPUParticles2D2.emitting = false
	$deletion_timer.start()


func _on_deletion_timer_timeout():
	queue_free()



