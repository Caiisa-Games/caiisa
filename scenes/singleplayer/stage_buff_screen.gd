class_name StageBuffPopup
extends Control

signal buff_selected

@onready var option1_btn: Button = $Option1Btn
@onready var option2_btn: Button = $Option2Btn

var current_stage: int = 1

func _ready() -> void:
	_setup_buttons()

func _setup_buttons() -> void:
	current_stage = GameState.current_stage
	if current_stage not in [11,6]:
		return
	option1_btn.text = tr("option1_stage_%d" % current_stage)
	option2_btn.text = tr("option2_stage_%d" % current_stage)

func _on_option1_pressed() -> void:
	_save_choice(1)
	buff_selected.emit()
	_redirect()

func _on_option2_pressed() -> void:
	_save_choice(2)
	buff_selected.emit()
	_redirect()

func _save_choice(choice: int) -> void:
	current_stage = GameState.current_stage
	if current_stage == 11:
		SaveManager.data.chosen_buffs.level10 = choice
	elif current_stage == 6:
		SaveManager.data.chosen_buffs.level5 = choice
	
	SaveManager.save()
	BuffManager.apply_stage_buff(current_stage, choice)
	
func _redirect() -> void:
	current_stage = GameState.current_stage
	GameState.game_mode = GameState.GameMode.SINGLEPLAYER
	
	get_tree().change_scene_to_file("res://scenes/piece_selection.tscn")
