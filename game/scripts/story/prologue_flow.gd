extends Control

const TITLE_SCREEN_PATH := "res://scenes/ui/title_screen.tscn"
const PROLOGUE_DATA_PATH := "res://data/story/prologue.json"
const ROUND_DATA_PATH := "res://data/candidates/round_01.json"

const COLOR_BACKGROUND := Color("f7fcff")
const COLOR_SURFACE := Color("e8f7ff")
const COLOR_PANEL := Color("ffffff")
const COLOR_OUTLINE := Color("14324a")
const COLOR_CYAN := Color("00b8d9")
const COLOR_CORAL := Color("ff5573")
const COLOR_WARNING := Color("ffd166")

@onready var scene_title: Label = $TopBar/SceneTitle
@onready var progress_label: Label = $TopBar/Progress
@onready var visual_title: Label = $StoryStage/VisualTitle
@onready var visual_body: Label = $StoryStage/VisualBody
@onready var chat_text: Label = $ChatPanel/ChatText
@onready var dialogue_panel: Panel = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/Speaker
@onready var dialogue_text: Label = $DialoguePanel/DialogueText
@onready var advance_button: Button = $DialoguePanel/AdvanceButton
@onready var selection_layer: Control = $SelectionLayer
@onready var phase_title: Label = $SelectionLayer/PhaseTitle
@onready var instruction: Label = $SelectionLayer/Instruction
@onready var candidate_a_button: Button = $SelectionLayer/CandidateAButton
@onready var candidate_b_button: Button = $SelectionLayer/CandidateBButton
@onready var impression_buttons: HBoxContainer = $SelectionLayer/ImpressionButtons
@onready var impression_a_button: Button = $SelectionLayer/ImpressionButtons/ImpressionAButton
@onready var impression_b_button: Button = $SelectionLayer/ImpressionButtons/ImpressionBButton
@onready var impression_hold_button: Button = $SelectionLayer/ImpressionButtons/ImpressionHoldButton
@onready var reveal_continue_button: Button = $SelectionLayer/RevealContinueButton
@onready var abandon_button: Button = $SelectionLayer/AbandonButton
@onready var confirm_overlay: ColorRect = $ConfirmOverlay
@onready var confirm_title: Label = $ConfirmOverlay/ConfirmPanel/Title
@onready var confirm_body: Label = $ConfirmOverlay/ConfirmPanel/Body
@onready var confirm_button: Button = $ConfirmOverlay/ConfirmPanel/ConfirmButton
@onready var cancel_button: Button = $ConfirmOverlay/ConfirmPanel/CancelButton
@onready var result_overlay: ColorRect = $ResultOverlay
@onready var result_title: Label = $ResultOverlay/ResultPanel/Title
@onready var result_body: Label = $ResultOverlay/ResultPanel/Body
@onready var return_title_button: Button = $ResultOverlay/ResultPanel/ReturnTitleButton

var prologue_data: Dictionary = {}
var round_data: Dictionary = {}
var beats: Array = []
var candidates: Array = []
var story_index := 0
var visual_mode := "broadcast"
var pending_choice := ""


