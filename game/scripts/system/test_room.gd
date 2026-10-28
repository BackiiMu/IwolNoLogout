extends Node2D

const GRID_SIZE := 16
const WORLD_SIZE := Vector2i(640, 360)

@onready var message_panel: ColorRect = $Hud/MessagePanel
@onready var message_label: Label = $Hud/MessagePanel/MessageLabel
@onready var terminal: Area2D = $Interactables/TestTerminal

var message_sequence := 0


func _ready() -> void:
	terminal.message_requested.connect(_show_message)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("07112a"))
	draw_rect(Rect2(16, 16, 608, 328), Color("152747"))

	for x in range(16, WORLD_SIZE.x - 15, GRID_SIZE):
		draw_line(Vector2(x, 16), Vector2(x, WORLD_SIZE.y - 16), Color("20385c"), 1.0)
	for y in range(16, WORLD_SIZE.y - 15, GRID_SIZE):
		draw_line(Vector2(16, y), Vector2(WORLD_SIZE.x - 16, y), Color("20385c"), 1.0)

	draw_rect(Rect2(128, 164, 64, 32), Color("243f68"))
	draw_rect(Rect2(448, 164, 64, 32), Color("243f68"))
	draw_circle(Vector2(320, 180), 30, Color("1a6e83"))
	draw_circle(Vector2(320, 180), 20, Color("24c7d9"), false, 2.0)


func _show_message(message: String) -> void:
	message_sequence += 1
	var current_sequence := message_sequence
	message_label.text = message
	message_panel.visible = true
	await get_tree().create_timer(1.5).timeout
	if current_sequence == message_sequence:
		message_panel.visible = false

