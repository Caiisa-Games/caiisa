extends TextureRect

@export var move_speed : float = 2.0    
@export var move_distance : float = 5.0 
@export var max_rotation : float = 1.5 

var time_passed : float = 0.0
var base_position : Vector2

func _ready() -> void:
	base_position = position
	time_passed = randf_range(0.0, 100.0)

func _process(delta: float) -> void:
	time_passed += delta * move_speed
	
	var x_offset = sin(time_passed) * move_distance
	var rot_offset = sin(time_passed) * deg_to_rad(max_rotation)
	
	position = Vector2(base_position.x + x_offset, base_position.y)
	rotation = rot_offset
