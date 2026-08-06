extends Control

@onready var buttons = {
	1: $GridContainer/Button1,
	2: $GridContainer/Button2,
	3: $GridContainer/Button3,
	4: $GridContainer/Button4,
	5: $GridContainer/Button5,
	6: $GridContainer/Button6,
	7: $GridContainer/Button7,
	8: $GridContainer/Button8,
	9: $GridContainer/Button9,
	10: $GridContainer/Button10,
	11: $GridContainer/Button11,
	12: $GridContainer/Button12,
	13: $GridContainer/Button13,
	14: $GridContainer/Button14,
	15: $GridContainer/Button15
}

func _ready() -> void:
	SaveManager.load_save()
	var unlocked_stage = SaveManager.data.highest_unlocked_level
	
	for stage_num in buttons:
		var btn: Button = buttons[stage_num]
		if btn:
			if stage_num <= unlocked_stage:
				btn.disabled = false
				btn.pressed.connect(_on_stage_pressed.bind(stage_num))
			else:
				btn.disabled = true

func _on_stage_pressed(stage_num: int) -> void:
	GameState.current_stage = stage_num
	GameState.game_mode = GameState.GameMode.SINGLEPLAYER
	get_tree().change_scene_to_file("res://scenes/piece_selection.tscn")
