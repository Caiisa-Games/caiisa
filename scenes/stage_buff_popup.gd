class_name StageBuffPopup
extends Control

signal buff_selected

@onready var option1_btn: Button = $Option1Btn
@onready var option2_btn: Button = $Option2Btn

var current_stage: int = 1

func _ready() -> void:
	current_stage = GameState.current_stage
	_setup_buttons()
	
	option1_btn.pressed.connect(_on_option1_pressed)
	option2_btn.pressed.connect(_on_option2_pressed)

func _setup_buttons() -> void:
	if current_stage >= 15:
		option1_btn.text = "افزایش ۶ تایی سقف انتخاب مهره"
		option2_text_or_btn(option2_btn, "افزایش ۱۵ واحدی قدرت حمله تمام مهره‌ها")
	elif current_stage >= 10:
		option1_btn.text = "افزایش ۳۰ واحدی جان (HP) تمام مهره‌ها"
		option2_btn.text = "کاهش ۱۰ درصدی روحیه دشمن"
	elif current_stage >= 5:
		option1_btn.text = "افزایش ۵ درصدی قدرت حمله مهره‌ها"
		option2_btn.text = "کاهش ۱۰ درصدی روحیه دشمن"
	else:
		option1_btn.text = "افزایش ۱۰ واحدی جان (HP) تمام مهره‌ها"
		option2_btn.text = "کاهش ۵ درصدی قدرت حمله دشمن"

func option2_text_or_btn(btn: Button, text_val: String) -> void:
	btn.text = text_val

func _on_option1_pressed() -> void:
	_save_choice(1)
	_mark_popup_shown()
	buff_selected.emit()
	queue_free()

func _on_option2_pressed() -> void:
	_save_choice(2)
	_mark_popup_shown()
	buff_selected.emit()
	queue_free()

func _save_choice(choice: int) -> void:
	if current_stage >= 15:
		GameState.stage_15_buff = choice
	elif current_stage >= 10:
		GameState.stage_10_buff = choice
	elif current_stage >= 5:
		GameState.stage_5_buff = choice
	else:
		GameState.stage_1_buff = choice
		
	GameState.recalculate_buffs()

func _mark_popup_shown() -> void:
	if current_stage >= 15:
		GameState.popup_shown_15 = true
	elif current_stage >= 10:
		GameState.popup_shown_10 = true
	elif current_stage >= 5:
		GameState.popup_shown_5 = true
	else:
		GameState.popup_shown_1 = true
