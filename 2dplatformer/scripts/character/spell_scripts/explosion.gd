extends Node2D

var knockback = -100
var damage = 30

var charge_decrease = 20
var timer_called = false
var hitbox_direction
var emit = true

var chargebar_low = false
var position_in_spell_list
@onready var direction = get_parent().get_node("player").last_direction
# Called when the node enters the scene tree for the first time.
func _ready():
	$explosion_sound.volume_db = GlobalVar.sound_effect_volume
	$fuse_sound.volume_db = GlobalVar.sound_effect_volume
	$fuse_sound.play()
	global_position.x = get_parent().get_node("player").global_position.x + (direction * 75)
	position_in_spell_list = GlobalVar.equipped_spells.find("explosion")
	get_parent().get_node("HUD").get_node("spell_charge_bar_folder")\
			.get_node("spell%s_charge_bar"%(position_in_spell_list+1)).value = 1000


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	chargebar_low = false
	if emit == false:
		if get_parent().get_node("HUD").get_node("spell_charge_bar_folder")\
				.get_node("spell%s_charge_bar"%(position_in_spell_list+1)).value < 30:
			chargebar_low = true
		
		if chargebar_low == true:
			emit = true
			$GPUParticles2D.emitting = true
			$deletion_timer.wait_time = $GPUParticles2D.lifetime + 0.3
			$collision_timer.start()
			$explosion_sound.play()
		emit = true
		cancel()



func cancel():
	$GPUParticles2D2.emitting = false
	$deletion_timer.start()
	$fuse_sound.stop()


func _on_deletion_timer_timeout():
	queue_free()


func _on_collision_timer_timeout():
	$Area2D/CollisionShape2D.disabled = false
	$collision_deletion_timer.start()


func _on_collision_deletion_timer_timeout():
	$Area2D/CollisionShape2D.disabled = true
