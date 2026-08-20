extends AbilityEffect

func execute(caster: Tile, target_cell: Vector2i, board: BoardManager) -> bool:
	if not caster or not caster.occupant or not caster.occupant.piece_data:
		return false

	var target_tile = board.get_tile_at(target_cell)
	if not target_tile or not target_tile.occupant:
		return false

	var direction: Vector2i = target_cell - caster.grid_position
	var perp := Vector2i(-direction.y, direction.x)

	var cells_to_hit: Array[Vector2i] = [
		target_cell,
		target_cell + perp,
		target_cell - perp
	]

	var base_power: int = caster.occupant.piece_data.power
	var hit_any := false

	for cell in cells_to_hit:
		var tile = board.get_tile_at(cell)
		if tile == null or tile.occupant == null or tile.occupant.piece_data == null:
			continue
		var unit = tile.occupant as Occupant
		if unit.player == caster.occupant.player:
			continue

		hit_any = true
		var died = await CombatRules.apply_combat_damage(caster.occupant, unit, base_power, board, board.battle_manager)
		if died:
			board.battle_manager.handle_ability_kill(tile)

	return hit_any
