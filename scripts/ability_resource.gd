class_name AbilityResource
extends Resource

enum TargetType { SELF, SINGLE_ENEMY, SINGLE_ALLY, AOE_CROSS, AOE_RADIUS }

@export var id: String
@export var name: String
@export var energy_cost: int
@export var target_type: TargetType
@export var range: int = 1
@export var script_effect: Script # Custom script
