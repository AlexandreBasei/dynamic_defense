extends Area2D

class_name Defender

signal hit

@onready var animations = $AnimatedSprite2D

@export var maxHP:int = 10
@export var damages:int = 5
@export var speed:int = 100
@export var atkCooldown:float = .35
@export var walkStop:float = 592.0
@export var cost:int = 10


var currentHP
var isWalking:bool = true
var isAttacking:bool = false
var id:int = 0

var targets:Array[Area2D]

func _ready():
	currentHP = maxHP
	
func _process(delta: float) -> void:
	if position.x < walkStop and !isAttacking:
		move_local_x(speed * delta)
		isWalking = true
	else:
		isWalking = false
		
	if isWalking:
		animations.play("walk")
	elif !isAttacking :
		animations.play("idle")
	if not targets.is_empty():
		_can_attack()

func take_damage(dmg: int) -> void:
	#animations.play("hurt")
	#await animations.animation_finished
	hit.emit()
	currentHP -= dmg
	#print(currentHP)
	
	if currentHP <= 0:
		currentHP = 0
		#print(targets)
		#((Mob)targets).isBlocked = false
		
		queue_free()

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("mobs"):
		targets.append(area)
		#print(targets)
		_can_attack()
		
func _can_attack() -> void :
	for ti in range(targets.size()-1, -1, -1) :
		var target = targets[ti]
		if(target == null or not is_instance_valid(target) or target.currentHP <= 0): 
			targets.erase(target)
		
	if(targets.size() > 0 and not isAttacking):
		animations.play("attack")
		isAttacking = true

func _on_animation_finished() -> void:
	#print("Animation finished")
	for ti in range(targets.size()-1, -1, -1) :
		var target = targets[ti]
		if is_instance_valid(target) and target.is_in_group("mobs"):
			target.take_damage(damages)
			#print("Did damages to someone : ", target, damages)
	animations.play("idle")
	await get_tree().create_timer(atkCooldown).timeout
	isAttacking = false
