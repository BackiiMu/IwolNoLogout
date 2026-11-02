extends Node

const SAVE_PATH := "user://save_v1.json"
const TEMP_SAVE_PATH := "user://save_v1.tmp"
const SAVE_FILE_NAME := "save_v1.json"
const TEMP_SAVE_FILE_NAME := "save_v1.tmp"
const BACKUP_SAVE_FILE_NAME := "save_v1.backup"
const SAVE_VERSION := 1

var data: Dictionary = {}


func _ready() -> void:
	if not load_game():
		data = _default_state()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func start_new_game() -> bool:
	data = _default_state()
	return save_game()


func load_game() -> bool:
	if not has_save():
		return false
	var raw_text := FileAccess.get_file_as_string(SAVE_PATH)
	var parsed: Variant = JSON.parse_string(raw_text)
	if not (parsed is Dictionary):
		push_error("Save file is not a valid dictionary.")
		return false
	var loaded_data := parsed as Dictionary
	if int(loaded_data.get("version", 0)) != SAVE_VERSION:
		push_error("Unsupported save version: %s" % loaded_data.get("version", 0))
		return false
	data = _normalize_state(loaded_data)
	return true


func save_game() -> bool:
	data["updated_at_unix"] = int(Time.get_unix_time_from_system())
	var file := FileAccess.open(TEMP_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open temporary save file.")
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	file = null

	var user_directory := DirAccess.open("user://")
	if user_directory == null:
		push_error("Failed to open user data directory.")
		return false
	if user_directory.file_exists(BACKUP_SAVE_FILE_NAME):
		user_directory.remove(BACKUP_SAVE_FILE_NAME)
	if user_directory.file_exists(SAVE_FILE_NAME):
		var backup_error := user_directory.rename(SAVE_FILE_NAME, BACKUP_SAVE_FILE_NAME)
		if backup_error != OK:
			push_error("Failed to create save backup: %s" % error_string(backup_error))
			user_directory.remove(TEMP_SAVE_FILE_NAME)
			return false

	var rename_error := user_directory.rename(TEMP_SAVE_FILE_NAME, SAVE_FILE_NAME)
	if rename_error != OK:
		push_error("Failed to finalize save: %s" % error_string(rename_error))
		if user_directory.file_exists(BACKUP_SAVE_FILE_NAME):
			user_directory.rename(BACKUP_SAVE_FILE_NAME, SAVE_FILE_NAME)
		return false

	if user_directory.file_exists(BACKUP_SAVE_FILE_NAME):
		user_directory.remove(BACKUP_SAVE_FILE_NAME)
	return true


func get_phase() -> String:
	return str(data.get("phase", "prologue"))


func set_phase(phase: String) -> bool:
	data["phase"] = phase
	return save_game()


func get_story_index() -> int:
	return int(data.get("story_index", 0))


func set_story_index(index: int) -> bool:
	data["story_index"] = maxi(index, 0)
	data["phase"] = "prologue"
	return save_game()


func record_first_impression(round_number: int, candidate_id: String) -> bool:
	var round_state := _get_round_state(round_number)
	if str(round_state.get("status", "unresolved")) != "unresolved":
		return false
	round_state["first_impression"] = candidate_id
	data["phase"] = "selection_reveal"
	return save_game()


func mark_decision_ready(round_number: int) -> bool:
	var round_state := _get_round_state(round_number)
	if str(round_state.get("status", "unresolved")) != "unresolved":
		return false
	round_state["profiles_revealed"] = true
	data["phase"] = "selection_decision"
	return save_game()


func confirm_companion(round_number: int, candidate_id: String) -> bool:
	if str(data.get("companion_id", "")) != "":
		return false
	var round_state := _get_round_state(round_number)
	if str(round_state.get("status", "unresolved")) != "unresolved":
		return false
	round_state["status"] = "companion"
	round_state["selected_candidate_id"] = candidate_id
	data["companion_id"] = candidate_id
	data["selection_locked"] = true
	data["phase"] = "selection_result"
	return save_game()


func abandon_round(round_number: int, candidate_ids: Array[String]) -> bool:
	if bool(data.get("selection_locked", false)):
		return false
	var round_state := _get_round_state(round_number)
	if str(round_state.get("status", "unresolved")) != "unresolved":
		return false
	round_state["status"] = "abandoned"
	round_state["abandoned_candidate_ids"] = candidate_ids
	data["current_round"] = round_number + 1
	data["phase"] = "selection_result"
	return save_game()


func get_round_state(round_number: int) -> Dictionary:
	return _get_round_state(round_number).duplicate(true)


func get_companion_id() -> String:
	return str(data.get("companion_id", ""))


func _get_round_state(round_number: int) -> Dictionary:
	var rounds := data.get("rounds", {}) as Dictionary
	var round_key := str(round_number)
	if not rounds.has(round_key):
		rounds[round_key] = _default_round_state()
	data["rounds"] = rounds
	return rounds[round_key] as Dictionary


func _normalize_state(loaded_data: Dictionary) -> Dictionary:
	var normalized := _default_state()
	for key in loaded_data:
		normalized[key] = loaded_data[key]
	if not (normalized.get("rounds", {}) is Dictionary):
		normalized["rounds"] = {}
	return normalized


func _default_state() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"phase": "prologue",
		"story_index": 0,
		"current_round": 1,
		"companion_id": "",
		"selection_locked": false,
		"rounds": {},
		"updated_at_unix": 0,
	}


func _default_round_state() -> Dictionary:
	return {
		"status": "unresolved",
		"first_impression": "",
		"profiles_revealed": false,
		"selected_candidate_id": "",
		"abandoned_candidate_ids": [],
	}
