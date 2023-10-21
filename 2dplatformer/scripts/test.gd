extends Node2D
@export var inventory1:PackedScene
@export var inventory2:PackedScene

var inventory_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	$Sprite2D.set_texture(load("res://scenes/UI/icons/fireburst_icon.png")) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#	if Input.is_action_just_pressed("dash") and inventory_open == false:
#		var inventory_spell_sel = inventory1.instantiate()
#		inventory_spell_sel.set_name("inventory1")
#		add_child(inventory_spell_sel)
#		inventory_open = true
#
#	elif Input.is_action_just_pressed("dash") and inventory_open == true:
#		get_node("inventory1").queue_free()
#		inventory_open = false
