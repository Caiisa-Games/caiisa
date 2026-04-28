class_name CombatRules

static func calculate_damage(
	attacker_power: int, 
	height_delta: int, 
	is_critical: bool = false
) -> int:
	
	var raw_damage = attacker_power
	
	var height_bonus = clamp(height_delta, -3, 3)
	raw_damage += height_bonus
	
	if is_critical:
		raw_damage = int(raw_damage * 1.5)
	
	return max(1, raw_damage)

static func is_within_range(attacker_pos: Vector2i, target_pos: Vector2i, attack_range: int) -> bool:
	var dx = abs(attacker_pos.x - target_pos.x)
	var dy = abs(attacker_pos.y - target_pos.y)
	var distance = max(dx, dy)
	return distance <= attack_range
