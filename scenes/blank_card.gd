extends TextureRect

@export var hover_speed : float = 2.0
@export var hover_distance : float = 1.2

var time_passed : float = 0.0
var base_position : Vector2
var is_hovered : bool = false
var shader_mat : ShaderMaterial
var shader_tween : Tween

func _ready() -> void:
	base_position = position
	
	var shader_file = load("res://shader/shader_1.gdshader")
	if shader_file:
		shader_mat = ShaderMaterial.new()
		shader_mat.shader = shader_file
	
	mouse_entered.connect(_on_custom_mouse_entered)
	mouse_exited.connect(_on_custom_mouse_exited)
	gui_input.connect(_on_custom_gui_input)

func _process(delta: float) -> void:
	if is_hovered:
		time_passed += delta * hover_speed
		#var target_y = base_position.y + (sin(time_passed) * hover_distance)
		#position.y = lerp(position.y, target_y, delta * 5.0)

func _on_custom_mouse_entered() -> void:
	is_hovered = true
	time_passed = 0.0
	
	if shader_mat:
		if shader_tween and shader_tween.is_running():
			shader_tween.kill()
			
		var new_mat = shader_mat.duplicate()
		new_mat.set_shader_parameter("progress", 0.0)
		
		shader_tween = create_tween()
		
		shader_tween.tween_interval(0.25)
		
		shader_tween.tween_callback(func():
			if is_hovered:
				material = new_mat
		)
		
		shader_tween.tween_property(new_mat, "shader_parameter/progress", 1.0, 0.5)

func _on_custom_mouse_exited() -> void:
	is_hovered = false
	material = null
	
	if shader_tween and shader_tween.is_running():
		shader_tween.kill()
		
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", base_position.y, 0.15)

func _on_custom_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_play_click_animation()

func _play_click_animation() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_interval(0.05)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05)
