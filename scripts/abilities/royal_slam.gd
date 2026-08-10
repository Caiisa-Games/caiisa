extends AbilityEffect

func execute(caster: Node2D, target_cell: Vector2i, grid_manager: Node) -> bool:
	var center: Vector2i = caster.grid_position
	var adjacent_cells: Array[Vector2i] = grid_manager.get_surrounding_cells(center, 1)
	
	for cell in adjacent_cells:
		var unit = grid_manager.get_unit_at(cell)
		if unit and unit.team != caster.team:
			var dmg = int(unit.max_health * 0.10)
			unit.take_damage(dmg, caster)
			
			var dir: Vector2i = cell - center
			var push_target: Vector2i = cell + dir
			
			if grid_manager.is_cell_empty(push_target):
				grid_manager.move_unit_silent(unit, push_target)
			else:
				var blocking_unit = grid_manager.get_unit_at(push_target)
				if blocking_unit:
					blocking_unit.take_damage(caster.base_damage, caster)
				unit.take_damage(caster.base_damage, caster)
				
	return true