func _ready() -> void:
	prologue_data = _load_json(PROLOGUE_DATA_PATH)
	round_data = _load_json(ROUND_DATA_PATH)
	beats = prologue_data.get("beats", []) as Array
	candidates = round_data.get("candidates", []) as Array
	if beats.is_empty() or candidates.size() != 2:
		push_error("Prologue or candidate data is incomplete.")
		return

	advance_button.pressed.connect(_advance_story)
	impression_a_button.pressed.connect(func() -> void: _record_impression(str(candidates[0].get("id", ""))))
	impression_b_button.pressed.connect(func() -> void: _record_impression(str(candidates[1].get("id", ""))))
	impression_hold_button.pressed.connect(func() -> void: _record_impression("undecided"))
	reveal_continue_button.pressed.connect(_advance_to_decision)
	candidate_a_button.pressed.connect(func() -> void: _request_candidate(str(candidates[0].get("id", ""))))
	candidate_b_button.pressed.connect(func() -> void: _request_candidate(str(candidates[1].get("id", ""))))
	abandon_button.pressed.connect(_request_abandon)
	confirm_button.pressed.connect(_confirm_pending_choice)
	cancel_button.pressed.connect(_close_confirmation)
	return_title_button.pressed.connect(_return_to_title)

	confirm_overlay.visible = false
	result_overlay.visible = false
	_restore_progress()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 320, 180), COLOR_BACKGROUND)
	for x in range(0, 320, 16):
		draw_line(Vector2(x, 0), Vector2(x, 180), Color(COLOR_CYAN, 0.035), 1.0)
	for y in range(0, 180, 16):
		draw_line(Vector2(0, y), Vector2(320, y), Color(COLOR_CYAN, 0.035), 1.0)
	if selection_layer.visible:
		return
	match visual_mode:
		"error", "glitch":
			draw_rect(Rect2(14, 34, 196, 82), Color("fff0f3"))
			draw_rect(Rect2(18, 40, 188, 4), COLOR_CORAL)
			for offset in [0, 17, 39, 68]:
				draw_rect(Rect2(22 + offset, 92 - offset % 13, 24, 3), Color(COLOR_CORAL, 0.5))
		"tuto", "tuto_warning":
			draw_rect(Rect2(14, 34, 196, 82), COLOR_SURFACE)
			_draw_tuto(Vector2(92, 56))
			if visual_mode == "tuto_warning":
				draw_rect(Rect2(20, 104, 184, 6), COLOR_WARNING)
		"gate":
			draw_rect(Rect2(14, 34, 196, 82), Color("eefcff"))
			draw_rect(Rect2(62, 48, 100, 58), COLOR_OUTLINE, false, 3.0)
			draw_rect(Rect2(72, 57, 80, 40), COLOR_CYAN, false, 2.0)
			draw_circle(Vector2(112, 77), 8, COLOR_CORAL, false, 2.0)
		_:
			draw_rect(Rect2(14, 34, 196, 82), COLOR_SURFACE)
			draw_rect(Rect2(24, 44, 92, 52), COLOR_PANEL)
			draw_rect(Rect2(24, 44, 92, 52), COLOR_OUTLINE, false, 2.0)
			draw_rect(Rect2(132, 44, 66, 52), COLOR_PANEL)
			draw_rect(Rect2(132, 44, 66, 52), COLOR_OUTLINE, false, 2.0)
			draw_rect(Rect2(31, 52, 78, 6), COLOR_CYAN)
			draw_rect(Rect2(31, 64, 54, 4), Color(COLOR_OUTLINE, 0.45))
			draw_rect(Rect2(31, 74, 66, 4), Color(COLOR_OUTLINE, 0.25))


func _draw_tuto(origin: Vector2) -> void:
	draw_rect(Rect2(origin + Vector2(10, 0), Vector2(28, 36)), COLOR_OUTLINE)
	draw_rect(Rect2(origin + Vector2(0, 9), Vector2(48, 18)), COLOR_OUTLINE)
	draw_rect(Rect2(origin + Vector2(13, 9), Vector2(22, 15)), COLOR_PANEL)
	draw_rect(Rect2(origin + Vector2(17, 13), Vector2(4, 5)), COLOR_CYAN)
	draw_rect(Rect2(origin + Vector2(29, 13), Vector2(4, 5)), COLOR_CORAL)
	draw_rect(Rect2(origin + Vector2(3, 14), Vector2(5, 7)), COLOR_CYAN)
	draw_rect(Rect2(origin + Vector2(40, 14), Vector2(5, 7)), COLOR_CORAL)


func _unhandled_input(event: InputEvent) -> void:
	if confirm_overlay.visible and event.is_action_pressed("ui_cancel"):
		_close_confirmation()
		get_viewport().set_input_as_handled()
		return
	if result_overlay.visible and event.is_action_pressed("ui_cancel"):
		_return_to_title()
		get_viewport().set_input_as_handled()
		return
	if not selection_layer.visible and event.is_action_pressed("ui_accept"):
		_advance_story()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		_return_to_title()
		get_viewport().set_input_as_handled()


func _restore_progress() -> void:
	match GameState.get_phase():
		"selection_limited":
			_show_limited_selection()
		"selection_reveal":
			_show_reveal()
		"selection_decision":
			_show_decision()
		"selection_result":
			_show_result()
		_:
			story_index = clampi(GameState.get_story_index(), 0, beats.size() - 1)
			_show_story_beat()


func _show_story_beat() -> void:
	selection_layer.visible = false
	dialogue_panel.visible = true
	$StoryStage.visible = true
	$ChatPanel.visible = true
	var beat := beats[story_index] as Dictionary
	visual_mode = str(beat.get("visual", "broadcast"))
	scene_title.text = str(prologue_data.get("title", "프롤로그"))
	progress_label.text = "%02d / %02d" % [story_index + 1, beats.size()]
	speaker_label.text = str(beat.get("speaker", ""))
	dialogue_text.text = str(beat.get("text", ""))
	visual_title.text = _visual_title_for(visual_mode)
	visual_body.text = _visual_body_for(visual_mode)
	chat_text.text = _chat_text_until(story_index)
	advance_button.text = "선택 시작" if story_index == beats.size() - 1 else "다음"
	advance_button.grab_focus()
	queue_redraw()


