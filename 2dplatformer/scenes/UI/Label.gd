extends Label

var spell_text
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func change_text():
	if spell_text == "clear":
		text = "spell description"
	elif spell_text == "airburst":
		text = "Air Burst \n\nProduces a burst of air \nwhich pushes enemies away with \na mediocre amount of force \n\nPushes"
	elif spell_text == "fireburst":
		text = "Fire Burst \n \nProduces a burst of fire, \nigniting enemies \n\nApplies burn"
	elif spell_text == "waterstream":
		text = "Water Stream \n\nProduces a torrent of water, \n slowing enemies \n\nApplies wet"
	elif spell_text == "firestream":
		text = "Fire Stream \n\nProduce a fiery breath, \nigniting enemies \n\nApplies burn"
	
