extends Control
class_name LoadingScreen

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var loading_bar: ProgressBar = $LoadingBar
@onready var tip_label: Label = $TipLabel

@export var target_scene: String

const FADE_IN_DURATION := 3.0
const LOADING_DURATION := 5.0
const FADE_OUT_DURATION := 1.0


func _ready() -> void:
	assert(target_scene != "", "ERROR: Target scene is null!");
	ResourceLoader.load_threaded_request(target_scene)
	fade_overlay.show()
	fade_overlay.modulate = Color.BLACK
	loading_bar.value = 0
	loading_bar.show()
	var tip_number = randi() % 6 + 1
	tip_label.text = tr("tip" + str(tip_number))
	tip_label.show()
	
	_start_intro_sequence()

func _start_intro_sequence() -> void:
	var intro = create_tween()
	intro.tween_interval(0.5)
	intro.tween_property(fade_overlay, "modulate:a", 0.0, FADE_IN_DURATION)
	intro.parallel().tween_property(loading_bar, "value", 100.0, LOADING_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	intro.tween_property(fade_overlay, "modulate:a", 1.0, FADE_OUT_DURATION)
	intro.tween_callback(change_scene)
	intro.tween_interval(0.5)
	intro.tween_property(fade_overlay, "modulate:a", 0.0, 0.5)
	intro.finished.connect(func(): fade_overlay.hide())
	
func change_scene():
	if ResourceLoader.load_threaded_get_status(target_scene) == ResourceLoader.THREAD_LOAD_LOADED:
		var packed = ResourceLoader.load_threaded_get(target_scene)
		get_tree().change_scene_to_packed(packed)
		queue_free()
