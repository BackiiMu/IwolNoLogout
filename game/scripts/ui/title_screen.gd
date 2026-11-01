extends Control

const TEST_ROOM_PATH := "res://scenes/system/test_room.tscn"
const GALLERY_PATH := "res://scenes/ui/screen_gallery.tscn"

const COLOR_BACKGROUND := Color("f7fcff")
const COLOR_SURFACE := Color("e8f7ff")
const COLOR_PANEL := Color("ffffff")
const COLOR_OUTLINE := Color("14324a")
const COLOR_CYAN := Color("00b8d9")
const COLOR_CORAL := Color("ff5573")

@onready var new_game_button: Button = $MenuPanel/Menu/NewGameButton
@onready var quit_button: Button = $MenuPanel/Menu/QuitButton
@onready var gallery_button: Button = $GalleryButton
@onready var exit_overlay: ColorRect = $ExitOverlay
@onready var confirm_exit_button: Button = $ExitOverlay/ConfirmPanel/Buttons/ConfirmExitButton
@onready var cancel_exit_button: Button = $ExitOverlay/ConfirmPanel/Buttons/CancelExitButton


func _ready() -> void:
	new_game_button.pressed.connect(_start_new_game)
	quit_button.pressed.connect(_request_exit)
	gallery_button.pressed.connect(_open_gallery)
	confirm_exit_button.pressed.connect(_confirm_exit)
	cancel_exit_button.pressed.connect(_cancel_exit)
	exit_overlay.visible = false
	gallery_button.visible = OS.is_debug_build()
	new_game_button.grab_focus()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 320, 180), COLOR_BACKGROUND)
	draw_rect(Rect2(144, 20, 164, 134), COLOR_SURFACE)
	draw_rect(Rect2(152, 30, 76, 48), COLOR_PANEL)
	draw_rect(Rect2(160, 37, 42, 25), COLOR_SURFACE)
	draw_rect(Rect2(160, 37, 42, 25), COLOR_OUTLINE, false, 2.0)
	draw_rect(Rect2(174, 45, 14, 7), COLOR_CYAN)
	draw_rect(Rect2(178, 62, 6, 17), COLOR_OUTLINE)
	draw_rect(Rect2(158, 78, 47, 4), COLOR_OUTLINE)
	draw_rect(Rect2(151, 92, 77, 13), COLOR_PANEL)
	draw_rect(Rect2(250, 34, 48, 106), COLOR_PANEL)
	draw_rect(Rect2(250, 34, 48, 106), COLOR_OUTLINE, false, 2.0)
	draw_rect(Rect2(250, 57, 4, 17), COLOR_CYAN)
	draw_rect(Rect2(294, 57, 4, 17), COLOR_CORAL)
	draw_rect(Rect2(250, 104, 4, 17), COLOR_CORAL)
	draw_rect(Rect2(294, 104, 4, 17), COLOR_CYAN)
	draw_rect(Rect2(270, 84, 6, 6), COLOR_CYAN)
	_draw_tuto(Vector2(230, 112))


func _draw_tuto(origin: Vector2) -> void:
	draw_rect(Rect2(origin + Vector2(4, 0), Vector2(14, 20)), COLOR_OUTLINE)
	draw_rect(Rect2(origin + Vector2(0, 5), Vector2(22, 10)), COLOR_OUTLINE)
	draw_rect(Rect2(origin + Vector2(6, 5), Vector2(10, 8)), COLOR_PANEL)
	draw_rect(Rect2(origin + Vector2(8, 7), Vector2(2, 3)), COLOR_CYAN)
	draw_rect(Rect2(origin + Vector2(13, 7), Vector2(2, 3)), COLOR_CORAL)
	draw_rect(Rect2(origin + Vector2(1, 8), Vector2(2, 4)), COLOR_CYAN)
	draw_rect(Rect2(origin + Vector2(19, 8), Vector2(2, 4)), COLOR_CORAL)
	draw_rect(Rect2(origin + Vector2(6, 20), Vector2(3, 3)), COLOR_OUTLINE)
	draw_rect(Rect2(origin + Vector2(14, 20), Vector2(3, 3)), COLOR_OUTLINE)


func _unhandled_input(event: InputEvent) -> void:
	if exit_overlay.visible and event.is_action_pressed("ui_cancel"):
		_cancel_exit()
		get_viewport().set_input_as_handled()


func _start_new_game() -> void:
	var error := get_tree().change_scene_to_file(TEST_ROOM_PATH)
	if error != OK:
		push_error("Failed to open test room: %s" % error_string(error))


func _request_exit() -> void:
	exit_overlay.visible = true
	_set_main_menu_focus_enabled(false)
	cancel_exit_button.grab_focus()


func _open_gallery() -> void:
	var error := get_tree().change_scene_to_file(GALLERY_PATH)
	if error != OK:
		push_error("Failed to open UI gallery: %s" % error_string(error))


func _cancel_exit() -> void:
	exit_overlay.visible = false
	_set_main_menu_focus_enabled(true)
	quit_button.grab_focus()


func _confirm_exit() -> void:
	get_tree().quit()


func _set_main_menu_focus_enabled(enabled: bool) -> void:
	var focus_mode := Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	new_game_button.focus_mode = focus_mode
	quit_button.focus_mode = focus_mode
	gallery_button.focus_mode = focus_mode
