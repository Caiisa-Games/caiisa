extends AudioStreamPlayer2D

@onready var sgt: AudioStreamPlayer2D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sgt.stop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
