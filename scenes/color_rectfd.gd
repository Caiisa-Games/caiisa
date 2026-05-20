extends Sprite2D

@export var images : Array[Texture]

func _ready() -> void:
	pass

var canmove = true
var t = 1
func popop():
	t = [-1,1].pick_random()
	if t == 1:
		position.x = 1400
	elif t == -1:
		position.x = -300
		
	await get_tree().create_timer(randf_range(0, 5)).timeout
	$".".position.y = randi_range(180, 635)
	$".".texture = images.pick_random()
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
			
