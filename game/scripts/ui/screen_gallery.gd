extends Control

const CATALOG_PATH := "res://data/ui/screen_catalog.json"
const TITLE_SCREEN_PATH := "res://scenes/ui/title_screen.tscn"

@export_range(1, 43) var initial_screen := 1

@onready var preview: TextureRect = $Preview
@onready var title_label: Label = $Header/Title
@onready var index_label: Label = $Footer/Index

var screens: Array[Dictionary] = []
var current_index := 0


func _ready() -> void:
	_load_catalog()
	if screens.is_empty():
		return
	current_index = clampi(initial_screen - 1, 0, screens.size() - 1)
	_show_current_screen()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_accept"):
		_step(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left"):
		_step(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_return_to_title()
		get_viewport().set_input_as_handled()


func _load_catalog() -> void:
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open UI screen catalog")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Array):
		push_error("UI screen catalog must be an array")
		return
	for entry in parsed:
		if entry is Dictionary:
			screens.append(entry)


func _step(direction: int) -> void:
	if screens.is_empty():
		return
	current_index = wrapi(current_index + direction, 0, screens.size())
	_show_current_screen()


func _show_current_screen() -> void:
	var entry := screens[current_index]
	var texture_path := str(entry.get("preview", ""))
	var texture := load(texture_path) as Texture2D
	if texture == null:
		push_error("Failed to load UI gallery texture: %s" % texture_path)
		return
	preview.texture = texture
	title_label.text = "%02d  %s" % [int(entry.get("id", 0)), str(entry.get("title", ""))]
	index_label.text = "%02d / %02d" % [current_index + 1, screens.size()]


func _return_to_title() -> void:
	var error := get_tree().change_scene_to_file(TITLE_SCREEN_PATH)
	if error != OK:
		push_error("Failed to return to title: %s" % error_string(error))
