extends CanvasLayer
@onready var spell_icons = $spell_icons.get_children()
var selected_spells
var dead = false
var dead_timer_called = false




# Called when the node enters the scene tree for the first time.
func _ready():
	# makes font same as everything else
	$speedrun_timer.theme.default_font_size = GlobalVar.font_size
	$Control/tutorials.theme.default_font_size = GlobalVar.font_size
	if "movement" in GlobalVar.tutorials_to_go:
		tutorial("movement")
	$health_bar.value = GlobalVar.character_health
	sprite_update()
	
	if GlobalVar.speen_run_timer_enabled == true:
		$speedrun_timer.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# controls what is visible and what isn't
	if visible == false:
		for icon in spell_icons:
			icon.visible = false
	elif visible == true:
		for icon in spell_icons:
			icon.visible = true
	
	# contols death screen
	if dead == true:
		$death_message.visible = true
		$screen_effect.modulate.a = lerpf($screen_effect.modulate.a, 1, 0.02)
		$death_message.modulate.a = lerpf($death_message.modulate.a, 1, 0.02)
		if dead_timer_called == false:
			$death_timer.start()
			dead_timer_called = true
	
	# controls speed run timer
	if GlobalVar.speen_run_timer_enabled == true:
		$speedrun_timer.text = GlobalVar.stopwatch_display
	
	
	# controls when tutorials played
	if GlobalVar.double_jump_unlocked == true and "double_jump" in GlobalVar.tutorials_to_go:
		tutorial("double_jump")
	if GlobalVar.wall_jump_unlocked == true and "wall_jump" in GlobalVar.tutorials_to_go:
		tutorial("wall_jump")
	if GlobalVar.dash_unlocked == true and "dash" in GlobalVar.tutorials_to_go:
		tutorial("dash")
	if "fireburst" in GlobalVar.discovered_spells and "spells" in GlobalVar.tutorials_to_go:
		tutorial("spells")
	
	if GlobalVar.current_level == "f2" and "spell_unlocks" in GlobalVar.tutorials_to_go:
		tutorial("spell_unlocks")
	if len(GlobalVar.discovered_keys) != 0 and "keys" in GlobalVar.tutorials_to_go:
		tutorial("keys")
	if GlobalVar.current_level == "flarge" and "movement_unlocks" in GlobalVar.tutorials_to_go:
		tutorial("movement_unlocks")


# updates spell equipped icons
func sprite_update():
	selected_spells = GlobalVar.equipped_spells
	for i in range(len(selected_spells)):
		var sprite = get_node("spell_icons").get_node("spell_icon%s" %(i+1))
		sprite.set_texture(load("res://scenes/UI/icons/%s_icon.png" %selected_spells[i]))
		sprite.scale.x = 1.5
		sprite.scale.y = 1.5
		sprite.texture_filter = 1


# controls when the player respawns
func _on_death_timer_timeout():
	GlobalVar.respawn()


# controls text of tutorial
func tutorial(mechanic):
	GlobalVar.tutorials_to_go.erase(mechanic)
	$Control/Sprite2D.visible = true
	$tutorial_timer.start()
	
	if mechanic == "movement":
		$Control/temp.visible = true
		var text = "%s, %s, %s, %s"%\
		[InputMap.action_get_events("up")[0].as_text(),\
		InputMap.action_get_events("move_left")[0].as_text(),\
		InputMap.action_get_events("down")[0].as_text(),\
		InputMap.action_get_events("move_right")[0].as_text() ]
		text = text.replace("(Physical)", "")
		var text2 = "%s"%InputMap.action_get_events("jump")[0].as_text()
		text2 = text2.replace("(Physical)", "")
		$Control/tutorials.text = "press: %s to move and press: %s to jump"%[text,text2]
	
	elif mechanic == "inventory":
		$Control/temp.visible = false
		var text = " %s" % [InputMap.action_get_events("inventory")[0].as_text()]
		text = text.replace("(Physical)", "")
		$Control/tutorials.text = "press: %s to open and close inventory"%text
	
	elif mechanic == "spells":
		var text = "%s, %s, %s, %s, %s"%\
		[InputMap.action_get_events("spell1")[0].as_text(),\
		InputMap.action_get_events("spell2")[0].as_text(),\
		InputMap.action_get_events("spell3")[0].as_text(),\
		InputMap.action_get_events("spell4")[0].as_text(),\
		InputMap.action_get_events("spell5")[0].as_text() ]
		text = text.replace("(Physical)", "")
		$Control/tutorials.text = "press: %s to cast\
				 assigned spells (shown under health bar)"%text
	
	elif mechanic == "keys":
		$Control/tutorials.text = "green items are keys, opens a locked door somewhere"
	
	elif mechanic == "movement_unlocks":
		$Control/tutorials.text = "gold items are\
				 movement abilities which let you explore new areas"
	
	elif mechanic == "spell_unlocks":
		$Control/tutorials.text = "blue items are spells,\
				 check which spells are unlocked in the inventory"
	
	elif mechanic == "wall_jump":
		$Control/tutorials.text = "jump while moving into a wall to perform a wall jump"
	
	elif mechanic == "dash":
		var text = " %s" % [InputMap.action_get_events("dash")[0].as_text()]
		text = text.replace("(Physical)", "")
		$Control/tutorials.text = "press: %s to dash forward"%text
	
	elif mechanic == "double_jump":
		$Control/tutorials.text = "jump while in air to jump again"


# controls when the tutorial text is cleared
func _on_tutorial_timer_timeout():
	$Control/tutorials.text = ""
	$Control/Sprite2D.visible = false
