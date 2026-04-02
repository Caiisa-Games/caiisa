class_name PieceData
extends Resource

@export_group("Info")
@export var name: String
@export var description: String

@export_group("Visuals")
@export var texture: Texture2D
@export var collision_shape: Shape2D

@export_group("Stats")
@export var knockback: float = 1.0
@export var power: float = 1.0
@export var defense: float = 1.0
