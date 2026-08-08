class_name StageSelection
extends Control

@onready var buttons = {
	1: get_node_or_null("GridContainer/Button1"),
	2: get_node_or_null("GridContainer/Button2"),
	3: get_node_or_null("GridContainer/Button3"),
	4: get_node_or_null("GridContainer/Button4"),
	5: get_node_or_null("GridContainer/Button5"),
	6: get_node_or_null("GridContainer/Button6"),
	7: get_node_or_null("GridContainer/Button7"),
	8: get_node_or_null("GridContainer/Button8"),
	9: get_node_or_null("GridContainer/Button9"),
	10: get_node_or_null("GridContainer/Button10"),
	11: get_node_or_null("GridContainer/Button11"),
	12: get_node_or_null("GridContainer/Button12"),
	13: get_node_or_null("GridContainer/Button13"),
	14: get_node_or_null("GridContainer/Button14"),
	15: get_node_or_null("GridContainer/Button15")
}

@onready var safe_btn_5: Button = get_node_or_null("SafeButton5")
@onready var safe_btn_10: Button = get_node_or_null("SafeButton10")
@onready var safe_btn_15: Button = get_node_or_null("SafeButton15")

const BUFF_POPUP_SCENE = preload("res://scenes/singleplayer/stage_buff_screen.tscn")

func _ready() -> void:
	_update_stage_buttons()
	_update_safe_buttons()

func _update_stage_buttons() -> void:
	var unlocked_stage = GameState.highest_unlocked_stage
	for stage_num in buttons:
		var btn = buttons[stage_num]
		if btn:
			if stage_num <= unlocked_stage:
				btn.disabled = false
				if not btn.pressed.is_connected(_on_stage_pressed):
					btn.pressed.connect(_on_stage_pressed.bind(stage_num))
			else:
				btn.disabled = true

func _update_safe_buttons() -> void:
	var unlocked = GameState.highest_unlocked_stage
	_setup_single_safe(safe_btn_5, 5, unlocked > 5 and not GameState.popup_shown_5)
	_setup_single_safe(safe_btn_10, 10, unlocked > 10 and not GameState.popup_shown_10)
	_setup_single_safe(safe_btn_15, 15, unlocked > 15 and not GameState.popup_shown_15)

func _setup_single_safe(btn: Button, stage_num: int, is_active: bool) -> void:
	if not btn: return
	
	btn.disabled = not is_active
	if is_active:
		btn.modulate = Color.GOLD 
		if not btn.pressed.is_connected(_open_safe_popup):
			btn.pressed.connect(_open_safe_popup.bind(stage_num))
	else:
		btn.modulate = Color.DARK_GRAY

func _open_safe_popup(stage_num: int) -> void:
	GameState.current_stage = stage_num
	if BUFF_POPUP_SCENE:
		var popup = BUFF_POPUP_SCENE.instantiate() as StageBuffPopup
		add_child(popup)
		popup.buff_selected.connect(_update_safe_buttons)

func _on_stage_pressed(stage_num: int) -> void:
	GameState.current_stage = stage_num
	GameState.game_mode = GameState.GameMode.STAGE
	get_tree().change_scene_to_file("res://scenes/piece_selection.tscn")
