extends Button

@export var action : String


# stops the unhandled process and displays the input text
func _ready():
	set_process_unhandled_key_input(false)
	display_key()


# displays text version of the input event
func display_key():
	text = "%s"%InputMap.action_get_events(action)[0].as_text()


# if the button is toggled on, then the button is listening to inputs
func _on_toggled(button_pressed):
	set_process_unhandled_key_input(button_pressed)
	if button_pressed:
		text = "---"
	else:
		display_key()

# when event is pressed it calls the remap key funciton and un toggles button
func _unhandled_key_input(event):
	remap_key(event)
	button_pressed = false


# remaps input
func remap_key(event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action,event)
	
	if (
			action == "spell1"
			or action == "spell2"
			or action == "spell3"
			or action == "spell4"
			or action == "spell5"
	):
		GlobalVar.reset_cast_inputs()
	text = "%s" %event.as_text()