func _advance_story() -> void:
	if selection_layer.visible or confirm_overlay.visible or result_overlay.visible:
		return
	if story_index < beats.size() - 1:
		story_index += 1
		GameState.set_story_index(story_index)
		_show_story_beat()
		return
	GameState.set_phase("selection_limited")
	_show_limited_selection()


func _show_limited_selection() -> void:
	_prepare_selection_layer()
	phase_title.text = str(round_data.get("title", "라운드 1")) + " · 제한 정보"
	instruction.text = "이름과 얼굴은 아직 공개되지 않습니다. 더 믿음이 가는 쪽을 고르거나 판단을 보류하세요."
	candidate_a_button.text = _limited_card_text(candidates[0] as Dictionary)
	candidate_b_button.text = _limited_card_text(candidates[1] as Dictionary)
	candidate_a_button.disabled = true
	candidate_b_button.disabled = true
	impression_buttons.visible = true
	reveal_continue_button.visible = false
	abandon_button.visible = false
	progress_label.text = "1 / 3"
	impression_a_button.grab_focus()


func _record_impression(candidate_id: String) -> void:
	if GameState.record_first_impression(1, candidate_id):
		_show_reveal()


func _show_reveal() -> void:
	_prepare_selection_layer()
	phase_title.text = str(round_data.get("title", "라운드 1")) + " · 동시 공개"
	instruction.text = "첫인상은 기록됐지만 아직 확정이 아닙니다. 두 사람의 강점과 제약을 같은 기준으로 확인하세요."
	candidate_a_button.text = _profile_card_text(candidates[0] as Dictionary)
	candidate_b_button.text = _profile_card_text(candidates[1] as Dictionary)
	candidate_a_button.disabled = true
	candidate_b_button.disabled = true
	impression_buttons.visible = false
	reveal_continue_button.visible = true
	abandon_button.visible = false
	progress_label.text = "2 / 3"
	reveal_continue_button.grab_focus()


func _advance_to_decision() -> void:
	if GameState.mark_decision_ready(1):
		_show_decision()


func _show_decision() -> void:
	_prepare_selection_layer()
	phase_title.text = str(round_data.get("title", "라운드 1")) + " · 최종 결정"
	instruction.text = "한 명을 확정하면 이후 후보 선택이 종료됩니다. 둘 다 포기하면 두 사람은 다시 선택할 수 없습니다."
	candidate_a_button.text = _decision_card_text(candidates[0] as Dictionary)
	candidate_b_button.text = _decision_card_text(candidates[1] as Dictionary)
	candidate_a_button.disabled = false
	candidate_b_button.disabled = false
	impression_buttons.visible = false
	reveal_continue_button.visible = false
	abandon_button.visible = true
	progress_label.text = "3 / 3"
	candidate_a_button.grab_focus()


func _request_candidate(candidate_id: String) -> void:
	if GameState.get_phase() != "selection_decision":
		return
	var candidate := _candidate_by_id(candidate_id)
	pending_choice = candidate_id
	confirm_title.text = "%s을(를) 동행자로 확정할까요?" % candidate.get("name", "후보")
	confirm_body.text = "이 선택은 저장 즉시 고정됩니다.\n이후 라운드의 후보는 선택할 수 없습니다."
	confirm_button.text = "영구 확정"
	_open_confirmation()


func _request_abandon() -> void:
	if GameState.get_phase() != "selection_decision":
		return
	pending_choice = "abandon"
	confirm_title.text = "두 후보를 모두 포기할까요?"
	confirm_body.text = "서윤과 도윤은 영구히 선택할 수 없습니다.\n저장 후 라운드 2로 넘어갑니다."
	confirm_button.text = "둘 다 포기"
	_open_confirmation()


func _open_confirmation() -> void:
	confirm_overlay.visible = true
	_set_selection_focus_enabled(false)
	cancel_button.grab_focus()


func _close_confirmation() -> void:
	confirm_overlay.visible = false
	pending_choice = ""
	_set_selection_focus_enabled(true)
	candidate_a_button.grab_focus()


func _confirm_pending_choice() -> void:
	var saved := false
	if pending_choice == "abandon":
		var candidate_ids: Array[String] = [
			str(candidates[0].get("id", "")),
			str(candidates[1].get("id", "")),
		]
		saved = GameState.abandon_round(1, candidate_ids)
	elif pending_choice != "":
		saved = GameState.confirm_companion(1, pending_choice)
	if not saved:
		confirm_body.text = "저장하지 못했습니다. 선택은 적용되지 않았습니다.\n다시 시도해 주세요."
		return
	confirm_overlay.visible = false
	pending_choice = ""
	_show_result()


