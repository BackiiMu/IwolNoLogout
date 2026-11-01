extends Node2D

const FRAME_DURATION := 0.14
const FRAME_SEQUENCE := [0, 1, 0, 2]
const SPRITE_SHEET := preload("res://assets/characters/iwol_walk_32x48_v1.png")

var facing: StringName = &"down"
var is_moving := false
var animation_time := 0.0
var frame := 0


func set_motion(next_facing: StringName, moving: bool) -> void:
	var motion_changed := facing != next_facing or is_moving != moving
	facing = next_facing
	is_moving = moving
	if motion_changed:
		animation_time = 0.0
		frame = 0
		queue_redraw()


func _process(delta: float) -> void:
	if not is_moving:
		return

	animation_time += delta
	if animation_time >= FRAME_DURATION:
		animation_time -= FRAME_DURATION
		frame = (frame + 1) % FRAME_SEQUENCE.size()
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-10, 0, 20, 4), Color(0.01, 0.02, 0.05, 0.35))
	var frame_column: int = FRAME_SEQUENCE[frame] if is_moving else 0
	var source_region := Rect2(frame_column * 32, _get_direction_row() * 48, 32, 48)
	draw_texture_rect_region(SPRITE_SHEET, Rect2(-16, -47, 32, 48), source_region)


func _get_direction_row() -> int:
	match facing:
		&"left":
			return 1
		&"right":
			return 2
		&"up":
			return 3
		_:
			return 0
