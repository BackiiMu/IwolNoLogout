extends Control

@export_range(1, 43) var screen_id := 1
@export var screen_title := ""
@export_file("*.png") var preview_texture_path := ""

@onready var preview: TextureRect = $Preview


func _ready() -> void:
	var texture := load(preview_texture_path) as Texture2D
	if texture == null:
		push_error("Failed to load UI preview: %s" % preview_texture_path)
		return
	preview.texture = texture


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var error := get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
		if error != OK:
			push_error("Failed to return to title: %s" % error_string(error))
		get_viewport().set_input_as_handled()
