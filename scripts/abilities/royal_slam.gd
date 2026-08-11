extends AbilityEffect

func execute(caster: Tile, _target_cell: Vector2i, board: BoardManager) -> bool:
	if not caster.occupant.piece_data:
		return false
	var center: Vector2i = caster.grid_position
	var adjacent_cells: Array[Vector2i] = board.get_surrounding_cells(center, 1)

	for cell in adjacent_cells:
		var unit = board.get_tile_at(cell).occupant as Occupant
		if unit.piece_data and unit.player != caster.occupant.player:
			var dmg = int(unit.current_hp * 0.10)
			unit.take_damage(dmg)
			
			var dir: Vector2i = cell - center
			var push_target: Vector2i = cell + dir
			if not board.get_tile_at(push_target):
				continue
			if board.is_cell_empty(push_target):
				board._move_occupant(board.get_tile_at(cell), board.get_tile_at(push_target))
			else:
				var blocking_unit = board.get_tile_at(push_target).occupant as Occupant
				if blocking_unit:
					blocking_unit.take_damage(caster.occupant.piece_data.power)
				unit.take_damage(caster.occupant.piece_data.power)
				
	return true
