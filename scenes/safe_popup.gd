class_name SafePopup
extends Control

signal reward_claimed

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var option_1_btn: Button = $PanelContainer/VBoxContainer/HBoxContainer/Option1Btn
@onready var option_2_btn: Button = $PanelContainer/VBoxContainer/HBoxContainer/Option2Btn
@onready var claim_btn: Button = $PanelContainer/VBoxContainer/ClaimBtn

var current_stage_target: int = 5
var selected_option: int = 0

func setup_safe(stage_num: int) -> void:
	current_stage_target = stage_num
	claim_btn.disabled = true
	
	option_1_btn.pressed.connect(func(): _select_option(1))
	option_2_btn.pressed.connect(func(): _select_option(2))
	claim_btn.pressed.connect(_on_claim_pressed)

	match stage_num:
		5:
			title_label.text = "پاداش گاوصندوق مرحله ۵"
			option_1_btn.text = "افزایش ۵٪ قدرت حمله"
			option_2_btn.text = "کاهش ۱۰٪ روحیه دشمن"
		10:
			title_label.text = "پاداش گاوصندوق مرحله ۱۰ (اهداء زمین)"
			option_1_btn.text = "افزایش ۳۰ واحد جان"
			option_2_btn.text = "کاهش ۱۰٪ روحیه دشمن"
		15:
			title_label.text = "پاداش گاوصندوق مرحله ۱۵ (بک‌گراند ویژه)"
			option_1_btn.text = "افزایش ظرفیت مهره‌ها به ۶"
			option_2_btn.text = "افزایش ۱۵ واحد قدرت حمله ثابت"

func _select_option(option_index: int) -> void:
	selected_option = option_index
	claim_btn.disabled = false
	
	if option_index == 1:
		option_1_btn.modulate = Color.GREEN
		option_2_btn.modulate = Color.WHITE
	else:
		option_1_btn.modulate = Color.WHITE
		option_2_btn.modulate = Color.GREEN

func _on_claim_pressed() -> void:
	if selected_option == 0: return

	match current_stage_target:
		5:
			SaveManager.data.chosen_buffs.level5 = selected_option
		10:
			SaveManager.data.chosen_buffs.level10 = selected_option
		15:
			GameState.stage_15_buff = selected_option

	GameState.recalculate_buffs()
	reward_claimed.emit()
	queue_free()
