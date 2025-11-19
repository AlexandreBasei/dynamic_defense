extends Area2D

signal hit

@onready var animations = $AnimatedSprite2D

@export var maxHP:int = 10
@export var damages:int = 5
@export var speed:int = 100
@export var atkCooldown:int = 3
@export var walkStop:float = 592.0

var currentHP
var isWalking:bool = true
var isAttacking:bool = false
var id:int = 0

func _ready():
	currentHP = maxHP
	
func _process(delta: float) -> void:
	if position.x < walkStop and !isAttacking:
		move_local_x(speed * delta)
		isWalking = true
	else:
		isWalking = false
	
	if !isWalking and !isAttacking:
		animations.play("idle")

func take_damage(dmg: int) -> void:
	hit.emit()
	currentHP -= dmg
	
	if currentHP < 0:
		currentHP = 0
		queue_free()


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("mobs"):
		isAttacking = true
		animations.play("attack")
		take_damage(area.damages)
		await get_tree().create_timer(atkCooldown).timeout
		isAttacking = false
