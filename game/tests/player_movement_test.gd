extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_room := load("res://scenes/system/test_room.tscn") as PackedScene
	_check(packed_room != null, "Failed to load test room")
	if packed_room == null:
		_finish()
		return

	var room := packed_room.instantiate()
	root.add_child(room)
	await process_frame
	await physics_frame

	var player := room.get_node("Player") as CharacterBody2D
	_check(player != null, "Player node is missing")
	if player == null:
		_finish()
		return

	var start_position := player.global_position
	Input.action_press("move_right")
	await _wait_physics_frames(8)
	Input.action_release("move_right")
	_check(player.global_position.x > start_position.x, "Player did not move right")
	_check(player.get("facing_name") == &"right", "Player did not preserve right-facing state")

	var horizontal_distance: float = player.global_position.distance_to(start_position)
	player.global_position = start_position
	Input.action_press("move_right")
	Input.action_press("move_down")
	await _wait_physics_frames(8)
	Input.action_release("move_right")
	Input.action_release("move_down")
	var diagonal_distance: float = player.global_position.distance_to(start_position)
	_check(absf(horizontal_distance - diagonal_distance) <= 2.0, "Diagonal speed is not normalized")

	player.global_position = Vector2(24, 100)
	Input.action_press("move_left")
	await _wait_physics_frames(20)
	Input.action_release("move_left")
	_check(player.global_position.x >= 21.0, "Player moved through the left wall")

	var camera := player.get_node("Camera2D") as Camera2D
	_check(camera != null, "Player camera is missing")
	if camera != null:
		_check(not camera.position_smoothing_enabled, "Pixel camera smoothing must stay disabled")

	player.global_position = Vector2(240, 116)
	player.set("facing_direction", Vector2.UP)
	player.set("facing_name", &"up")
	player.get_node("InteractionArea").position = Vector2(0, -19)
	await _wait_physics_frames(2)
	var interaction_succeeded: bool = player.call("_try_interact")
	_check(interaction_succeeded, "Player interaction detector did not find the terminal")

	room.queue_free()
	await process_frame
	_finish()


func _wait_physics_frames(count: int) -> void:
	for _index in count:
		await physics_frame


func _finish() -> void:
	if failures.is_empty():
		print("P2 player movement test passed.")
		quit()
		return

	for failure in failures:
		push_error(failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

