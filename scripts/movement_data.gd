class_name MovementData
extends Resource

enum MovementType { ORTHOGONAL, DIAGONAL, BOTH }

@export var movement_type: MovementType = MovementType.ORTHOGONAL
@export var move_range: int = 1
