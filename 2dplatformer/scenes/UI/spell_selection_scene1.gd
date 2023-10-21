extends CanvasLayer
@onready var spell_type_button_folder := $Control/spell_select_buttons.get_children()
@onready var spell_button_folder := $Control/spell_buttons.get_children()

@onready var discovered_spells = []

@onready var selected_spells = GlobalVar.equipped_spells

var spell_listening = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	# changes font to be same as everything else
	$menu_button.theme.default_font_size = GlobalVar.font_size
	# gets information from globalvar
	discovered_spells = GlobalVar.discovered_spells
	
	change_text()
	
	# enabled the buttons for discovered spells to they can be equipped
	if len(discovered_spells) == 0:
		pass
	else:
		for spell in discovered_spells:
			get_node("Control").get_node("spell_buttons").get_node("%s" %spell).disabled = false


# changes icons in spell slot selection page
func change_text():
	for i in range(len(selected_spells)):
		var sprite = get_node("Control").get_node("spell_select_buttons")\
				.get_node("spell%s" %(i+1)).get_node("spell%s_sprite" %(i+1))
		sprite.set_texture(load("res://scenes/UI/icons/%s_icon.png" %selected_spells[i]))
		sprite.scale.x =3
		sprite.scale.y =3
		sprite.position.x = 50
		sprite.position.y = 50
		sprite.texture_filter = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
# changes text of the spell description box
func _process(delta):
	if $Control/spell_buttons/airburst.is_hovered():
		if $Control/spell_buttons/airburst.disabled == false:
			$Control/Label.spell_text = "airburst"
		else:
			$Control/Label.spell_text = "undiscovered"
	
	elif $Control/spell_buttons/fireburst.is_hovered():
		if $Control/spell_buttons/fireburst.disabled == false:
			$Control/Label.spell_text = "fireburst"
		else:
			$Control/Label.spell_text = "undiscovered"
	
	elif $Control/spell_buttons/waterstream.is_hovered():
		if $Control/spell_buttons/waterstream.disabled == false:
			$Control/Label.spell_text = "waterstream"
		else:
			$Control/Label.spell_text = "undiscovered"
	
	elif $Control/spell_buttons/firestream.is_hovered():
		if $Control/spell_buttons/firestream.disabled == false:
			$Control/Label.spell_text = "firestream"
		else:
			$Control/Label.spell_text = "undiscovered"
	
	elif $Control/spell_buttons/lightningstream.is_hovered():
		if $Control/spell_buttons/lightningstream.disabled == false:
			$Control/Label.spell_text = "lightningstream"
		else:
			$Control/Label.spell_text = "undiscovered"
	
	elif $Control/spell_buttons/icespikefrombelow.is_hovered():
		if $Control/spell_buttons/icespikefrombelow.disabled == false:
			$Control/Label.spell_text = "icespikefrombelow"
		else:
			$Control/Label.spell_text = "undiscovered"
	
	elif $Control/spell_buttons/icespear.is_hovered():
		if $Control/spell_buttons/icespear.disabled == false:
			$Control/Label.spell_text = "icespear"
		else:
			$Control/Label.spell_text = "undiscovered"
	
	else:
		$Control/Label.spell_text = "clear"
	
	$Control/Label.change_text()


# hides the page showing all of the spell slot information
# shows the page with all of the discovered spells
func change_to_spell_select():
	for button in spell_type_button_folder:
		button.visible = false
	for button in spell_button_folder:
		button.visible = true
	for spell in discovered_spells:
		get_node("Control").get_node("spell_buttons")\
				.get_node("%s" %spell).get_node("icon").visible = true
	$Control/Label.visible = true
	$Control/Sprite2D.visible = true


# shows the page showing all of the spell slot information
# hides the page with all of the discovered spells
func change_to_spell_type_select():
	for button in spell_type_button_folder:
		button.visible = true
	for button in spell_button_folder:
		button.visible = false
	for spell in discovered_spells:
		get_node("Control").get_node("spell_buttons")\
				.get_node("%s" %spell).get_node("icon").visible = true
	$Control/Label.visible = false
	$Control/Sprite2D.visible = false
	get_parent().get_node("HUD").sprite_update()


# defines which spell slot will be changed
func _on_spell_1_pressed():
	spell_listening = 1
	change_to_spell_select()

func _on_spell_2_pressed():
	spell_listening = 2
	change_to_spell_select()

func _on_spell_3_pressed():
	spell_listening = 3
	change_to_spell_select()

func _on_spell_4_pressed():
	spell_listening = 4
	change_to_spell_select()

func _on_spell_5_pressed():
	spell_listening = 5
	change_to_spell_select()


# changes the selected spell slot to the selected spell
func _on_airburst_pressed():
	selected_spells[spell_listening-1] = "airburst"
	change_text()
	change_to_spell_type_select()
	spell_listening = 0


func _on_firestream_pressed():
	selected_spells[spell_listening-1] = "firestream"
	change_text()
	change_to_spell_type_select()
	spell_listening = 0


func _on_waterstream_pressed():
	selected_spells[spell_listening-1] = "waterstream"
	change_text()
	change_to_spell_type_select()
	spell_listening = 0


func _on_fireburst_pressed():
	selected_spells[spell_listening-1] = "fireburst"
	change_text()
	change_to_spell_type_select()
	spell_listening = 0

func _on_lightningstream_pressed():
	selected_spells[spell_listening-1] = "lightningstream"
	change_text()
	change_to_spell_type_select()
	spell_listening = 0

func _on_icespikefrombelow_pressed():
	selected_spells[spell_listening-1] = "icespikefrombelow"
	change_text()
	change_to_spell_type_select()
	spell_listening = 0

func _on_icespear_pressed():
	selected_spells[spell_listening-1] = "icespear"
	change_text()
	change_to_spell_type_select()
	spell_listening = 0





# changes to title screen scene
func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen_scenes/titlescreen.tscn")






