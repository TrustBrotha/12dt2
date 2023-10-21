extends CanvasLayer
@onready var spell_type_button_folder := $Control/spell_select_buttons.get_children()
@onready var spell_button_folder := $Control/spell_buttons.get_children()

var discovered_spells = ["fireburst", "airburst", "firestream", "waterstream"]

@onready var selected_spells = GlobalVar.equipped_spells

var spell_listening = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(len(selected_spells)):
		var sprite = get_node("Control").get_node("spell_select_buttons").get_node("spell%s" %(i+1)).get_node("spell%s_sprite" %(i+1))
		sprite.set_texture(load("res://scenes/UI/icons/%s_icon.png" %selected_spells[i]))
		sprite.scale.x =3
		sprite.scale.y =3
		sprite.position.x = 50
		sprite.position.y = 50
		sprite.texture_filter = 1
	
	if len(discovered_spells) == 0:
		pass
	else:
		for spell in discovered_spells:
			get_node("Control").get_node("spell_buttons").get_node("%s" %spell).disabled = false


func change_text():
	for i in range(len(selected_spells)):
		var sprite = get_node("Control").get_node("spell_select_buttons").get_node("spell%s" %(i+1)).get_node("spell%s_sprite" %(i+1))
		sprite.set_texture(load("res://scenes/UI/icons/%s_icon.png" %selected_spells[i]))
		sprite.scale.x =3
		sprite.scale.y =3
		sprite.position.x = 50
		sprite.position.y = 50
		sprite.texture_filter = 1






# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	print(selected_spells)
	if $Control/spell_buttons/airburst.is_hovered():
		$Control/Label.spell_text = "airburst"
	elif $Control/spell_buttons/fireburst.is_hovered():
		$Control/Label.spell_text = "fireburst"
	elif $Control/spell_buttons/waterstream.is_hovered():
		$Control/Label.spell_text = "waterstream"
	elif $Control/spell_buttons/firestream.is_hovered():
		$Control/Label.spell_text = "firestream"
	elif $Control/spell_buttons/lightningstream.is_hovered():
		$Control/Label.spell_text = "lightningstream"
	
	
	
	
	
	
	else:
		$Control/Label.spell_text = "clear"
	$Control/Label.change_text()





func change_to_spell_select():
	for button in spell_type_button_folder:
		button.visible = false
	for button in spell_button_folder:
		button.visible = true
	for spell in discovered_spells:
		get_node("Control").get_node("spell_buttons").get_node("%s" %spell).get_node("icon").visible = true
	$Control/Label.visible = true
	$Control/Sprite2D.visible = true

func change_to_spell_type_select():
	for button in spell_type_button_folder:
		button.visible = true
	for button in spell_button_folder:
		button.visible = false
	for spell in discovered_spells:
		get_node("Control").get_node("spell_buttons").get_node("%s" %spell).get_node("icon").visible = true
	$Control/Label.visible = false
	$Control/Sprite2D.visible = false
	get_parent().get_node("HUD").sprite_update()

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


func _on_airstream_pressed():
	selected_spells[spell_listening-1] = "airstream"
	change_text()
	change_to_spell_type_select()
	spell_listening = 0
