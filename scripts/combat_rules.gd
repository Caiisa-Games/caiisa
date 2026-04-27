class_name CombatRules

# Damage = (AttackerPower - heightdelta) * RangeModifier
# TODO: Account for height
static func calculate_damage(attacker_power: int, is_critical: bool = false) -> int:
	var raw_damage = attacker_power
	
	if is_critical:
		raw_damage = int(raw_damage * 1.5)
	
	return max(1, raw_damage)

static func is_within_range(attacker_pos: Vector2i, target_pos: Vector2i, attack_range: int) -> bool:
	var dx = abs(attacker_pos.x - target_pos.x)
	var dy = abs(attacker_pos.y - target_pos.y)
	var distance = max(dx, dy)
	return distance <= attack_range
