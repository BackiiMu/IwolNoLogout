extends Node

const BASE_SIZE := Vector2i(320, 180)
const DEFAULT_WINDOW_SCALE := 4
const MIN_WINDOW_SCALE := 2
const MAX_WINDOW_SCALE := 6

var window_scale := DEFAULT_WINDOW_SCALE


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return

	var position_was_requested := OS.get_cmdline_args().has("--position")
	set_window_scale(DEFAULT_WINDOW_SCALE, not position_was_requested)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		toggle_fullscreen()
		get_viewport().set_input_as_handled()


func toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		set_window_scale(window_scale)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func set_window_scale(scale: int, center_window := true) -> void:
	window_scale = clampi(scale, MIN_WINDOW_SCALE, MAX_WINDOW_SCALE)
	if DisplayServer.get_name() == "headless":
		return
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		return

	DisplayServer.window_set_size(BASE_SIZE * window_scale)
	if center_window:
		call_deferred("_center_window")


func _center_window() -> void:
	var screen := DisplayServer.window_get_current_screen()
	var screen_position := DisplayServer.screen_get_position(screen)
	var screen_size := DisplayServer.screen_get_size(screen)
	var window_size := DisplayServer.window_get_size()
	DisplayServer.window_set_position(screen_position + (screen_size - window_size) / 2)

