extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	_check_setting("display/window/size/viewport_width", 320)
	_check_setting("display/window/size/viewport_height", 180)
	_check_setting("display/window/stretch/mode", "canvas_items")
	_check_setting("display/window/stretch/scale_mode", "integer")

	for action in [
		"move_up",
		"move_down",
		"move_left",
		"move_right",
		"interact",
		"pause",
		"toggle_fullscreen",
		"toggle_debug",
	]:
		_check(InputMap.has_action(action), "Missing input action: %s" % action)

	_check_scene("res://scenes/system/boot.tscn")
	_check_scene("res://scenes/system/test_room.tscn")
	_check_scene("res://scenes/player/player.tscn")

	if failures.is_empty():
		print("P1 smoke test passed.")
		quit()
		return

	for failure in failures:
		push_error(failure)
	quit(1)


func _check_setting(path: String, expected: Variant) -> void:
	var actual: Variant = ProjectSettings.get_setting(path)
	_check(actual == expected, "%s expected %s but got %s" % [path, expected, actual])


func _check_scene(path: String) -> void:
	_check(ResourceLoader.exists(path, "PackedScene"), "Missing scene: %s" % path)
	if not ResourceLoader.exists(path, "PackedScene"):
		return

	var packed_scene := load(path) as PackedScene
	_check(packed_scene != null, "Failed to load scene: %s" % path)
	if packed_scene == null:
		return

	var instance := packed_scene.instantiate()
	_check(instance != null, "Failed to instantiate scene: %s" % path)
	if instance != null:
		instance.free()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

