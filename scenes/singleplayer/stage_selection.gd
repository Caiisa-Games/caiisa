class_name StageSelection
extends Control

const PAGE_WIDTH := 1152.0
const PAGE_CENTERS := [576.0, 1728.0, 2880.0, 4032.0]
const PAGE_SLIDE_DURATION := 0.22
const PIECE_SELECTION_SCENE := "res://scenes/piece_selection.tscn"
const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var buttons: Dictionary[int, Button] = {
	1: $PageContent/Button1, 2: $PageContent/Button2, 3: $PageContent/Button3, 4: $PageContent/Button4, 5: $PageContent/Button5,
	6: $PageContent/Button6, 7: $PageContent/Button7, 8: $PageContent/Button8, 9: $PageContent/Button9, 10: $PageContent/Button10,
	11: $PageContent/Button11, 12: $PageContent/Button12, 13: $PageContent/Button13, 14: $PageContent/Button14, 15: $PageContent/Button15,
	16: $PageContent/Button16, 17: $PageContent/Button17, 18: $PageContent/Button18, 19: $PageContent/Button19, 20: $PageContent/Button20,
}
@onready var previous_button: TextureButton = $HUD/Navigation/PreviousButton
@onready var next_button: TextureButton = $HUD/Navigation/NextButton

var current_page := 0
var is_moving := false

func _ready() -> void:
	AudioManager.play_music(preload("res://assets/sound/music_menu.ogg"))
	_update_stage_buttons()
	current_page = clampi((GameState.highest_unlocked_stage - 1) / 5, 0, PAGE_CENTERS.size() - 1)
	_set_page(current_page, false)

func _update_stage_buttons() -> void:
	for stage_num: int in buttons:
		var button := buttons[stage_num]
		var is_unlocked := GameState.is_stage_unlocked(stage_num)
		if stage_num % 5 == 0:
			button.text = tr("stage_label") % stage_num
		button.disabled = not is_unlocked
		button.tooltip_text = tr("stage_tooltip") % stage_num if is_unlocked else tr("stage_locked_tooltip")
		if is_unlocked and not button.pressed.is_connected(_on_stage_pressed):
			button.pressed.connect(_on_stage_pressed.bind(stage_num))

func _on_stage_pressed(stage_num: int) -> void:
	if not GameState.is_stage_unlocked(stage_num):
		return
	GameState.current_stage = stage_num
	GameState.game_mode = GameState.GameMode.SINGLEPLAYER
	get_tree().change_scene_to_file(PIECE_SELECTION_SCENE)

func _go_to_previous_page() -> void:
	_set_page(current_page - 1)

func _go_to_next_page() -> void:
	_set_page(current_page + 1)

func _set_page(page: int, animate := true) -> void:
	if is_moving:
		return
	var target_page := clampi(page, 0, PAGE_CENTERS.size() - 1)
	if target_page == current_page and animate:
		_update_navigation_buttons()
		return
	current_page = target_page
	var target_x: float = PAGE_CENTERS[current_page]
	if animate:
		is_moving = true
		_update_navigation_buttons()
		var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property($Camera2D, "position:x", target_x, PAGE_SLIDE_DURATION)
		await tween.finished
		is_moving = false
	else:
		$Camera2D.position.x = target_x
	_update_navigation_buttons()

func _update_navigation_buttons() -> void:
	previous_button.disabled = current_page == 0 or is_moving
	next_button.disabled = current_page == PAGE_CENTERS.size() - 1 or is_moving

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
