extends Area2D

signal hit

@export var maxHP = 10
var currentHP

@export var damages = 5
@export var speed = 200

func _ready():
	currentHP = maxHP
	
func _process(delta: float) -> void:
	move_local_x(-(speed * delta))

func take_damage(dmg: int) -> void:
	hit.emit()
	currentHP -= dmg
	
	if currentHP < 0:
		currentHP = 0
