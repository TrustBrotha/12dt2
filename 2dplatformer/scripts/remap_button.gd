extends Button

@export var action : String

func _ready():
	set_process_unhandled_key_input(false)
	display_key()


func display_key():
	text = "%s"%InputMap.action_get_events(action)[0].as_text()

func _on_toggled(button_pressed):
	set_process_unhandled_key_input(button_pressed)
	if button_pressed:
		text = "---"
	else:
		display_key()

func _unhandled_key_input(event):
	print("working")
	remap_key(event)
	button_pressed = false

func remap_key(event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action,event)
	
	text = "%s" %event.as_text()

## Called when the node enters the scene tree for the first time.
#func _ready():
#	set_process_unhandled_input(false)
#	update_key_text()
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#
#func _init():
#	toggle_mode = true
#
#func update_key_text():
#	text = "%s"%InputMap.action_get_events(action)[0].as_text()
#
#func _toggled(button_pressed):
#	set_process_unhandled_input(button_pressed)
#	if button_pressed:
#		text = "-----"
#		release_focus()
#	else:
#		update_key_text()
#		grab_focus()
#
#func _unhandled_input(event):
#	if event.pressed:
#		InputMap.action_erase_events(action)
#		InputMap.action_add_event(action,event)
#		button_pressed = false


