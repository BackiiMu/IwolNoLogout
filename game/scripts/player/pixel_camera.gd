extends Camera2D

@export var camera_offset := Vector2(0, -14)

@onready var target := get_parent() as Node2D


func _ready() -> void:
	top_level = true
	_update_position()


func _process(_delta: float) -> void:
	_update_position()


func _update_position() -> void:
	if target == null:
		return
	global_position = (target.global_position + camera_offset).round()
