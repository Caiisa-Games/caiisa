class_name KnightPassive
extends PassiveEffect

static func allows_jump_over(piece_data: PieceData) -> bool:
	return piece_data and piece_data.name == "knight"