func _show_result() -> void:
	selection_layer.visible = false
	dialogue_panel.visible = false
	$StoryStage.visible = false
	$ChatPanel.visible = false
	result_overlay.visible = true
	scene_title.text = "라운드 1 결과"
	progress_label.text = "자동 저장 완료"
	var round_state := GameState.get_round_state(1)
	if str(round_state.get("status", "")) == "companion":
		var companion := _candidate_by_id(GameState.get_companion_id())
		result_title.text = "%s이(가) 동행자가 되었습니다" % companion.get("name", "후보")
		result_body.text = "%s\n\n이 동행자는 모든 챕터와 최종 선택까지 고정됩니다.\n다음 구현: 첫 탐색과 쿠나이 전투" % companion.get("first_line", "")
	else:
		result_title.text = "서윤과 도윤을 모두 포기했습니다"
		result_body.text = "두 후보는 다시 선택할 수 없습니다.\n라운드 2 진행 상태가 저장되었습니다.\n\n다음 후보 라운드는 이후 챕터에서 구현합니다."
	return_title_button.grab_focus()
	queue_redraw()


func _prepare_selection_layer() -> void:
	selection_layer.visible = true
	dialogue_panel.visible = false
	$StoryStage.visible = false
	$ChatPanel.visible = false
	result_overlay.visible = false
	scene_title.text = "동행자 인증"
	queue_redraw()


func _set_selection_focus_enabled(enabled: bool) -> void:
	var focus_mode := Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	candidate_a_button.focus_mode = focus_mode
	candidate_b_button.focus_mode = focus_mode
	abandon_button.focus_mode = focus_mode


func _limited_card_text(candidate: Dictionary) -> String:
	return "후보 %s\n\n역할  %s\n\n성향  %s\n\n제약  %s" % [
		candidate.get("slot", "?"),
		candidate.get("role", ""),
		candidate.get("limited_tendency", ""),
		candidate.get("limited_constraint", ""),
	]


func _profile_card_text(candidate: Dictionary) -> String:
	return "%s · %s\n%s\n\n강점  %s\n\n제약  %s\n\n“%s”" % [
		candidate.get("slot", "?"),
		candidate.get("name", ""),
		candidate.get("role", ""),
		candidate.get("strength", ""),
		candidate.get("constraint", ""),
		candidate.get("first_line", ""),
	]


func _decision_card_text(candidate: Dictionary) -> String:
	return "%s · %s\n%s\n\n%s\n\n이 후보를 동행자로 확정" % [
		candidate.get("slot", "?"),
		candidate.get("name", ""),
		candidate.get("role", ""),
		candidate.get("relationship_hook", ""),
	]


func _candidate_by_id(candidate_id: String) -> Dictionary:
	for candidate_value in candidates:
		var candidate := candidate_value as Dictionary
		if str(candidate.get("id", "")) == candidate_id:
			return candidate
	return {}


func _chat_text_until(index: int) -> String:
	var messages: Array[String] = []
	var start_index := maxi(0, index - 2)
	for beat_index in range(start_index, index + 1):
		var beat := beats[beat_index] as Dictionary
		var chat_messages := beat.get("chat", []) as Array
		for message_value in chat_messages:
			messages.append("• %s" % str(message_value))
	while messages.size() > 7:
		messages.pop_front()
	return "\n".join(PackedStringArray(messages))


func _visual_title_for(mode: String) -> String:
	match mode:
		"pending": return "종료 요청 중"
		"error": return "LOGOUT ERROR"
		"glitch": return "연결 공간 재구성"
		"tuto", "tuto_warning": return "안전 안내 AI · TUTO"
		"gate": return "COMPANION GATE"
		_: return "LIVE · 방송 종료 직전"


func _visual_body_for(mode: String) -> String:
	match mode:
		"pending": return "종료 신호가 응답하지 않습니다."
		"error": return "권한 확인 실패 · 세션 유지"
		"glitch": return "현실 입력 신호가 차단되었습니다."
		"tuto": return "복구 절차를 안내하겠습니다."
		"tuto_warning": return "방송 유지 상태: 안전"
		"gate": return "동행자 한 명을 인증하세요."
		_: return "시청자와 마지막 인사를 나누는 중"


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing data file: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		push_error("Invalid JSON data: %s" % path)
		return {}
	return parsed as Dictionary


func _return_to_title() -> void:
	var error := get_tree().change_scene_to_file(TITLE_SCREEN_PATH)
	if error != OK:
		push_error("Failed to return to title: %s" % error_string(error))
