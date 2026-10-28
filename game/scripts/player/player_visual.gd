extends Node2D

const FRAME_DURATION := 0.14

const COLOR_SHADOW := Color(0.01, 0.02, 0.05, 0.45)
const COLOR_HAIR := Color("111827")
const COLOR_SKIN := Color("efb38f")
const COLOR_HOOD := Color("eadcc5")
const COLOR_HOODIE := Color("19345b")
const COLOR_HOODIE_LIGHT := Color("28507d")
const COLOR_PANTS := Color("111a2d")
const COLOR_SHOES := Color("d8e0e8")
const COLOR_EYES := Color("16233b")

var facing: StringName = &"down"
var is_moving := false
var animation_time := 0.0
var frame := 0


func set_motion(next_facing: StringName, moving: bool) -> void:
	facing = next_facing
	if is_moving != moving:
		is_moving = moving
		animation_time = 0.0
		frame = 0
		queue_redraw()


func _process(delta: float) -> void:
	if not is_moving:
		return

	animation_time += delta
	if animation_time >= FRAME_DURATION:
		animation_time -= FRAME_DURATION
		frame = (frame + 1) % 4
		queue_redraw()


func _draw() -> void:
	var step := 0
	if is_moving:
		step = -1 if frame in [1, 2] else 1

	draw_rect(Rect2(-10, 4, 20, 4), COLOR_SHADOW)
	_draw_legs(step)
	_draw_body()

	match facing:
		&"up":
			_draw_back_head()
		&"left":
			_draw_side_head(-1)
		&"right":
			_draw_side_head(1)
		_:
			_draw_front_head()


func _draw_legs(step: int) -> void:
	var left_step := step
	var right_step := -step
	if facing in [&"left", &"right"]:
		left_step = 0
		right_step = step

	draw_rect(Rect2(-8, -8 + left_step, 6, 12), COLOR_PANTS)
	draw_rect(Rect2(2, -8 + right_step, 6, 12), COLOR_PANTS)
	draw_rect(Rect2(-9, 2 + left_step, 8, 4), COLOR_SHOES)
	draw_rect(Rect2(1, 2 + right_step, 8, 4), COLOR_SHOES)


func _draw_body() -> void:
	draw_rect(Rect2(-12, -25, 24, 19), COLOR_HOODIE)
	draw_rect(Rect2(-10, -23, 20, 4), COLOR_HOODIE_LIGHT)
	draw_rect(Rect2(-15, -22, 5, 14), COLOR_HOODIE)
	draw_rect(Rect2(10, -22, 5, 14), COLOR_HOODIE)
	draw_rect(Rect2(-14, -10, 4, 4), COLOR_SKIN)
	draw_rect(Rect2(10, -10, 4, 4), COLOR_SKIN)


func _draw_front_head() -> void:
	draw_rect(Rect2(-11, -39, 22, 16), COLOR_SKIN)
	draw_rect(Rect2(-12, -40, 24, 6), COLOR_HAIR)
	draw_rect(Rect2(-12, -36, 5, 8), COLOR_HAIR)
	draw_rect(Rect2(7, -36, 5, 8), COLOR_HAIR)
	draw_rect(Rect2(-6, -31, 3, 3), COLOR_EYES)
	draw_rect(Rect2(3, -31, 3, 3), COLOR_EYES)
	draw_rect(Rect2(-10, -25, 20, 4), COLOR_HOOD)


func _draw_back_head() -> void:
	draw_rect(Rect2(-11, -39, 22, 16), COLOR_HAIR)
	draw_rect(Rect2(-12, -40, 24, 7), COLOR_HAIR)
	draw_rect(Rect2(-10, -26, 20, 6), COLOR_HOOD)
	draw_rect(Rect2(-7, -23, 14, 4), COLOR_HOODIE_LIGHT)


func _draw_side_head(side: int) -> void:
	draw_rect(Rect2(-10, -39, 20, 16), COLOR_SKIN)
	draw_rect(Rect2(-11, -40, 22, 6), COLOR_HAIR)
	draw_rect(Rect2(-11 if side < 0 else 6, -36, 5, 9), COLOR_HAIR)
	var eye_x := -6 if side < 0 else 3
	draw_rect(Rect2(eye_x, -31, 3, 3), COLOR_EYES)
	draw_rect(Rect2(-9, -25, 18, 4), COLOR_HOOD)

