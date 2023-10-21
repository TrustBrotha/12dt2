extends CanvasLayer
@onready var spell_icons = $spell_icons.get_children()
var selected_spells
var dead = false
var dead_timer_called = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$health_bar.value = GlobalVar.character_health
	selected_spells = GlobalVar.equipped_spells
	for i in range(len(selected_spells)):
		var sprite = get_node("spell_icons").get_node("spell_icon%s" %(i+1))
		sprite.set_texture(load("res://scenes/UI/icons/%s_icon.png" %selected_spells[i]))
		sprite.scale.x = 1.5
		sprite.scale.y = 1.5
		sprite.texture_filter = 1
	
	if GlobalVar.speen_run_timer_enabled == true:
		$speedrun_timer.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible == false:
		for icon in spell_icons:
			icon.visible = false
	elif visible == true:
		for icon in spell_icons:
			icon.visible = true
	
	if dead == true:
		$death_message.visible = true
		$screen_effect.modulate.a = lerpf($screen_effect.modulate.a, 1, 0.02)
		$death_message.modulate.a = lerpf($death_message.modulate.a, 1, 0.02)
		if dead_timer_called == false:
			$death_timer.start()
			dead_timer_called = true
	
	if GlobalVar.speen_run_timer_enabled == true:
		$speedrun_timer.text = GlobalVar.stopwatch_display

func sprite_update():
	selected_spells = GlobalVar.equipped_spells
	for i in range(len(selected_spells)):
		var sprite = get_node("spell_icons").get_node("spell_icon%s" %(i+1))
		sprite.set_texture(load("res://scenes/UI/icons/%s_icon.png" %selected_spells[i]))
		sprite.scale.x = 1.5
		sprite.scale.y = 1.5
		sprite.texture_filter = 1




func _on_death_timer_timeout():
	GlobalVar.respawn()
