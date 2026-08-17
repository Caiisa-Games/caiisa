extends AbilityEffect

func execute(caster: Tile, target_cell: Vector2i, board: BoardManager) -> bool:
	if not caster or not caster.occupant or not caster.occupant.piece_data:
		return false

	var target_tile = board.get_tile_at(target_cell)
	if not target_tile or not target_tile.occupant or not target_tile.occupant.piece_data:
		return false

	var target_unit = target_tile.occupant as Occupant

	if target_unit.player == caster.occupant.player:
		return false

	var base_power: int = caster.occupant.piece_data.power

	var missing_hp: int = max(0, target_unit.max_hp - target_unit.current_hp)
	var execute_bonus: int = int(missing_hp * 0.20)

	var height_diff: int = caster.height_level - target_tile.height_level

	var total_damage: int = CombatRules.calculate_damage(base_power, height_diff) + execute_bonus

	target_unit.take_damage(total_damage)

	return true
