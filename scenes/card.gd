extends Control

@onready var pro: ProgressBar = $ProgressBar
@onready var pro_2: ProgressBar = $ProgressBar2
@onready var pro_3: ProgressBar = $ProgressBar3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	pro.value = randi_range(0, pro.max_value)
	pro_2.value = randi_range(0, pro_2.max_value)
	pro_3.value = randi_range(0, pro_3.max_value)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
