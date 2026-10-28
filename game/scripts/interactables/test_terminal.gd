extends Area2D

signal message_requested(message: String)


func _ready() -> void:
	queue_redraw()


func interact(_actor: Node) -> void:
	message_requested.emit("상호작용 성공  /  터미널 정상")


func _draw() -> void:
	draw_rect(Rect2(-12, -14, 24, 20), Color("0b1730"))
	draw_rect(Rect2(-9, -11, 18, 10), Color("24c7d9"))
	draw_rect(Rect2(-7, -9, 14, 6), Color("173e59"))
	draw_rect(Rect2(-8, 6, 16, 4), Color("eadcc5"))

