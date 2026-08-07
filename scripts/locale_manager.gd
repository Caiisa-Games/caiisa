extends Node

const SUPPORTED_LOCALES: Array[Dictionary] = [
	{ "code": "en", "label": "English"  },
	{ "code": "fa", "label": "Persian" },
]

func get_locale_label(code: String) -> String:
	for entry in SUPPORTED_LOCALES:
		if entry["code"] == code:
			return entry["label"]
	return code

func get_all_labels() -> Array[String]:
	var labels: Array[String] = []
	for entry in SUPPORTED_LOCALES:
		labels.append(entry["label"])
	return labels

func get_code_by_index(index: int) -> String:
	if index < 0 or index >= SUPPORTED_LOCALES.size():
		return "en"
	return SUPPORTED_LOCALES[index]["code"]

func get_index_by_code(code: String) -> int:
	for i in range(SUPPORTED_LOCALES.size()):
		if SUPPORTED_LOCALES[i]["code"] == code:
			return i
	return 0
