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
	_check_scene("res://scenes/ui/title_screen.tscn")
	_check_scene("res://scenes/ui/screen_gallery.tscn")
	_check_scene("res://scenes/ui/screen_layout_base.tscn")
	_check_scene("res://scenes/system/test_room.tscn")
	_check_scene("res://scenes/player/player.tscn")
	_check(ResourceLoader.exists("res://ui/themes/bright_theme.tres"), "Missing bright UI theme")
	_check_screen_catalog()

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


func _check_screen_catalog() -> void:
	var catalog_path := "res://data/ui/screen_catalog.json"
	_check(FileAccess.file_exists(catalog_path), "Missing UI screen catalog")
	if not FileAccess.file_exists(catalog_path):
		return
	var file := FileAccess.open(catalog_path, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	_check(parsed is Array, "UI screen catalog must be an array")
	if not (parsed is Array):
		return
	var entries: Array = parsed
	_check(entries.size() == 43, "UI screen catalog must contain 43 screens")
	for entry in entries:
		if not (entry is Dictionary):
			_check(false, "UI screen catalog entry must be a dictionary")
			continue
		var scene_path := str(entry.get("scene", ""))
		var preview_path := str(entry.get("preview", ""))
		_check_scene(scene_path)
		_check(ResourceLoader.exists(preview_path, "Texture2D"), "Missing UI preview: %s" % preview_path)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

