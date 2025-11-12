extends Area2D

signal hit

@export var maxHP = 10
var currentHP

@export var damages = 5
@export var speed = 200
@export var isFlying = false
@export var isBlocked = false

func _ready():
	currentHP = maxHP
	
func _process(delta: float) -> void:
	if isBlocked == false :
		move_local_x(-(speed * delta))
	else :
		pass

func take_damage(dmg: int) -> void:
	hit.emit()
	currentHP -= dmg
	
	if currentHP < 0:
		currentHP = 0


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Unit"):
		isBlocked = true;
	
