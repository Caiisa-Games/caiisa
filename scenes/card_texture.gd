extends TextureRect

@export var move_speed : float = 2.0        
@export var max_rotation_deg : float = 2.5 

var time_passed : float = 0.0
var random_offset : float = 0.0

var shader_1_mat : ShaderMaterial
var shader_tween : Tween

func _ready() -> void:
	pivot_offset = size / 2.0
	
	random_offset = randf_range(0.0, 1000.0)
	time_passed = random_offset
	
	resized.connect(func(): pivot_offset = size / 2.0)
	
	var file_1 = load("res://shader/shader_1.gdshader")
	if file_1:
		shader_1_mat = ShaderMaterial.new()
		shader_1_mat.shader = file_1

func _process(delta: float) -> void:
	if is_visible_in_tree():
		time_passed += delta * move_speed
		
		var rot_angle = sin(time_passed) * max_rotation_deg + cos(time_passed * 0.7) * (max_rotation_deg * 0.4)
		
		rotation = deg_to_rad(rot_angle)

func play_exit_shader() -> void:
	show()
	
	if shader_tween and shader_tween.is_valid():
		shader_tween.kill()
		
	if shader_1_mat:
		var new_mat = shader_1_mat.duplicate() as ShaderMaterial
		material = new_mat
		
		shader_tween = create_tween()
		shader_tween.tween_property(new_mat, "shader_parameter/progress", 1.0, 0.4).from(0.0)
		shader_tween.tween_callback(func():
			material = null
		)
