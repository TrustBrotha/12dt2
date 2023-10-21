extends Label

var spell_text
# Called when the node enters the scene tree for the first time.
# sets the font size to be the same as all of the others in the game
func _ready():
	theme.default_font_size = GlobalVar.font_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# called from inventory script, changes text of spell descriptions
func change_text():
	if spell_text == "clear":
		text = "Spell description"
	if spell_text == "undiscovered":
		text = "Spell undiscovered"
	
	elif spell_text == "airburst":
		text = "Air Burst \n\nProduces a burst of air \nwhich pushes enemies \
				away with \na mediocre amount of force \n\nPushes"
	elif spell_text == "fireburst":
		text = "Fire Burst \n \nProduces a burst of fire, \nigniting enemies\
				 \n\nApplies burn"
	elif spell_text == "waterstream":
		text = "Water Stream \n\nProduces a torrent of water, \nslowing enemies\
				 \n\nApplies wet"
	elif spell_text == "firestream":
		text = "Fire Stream \n\nProduce a fiery breath, \nigniting enemies\
				 \n\nApplies burn"
	elif spell_text == "lightningstream":
		text = "Lighting Stream \n\nProduces a stream of arcs, \nelectrocuting\
				 enemies \n\nApplies shocked"
	elif spell_text == "icespikefrombelow":
		text = "Ice Trap \n\nProduces a pillar of ice \nbeneath the closest\
				 enemy, \nfreezing them \n\nApplies frost buildup"
	elif spell_text == "icespear":
		text = "Ice Spear \n\nProduces a spear of ice \nand fires it forward,\
				 \nfreezing enemies \n\nApplies frost buildup"
