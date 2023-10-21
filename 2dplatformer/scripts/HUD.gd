extends CanvasLayer
@onready var spell_icons = $spell_icons.get_children()
var selected_spells
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible == false:
		for icon in spell_icons:
			icon.visible = false
	elif visible == true:
		for icon in spell_icons:
			icon.visible = true

func sprite_update():
	selected_spells = GlobalVar.equipped_spells
	for i in range(len(selected_spells)):
		var sprite = get_node("spell_icons").get_node("spell_icon%s" %(i+1))
		sprite.set_texture(load("res://scenes/UI/icons/%s_icon.png" %selected_spells[i]))
		sprite.scale.x = 1.5
		sprite.scale.y = 1.5
		sprite.texture_filter = 1
