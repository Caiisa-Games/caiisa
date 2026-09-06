class_name EnemyAI
extends Node

func take_turn(board: BoardManager) -> void:
	print("--- Enemy Turn Started ---")

	var battle_manager: BattleManager = board.battle_manager
	if not battle_manager:
		print("--- Enemy Turn Finished (No BattleManager) ---")
		return

	var enemies: Array[Tile] = []

	for tile in board.tiles.values():
		if tile.occupant and tile.occupant.piece_data and tile.occupant.player == 2 and not tile.occupant.has_status("stunned"):
			enemies.append(tile)

	if enemies.is_empty():
		print("--- Enemy Turn Finished (No Enemies) ---")
		return

	var best_enemy: Tile = null
	var best_move_tile: Tile = null
	var min_distance := 999999
	var attack_found := false
	var best_attack_score := -999999

	for enemy in enemies:
		var moves = battle_manager.get_valid_moves_for_tile(enemy)

		for move_tile in moves:
			var is_attack = (move_tile.occupant.piece_data != null and move_tile.occupant.player == 1)

			if is_attack:
				var predicted := CombatRules.calculate_damage(
					CombatRules.get_attack_power(enemy.occupant),
					enemy.height_level - move_tile.height_level,
					false
				)
				var score := predicted
				if predicted >= move_tile.occupant.current_hp:
					score += 1000
				if not attack_found or score > best_attack_score:
					attack_found = true
					best_attack_score = score
					best_enemy = enemy
					best_move_tile = move_tile
			elif not attack_found:
				var nearest_player = _find_nearest_player(board, move_tile)
				if not nearest_player:
					continue
				var dist := _grid_distance(move_tile.grid_position, nearest_player.grid_position)
				if dist < min_distance:
					min_distance = dist
					best_enemy = enemy
					best_move_tile = move_tile

	if best_enemy == null or best_move_tile == null:
		for enemy in enemies:
			var moves = battle_manager.get_valid_moves_for_tile(enemy)
			if not moves.is_empty():
				best_enemy = enemy
				best_move_tile = moves[0]
				break

	if best_enemy == null or best_move_tile == null:
		print("--- Enemy Turn Finished (No Valid Move) ---")
		await get_tree().create_timer(0.3).timeout
		return

	var target_occupant = best_move_tile.occupant
	
	if target_occupant.piece_data and target_occupant.player == 1:
		battle_manager.show_enemy_intent(best_enemy, best_move_tile, true)
		await get_tree().create_timer(0.55).timeout
		var damage = CombatRules.calculate_damage(
			CombatRules.get_attack_power(best_enemy.occupant),
			best_enemy.height_level - best_move_tile.height_level,
			false
		)
		
		AudioManager.play_sfx(preload("res://assets/sound/دمیج دادن به مهره ی مقابل.mp3"))
		var attacked_tile = best_move_tile
		
		var died = await CombatRules.apply_combat_damage(
			best_enemy.occupant, 
			target_occupant, 
			damage, 
			board, 
			board.battle_manager
		)
		if died:
			battle_manager._handle_died(attacked_tile)
			if battle_manager.winner == 0:
				battle_manager._execute_dictionary_move(best_enemy, attacked_tile)
				board._move_occupant(best_enemy, attacked_tile)
				await battle_manager._check_promotion(attacked_tile)
		else:
			await battle_manager._apply_knockback(best_enemy, attacked_tile)

	else:
		battle_manager.show_enemy_intent(best_enemy, best_move_tile, false)
		await get_tree().create_timer(0.45).timeout
		AudioManager.play_sfx(preload("res://assets/sound/فرود اومدن مهره بعد از حرکت.mp3"))
		battle_manager._execute_dictionary_move(best_enemy, best_move_tile)
		board._move_occupant(best_enemy, best_move_tile)
		await battle_manager._check_promotion(best_move_tile)

	await get_tree().create_timer(0.3).timeout
	print("--- Enemy Turn Finished ---")


func _find_nearest_player(board: BoardManager, reference_tile: Tile) -> Tile:
	var nearest: Tile = null
	var best := 999999

	for tile in board.tiles.values():
		if tile.occupant and tile.occupant.piece_data and tile.occupant.player == 1:
			var d := _grid_distance(reference_tile.grid_position, tile.grid_position)
			if d < best:
				best = d
				nearest = tile

	return nearest


func _grid_distance(a: Vector2i, b: Vector2i) -> int:
	# Chebyshev
	return max(abs(a.x - b.x), abs(a.y - b.y))
