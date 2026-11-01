extends Node

const TITLE_SCREEN_PATH := "res://scenes/ui/title_screen.tscn"


func _ready() -> void:
	call_deferred("_open_title_screen")


func _open_title_screen() -> void:
	var error := get_tree().change_scene_to_file(TITLE_SCREEN_PATH)
	if error != OK:
		push_error("Failed to open title screen: %s" % error_string(error))
