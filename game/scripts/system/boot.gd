extends Node

const TEST_ROOM_PATH := "res://scenes/system/test_room.tscn"


func _ready() -> void:
	call_deferred("_open_test_room")


func _open_test_room() -> void:
	var error := get_tree().change_scene_to_file(TEST_ROOM_PATH)
	if error != OK:
		push_error("Failed to open test room: %s" % error_string(error))

