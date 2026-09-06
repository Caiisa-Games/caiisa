class_name StageBuffPopup
extends Control

signal buff_selected

const POWER_BUFF_ICON := preload("res://assets/sprites/buffs/Powerbuff.png")
const HP_BUFF_ICON := preload("res://assets/sprites/buffs/HpBuff.png")
const DECAY_BUFF_ICON := preload("res://assets/sprites/buffs/Decay.png")
const STALKERS_MARK_ICON := preload("res://assets/sprites/buffs/STALKER'S-MARK.png")

const STAGE_IMAGES := {
	5: preload("res://assets/Misc/Background/lvlbackground.png"),
	10: preload("res://assets/Misc/Background/Greek Architecture.png"),
	15: preload("res://assets/Misc/Background/Renaissance.png"),
}

const REWARDS := {
	5: [
		{"key": "buff_stage5_option1", "icon": DECAY_BUFF_ICON},
		{"key": "buff_stage5_option2", "icon": HP_BUFF_ICON},
	],
	10: [
		{"key": "buff_stage10_option1", "icon": POWER_BUFF_ICON},
		{"key": "buff_stage10_option2", "icon": DECAY_BUFF_ICON},
	],
	15: [
		{"key": "buff_stage15_option1", "icon": STALKERS_MARK_ICON},
		{"key": "buff_stage15_option2", "icon": HP_BUFF_ICON},
	],
}

@onready var stage_label: Label = $RewardPanel/StageLabel
@onready var title_label: Label = $RewardPanel/TitleLabel
@onready var options_row: HBoxContainer = $RewardPanel/OptionsRow
@onready var option1_btn: Button = $RewardPanel/OptionsRow/Option1Btn
@onready var option2_btn: Button = $RewardPanel/OptionsRow/Option2Btn
@onready var option1_label: Label = $RewardPanel/OptionsRow/Option1Btn/BenefitLabel
@onready var option2_label: Label = $RewardPanel/OptionsRow/Option2Btn/BenefitLabel
@onready var option1_icon: TextureRect = $RewardPanel/OptionsRow/Option1Btn/Icon
@onready var option2_icon: TextureRect = $RewardPanel/OptionsRow/Option2Btn/Icon
@onready var option1_selected: Label = $RewardPanel/OptionsRow/Option1Btn/SelectedLabel
@onready var option2_selected: Label = $RewardPanel/OptionsRow/Option2Btn/SelectedLabel
@onready var action_button: Button = $RewardPanel/ActionButton
@onready var reveal: Control = $RewardPanel/RewardReveal
@onready var reveal_image: TextureRect = $RewardPanel/RewardReveal/RevealImage
@onready var reveal_title: Label = $RewardPanel/RewardReveal/RevealTitle
@onready var reveal_body: Label = $RewardPanel/RewardReveal/RevealBody

var current_stage := 1
var selected_choice := 0
var reward_confirmed := false

func _ready() -> void:
	current_stage = GameState.current_stage
	_setup_localized_content()
	reveal.hide()
	action_button.disabled = true
	action_button.text = tr("stage_reward_confirm")
	option1_selected.hide()
	option2_selected.hide()
	options_row.modulate.a = 0.0
	var entrance := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	entrance.tween_property(options_row, "modulate:a", 1.0, 0.25)

func _setup_localized_content() -> void:
	stage_label.text = tr("stage_reward_for") % current_stage
	title_label.text = tr("stage_reward_title")
	var rewards: Array = REWARDS.get(current_stage, [])
	if rewards.size() != 2:
		push_error("Missing reward data for stage %d" % current_stage)
		return
	option1_label.text = tr(rewards[0].key)
	option2_label.text = tr(rewards[1].key)
	option1_icon.texture = rewards[0].icon
	option2_icon.texture = rewards[1].icon
	option1_selected.text = tr("stage_reward_selected")
	option2_selected.text = tr("stage_reward_selected")
	reveal_title.text = tr("stage_reward_unlocked")
	reveal_body.text = tr("stage_reward_unlocked_stage") % (current_stage + 1)
	if STAGE_IMAGES.has(current_stage):
		reveal_image.texture = STAGE_IMAGES[current_stage]

func _on_option1_pressed() -> void:
	_select_choice(1)

func _on_option2_pressed() -> void:
	_select_choice(2)

func _select_choice(choice: int) -> void:
	if reward_confirmed:
		return
	selected_choice = 0 if selected_choice == choice else choice
	option1_selected.visible = selected_choice == 1
	option2_selected.visible = selected_choice == 2
	action_button.disabled = selected_choice == 0

func _on_action_button_pressed() -> void:
	if not reward_confirmed:
		if selected_choice == 0:
			return
		_save_choice(selected_choice)
		reward_confirmed = true
		_show_reward_reveal()
		return
	_redirect()

func _show_reward_reveal() -> void:
	options_row.hide()
	reveal.show()
	reveal.modulate.a = 0.0
	action_button.text = tr("stage_reward_continue")
	action_button.disabled = false
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(reveal, "modulate:a", 1.0, 0.3)

func _save_choice(choice: int) -> void:
	match current_stage:
		5:
			SaveManager.data.chosen_buffs.level5 = choice
		10:
			SaveManager.data.chosen_buffs.level10 = choice
		15:
			SaveManager.data.chosen_buffs.level15 = choice
	SaveManager.save()
	GameState.refresh_background_unlocks(SaveManager.data)
	BuffManager.apply_stage_buff(current_stage, choice)
	buff_selected.emit()

func _redirect() -> void:
	if GameState.post_buff_destination == "next_stage":
		var next_stage := current_stage + 1
		if GameState.is_stage_unlocked(next_stage):
			GameState.set_current_stage(next_stage)
			get_tree().change_scene_to_file("res://scenes/piece_selection.tscn")
			return
	get_tree().change_scene_to_file("res://scenes/singleplayer/stage_selection.tscn")
