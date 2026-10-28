extends CanvasLayer

@onready var info_label: Label = $Panel/InfoLabel

var is_visible := true


func _ready() -> void:
	visible = is_visible


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		is_visible = not is_visible
		visible = is_visible
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not is_visible:
		return

	var fps := Engine.get_frames_per_second()
	var viewport_size := get_viewport().get_visible_rect().size
	info_label.text = "이동 테스트  |  %dx%d  |  %d FPS  |  F3 디버그  F11 전체 화면" % [
		int(viewport_size.x),
		int(viewport_size.y),
		fps,
	]

