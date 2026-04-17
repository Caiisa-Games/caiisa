class_name MovementData
extends Resource

enum MovementType { ORTHOGONAL, DIAGONAL, BOTH }

@export var movement_type: MovementType = MovementType.ORTHOGONAL
@export var move_range: int = 1
@export var can_pass_through_pieces: bool = false
