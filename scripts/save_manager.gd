extends Node

const SAVE_PATH := "user://save.json"

var data := {
	"last_completed_level": 0,
	"highest_unlocked_level": 1,
}

func load_save():
	if not FileAccess.file_exists(SAVE_PATH):
		save()
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text = file.get_as_text()
	var result = JSON.parse_string(text)
	if result is Dictionary:
		data = result

func save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
