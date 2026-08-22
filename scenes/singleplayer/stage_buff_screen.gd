#class_name StageBuffPopup
#extends Control
#
#signal buff_selected
#
#@onready var option1_btn: Button = $Option1Btn
#@onready var option2_btn: Button = $Option2Btn
#
#var current_stage: int = 1
#
#func _ready() -> void:
	#_setup_buttons()
#
#func _setup_buttons() -> void:
	#current_stage = GameState.current_stage
	#if current_stage not in [11,6]:
		#return
	#option1_btn.text = tr("option1_stage_%d" % current_stage)
	#option2_btn.text = tr("option2_stage_%d" % current_stage)
#
#func _on_option1_pressed() -> void:
	#_save_choice(1)
	#buff_selected.emit()
	#_redirect()
#
#func _on_option2_pressed() -> void:
	#_save_choice(2)
	#buff_selected.emit()
	#_redirect()
#
#func _save_choice(choice: int) -> void:
	#current_stage = GameState.current_stage
	#if current_stage == 11:
		#SaveManager.data.chosen_buffs.level10 = choice
	#elif current_stage == 6:
		#SaveManager.data.chosen_buffs.level5 = choice
	#
	#SaveManager.save()
	#BuffManager.apply_stage_buff(current_stage, choice)
	#
#func _redirect() -> void:
	#current_stage = GameState.current_stage
	#GameState.game_mode = GameState.GameMode.SINGLEPLAYER
	#
	#get_tree().change_scene_to_file("res://scenes/piece_selection.tscn")



extends Control

signal buff_selected

@onready var option1_btn: Button = $Option1Btn
@onready var option2_btn: Button = $Option2Btn
@onready var submit_btn: Button = $SubmitBtn # دکمه ثبت اولیه

# سه تا ColorRect برای جایزه
@onready var reward_rects: Array[ColorRect] = [
	$ColorRect1,
	$ColorRect2,
	$ColorRect3
]

var selected_choice: int = 0
var is_reward_phase: bool = false

func _ready() -> void:
	# در ابتدا دکمه ثبت غیرفعال است
	submit_btn.disabled = true
	
	# مخفی کردن ۳ تا ColorRect جایزه در شروع کار
	for rect in reward_rects:
		rect.visible = false

	# اتصال دکمه‌های باف
	option1_btn.pressed.connect(func(): _on_buff_chosen(1))
	option2_btn.pressed.connect(func(): _on_buff_chosen(2))
	
	# اتصال دکمه ثبت
	submit_btn.pressed.connect(_on_submit_pressed)

# وقتی یکی از دو دکمه باف انتخاب می‌شود
func _on_buff_chosen(choice: int) -> void:
	selected_choice = choice
	submit_btn.disabled = false # حالا دکمه ثبت فعال می‌شود
	
	if choice == 1:
		option1_btn.modulate = Color.GREEN
		option2_btn.modulate = Color.WHITE
	else:
		option1_btn.modulate = Color.WHITE
		option2_btn.modulate = Color.GREEN

# وقتی روی دکمه ثبت کلیک می‌شود
func _on_submit_pressed() -> void:
	if not is_reward_phase:
		# مرحله اول: ثبت باف و نمایش جوایز
		if selected_choice == 0:
			return
			
		_save_choice(selected_choice)
		
		# مخفی کردن دکمه‌های باف و آماده کردن دکمه ثبت برای رد کردن جوایز
		option1_btn.visible = false
		option2_btn.visible = false
		
		# نمایش ۳ تا ColorRect به نشانه دریافت جایزه
		for rect in reward_rects:
			rect.visible = true
			
		is_reward_phase = true
		submit_btn.text = "تایید و مرحله بعد" # تغییر متن دکمه برای مرحله بعد
	else:
		# مرحله دوم: کاربر روی همین دکمه می‌زند تا جوایز رد شوند و برود سن بعدی
		finish_and_redirect()

func _save_choice(choice: int) -> void:
	var current_stage = GameState.current_stage
	if current_stage in [5, 10, 15]:
		SaveManager.data.chosen_buffs["level_%d" % current_stage] = choice
	
	SaveManager.save()
	BuffManager.apply_stage_buff(current_stage, choice)

func finish_and_redirect() -> void:
	GameState.game_mode = GameState.GameMode.SINGLEPLAYER
	get_tree().change_scene_to_file("res://scenes/piece_selection.tscn")
