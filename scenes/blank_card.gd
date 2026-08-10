extends TextureRect

@export var hover_speed : float = 2.0
@export var parallax_factor: float = 8.0 

var time_passed : float = 0.0
var is_hovered : bool = false
var shader_mat : ShaderMaterial
var shader_tween : Tween

func _ready() -> void:
	var shader_file = load("res://shader/card/shader_4.gdshader")
	if shader_file:
		shader_mat = ShaderMaterial.new()
		shader_mat.shader = shader_file
		material = shader_mat

func _process(delta: float) -> void:
	if is_hovered and is_visible_in_tree():
		time_passed += delta * hover_speed
		
		if shader_mat:
			var current_size = size if size != Vector2.ZERO else Vector2(1, 1)
			var local_mouse = (get_local_mouse_position() / current_size) - Vector2(0.5, 0.5)
			
			shader_mat.set_shader_parameter("mouse_pos", local_mouse)
			
			for child in get_children():
				if child is Control or child is Node2D:
					child.position = lerp(child.position, local_mouse * parallax_factor, 0.2)
	else:
		for child in get_children():
			if child is Control or child is Node2D:
				child.position = lerp(child.position, Vector2.ZERO, 0.2)

func start_hover() -> void:
	is_hovered = true
	time_passed = 0.0
	
	if shader_tween and shader_tween.is_valid():
		shader_tween.kill()
		
	if shader_mat:
		var current_size = size if size != Vector2.ZERO else Vector2(1, 1)
		var local_mouse = (get_local_mouse_position() / current_size) - Vector2(0.5, 0.5)
		
		shader_mat.set_shader_parameter("hovering", 0.0)
		shader_mat.set_shader_parameter("mouse_pos", local_mouse)
		
		shader_tween = create_tween()
		shader_tween.tween_property(shader_mat, "shader_parameter/hovering", 1.0, 0.2)
