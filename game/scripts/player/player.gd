class_name Player
extends CharacterBody2D

signal interaction_attempted(success: bool)

@export var move_speed := 72.0

@onready var player_visual: Node2D = $PlayerVisual
@onready var interaction_area: Area2D = $InteractionArea

var facing_direction := Vector2.DOWN
var facing_name: StringName = &"down"


func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed

	if not input_vector.is_zero_approx():
		_update_facing(input_vector)

	move_and_slide()
	player_visual.global_position = global_position.round()
	player_visual.call("set_motion", facing_name, not velocity.is_zero_approx())
	interaction_area.position = facing_direction * 14.0 + Vector2(0, -5)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interaction_attempted.emit(_try_interact())
		get_viewport().set_input_as_handled()


func _update_facing(input_vector: Vector2) -> void:
	if absf(input_vector.x) > absf(input_vector.y):
		if input_vector.x < 0.0:
			facing_direction = Vector2.LEFT
			facing_name = &"left"
		else:
			facing_direction = Vector2.RIGHT
			facing_name = &"right"
	else:
		if input_vector.y < 0.0:
			facing_direction = Vector2.UP
			facing_name = &"up"
		else:
			facing_direction = Vector2.DOWN
			facing_name = &"down"


func _try_interact() -> bool:
	for area in interaction_area.get_overlapping_areas():
		if area.has_method("interact"):
			area.call("interact", self)
			return true
	return false

