class_name LanguagePicker
extends HBoxContainer

@onready var option_button: OptionButton = $OptionButton

func _ready() -> void:
	option_button.clear()
	for label in LocaleManager.get_all_labels():
		option_button.add_item(label)

	option_button.selected = LocaleManager.get_index_by_code(SettingsManager.data.locale)

	option_button.item_selected.connect(_on_item_selected)

func _on_item_selected(index: int) -> void:
	var code := LocaleManager.get_code_by_index(index)
	SettingsManager.set_locale(code)
	
	SettingsManager.save_settings()
