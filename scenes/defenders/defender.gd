extends Area2D

class_name Defender

signal hit

@onready var animations = $AnimatedSprite2D

@export var maxHP:int = 10
@export var damages:int = 5
@export var speed:int = 100
@export var atkCooldown:int = 3
@export var walkStop:float = 592.0
@export var cost:int = 10

var currentHP
var isWalking:bool = true
var isAttacking:bool = false
var attackTurn_d:bool = false
var id:int = 0

var target:Area2D

func _ready():
	currentHP = maxHP
	
func _process(delta: float) -> void:
	if position.x < walkStop and !isAttacking:
		move_local_x(speed * delta)
		isWalking = true
		
		
	else:
		isWalking = false
		
	
	if !isWalking and !isAttacking :
		animations.play("idle")
	if attackTurn_d :
		_can_attack(target)

func take_damage(dmg: int) -> void:
	#animations.play("hurt")
	#await animations.animation_finished
	hit.emit()
	currentHP -= dmg
	print(currentHP)
	
	if currentHP <= 0:
		currentHP = 0
		print(target)
		#((Mob)target).isBlocked = false
		
		queue_free()


func _on_attack_area_area_entered(area: Area2D) -> void:
	
	isAttacking = true
	target = area
	print(target)
	_can_attack(target)
		
func _can_attack(target : Area2D) -> void :
	if target.is_in_group("mobs"):
		if (attackTurn_d):
			attackTurn_d = false
			animations.play("attack")
			
			await animations.animation_finished
			target.take_damage(damages)
			#await get_tree().create_timer(atkCooldown).timeout
			#isAttacking = false
		
		
