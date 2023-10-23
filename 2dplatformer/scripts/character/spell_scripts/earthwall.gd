extends Node2D

var knockback = 0
var damage = 10

var charge_decrease = 5
var timer_called = false
var hitbox_direction
var emit = true

var chargebar_low = false
var position_in_spell_list
var building = false
# Called when the node enters the scene tree for the first time.
func _ready():
	position_in_spell_list = GlobalVar.equipped_spells.find("earthwall")
	if get_parent().get_node("HUD").get_node("spell_charge_bar_folder").get_node("spell%s_charge_bar"%(position_in_spell_list+1)).value > 950:
		building = true
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play("build")
		$wall_lifetime.start()
		get_parent().get_node("HUD").get_node("spell_charge_bar_folder")\
				.get_node("spell%s_charge_bar"%(position_in_spell_list+1)).value = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if building == true:
		if $RayCast2D.is_colliding():
			var collision_point = $RayCast2D.get_collision_point()
			global_position = collision_point
			$StaticBody2D/CollisionShape2D.disabled = false
			$RayCast2D.enabled = false


func _on_wall_lifetime_timeout():
	$AnimatedSprite2D.play("destroy")
	$StaticBody2D/CollisionShape2D.disabled = true
	$deletion_timer.start()


func _on_deletion_timer_timeout():
	queue_free()
