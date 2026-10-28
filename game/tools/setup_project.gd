extends SceneTree


func _initialize() -> void:
	_configure_input_actions()
	var error := ProjectSettings.save()
	if error != OK:
		push_error("Failed to save project settings: %s" % error_string(error))
		quit(1)
		return

	print("Configured project input actions.")
	quit()


func _configure_input_actions() -> void:
	_set_action("move_up", [_key(KEY_W), _key(KEY_UP), _axis(JOY_AXIS_LEFT_Y, -1.0)])
	_set_action("move_down", [_key(KEY_S), _key(KEY_DOWN), _axis(JOY_AXIS_LEFT_Y, 1.0)])
	_set_action("move_left", [_key(KEY_A), _key(KEY_LEFT), _axis(JOY_AXIS_LEFT_X, -1.0)])
	_set_action("move_right", [_key(KEY_D), _key(KEY_RIGHT), _axis(JOY_AXIS_LEFT_X, 1.0)])
	_set_action("interact", [_key(KEY_E), _key(KEY_ENTER), _button(JOY_BUTTON_A)])
	_set_action("pause", [_key(KEY_ESCAPE), _button(JOY_BUTTON_START)])
	_set_action("toggle_fullscreen", [_key(KEY_F11)])
	_set_action("toggle_debug", [_key(KEY_F3)])


func _set_action(action_name: StringName, events: Array[InputEvent]) -> void:
	ProjectSettings.set_setting(
		"input/%s" % action_name,
		{
			"deadzone": 0.5,
			"events": events,
		},
	)


func _key(physical_keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = physical_keycode
	return event


func _axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	return event


func _button(button: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	return event

