extends Area2D

signal hit

@export var maxHP = 10
var currentHP

@export var damages = 5

func _ready():
	currentHP = maxHP
	
func _process(delta: float) -> void:
	pass

func take_damage(dmg: int) -> void:
	hit.emit()
	currentHP -= dmg
	
	if currentHP < 0:
		currentHP = 0


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("mobs"):
		$AnimatedSprite2D.play("attack")
		take_damage(area.damages)
