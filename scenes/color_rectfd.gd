extends ColorRect



func _ready() -> void:
	pass

var canmove = true
var t = 1
func popop():
	t = [-1,1].pick_random()
	if t == 1:
		position.x = 1180
	elif t == -1:
		position.x = -50
		
	await get_tree().create_timer(randf_range(0, 5)).timeout
	position.y = randi_range(0, 600)
	$".".color.r = randf_range(0, 1)
	$".".color.g = randf_range(0, 1)
	$".".color.b = randf_range(0, 1)
	canmove = true
func _process(delta: float) -> void:
	if t == 1:
		if $".".position.x < -45:
			canmove = false
			popop()
	elif t == -1:
		if $".".position.x > 1170:
			canmove = false
			popop()
			
	if canmove:
		position.x -= 100 * delta * t
			
