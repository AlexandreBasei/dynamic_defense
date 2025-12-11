extends Area2D

class_name Mob

signal dead
signal destroyed

@export var maxHP = 10
var currentHP : int

@export var damages = 5
@export var speed = 200
@export var isFlying = false
@export var isBlocked = false
@export var goldDropped:int
@export var AttackCooldown:float = .35

@export var jumpTime  = 0.35
const jumpHeight = 100.0

var jumpStartPos : Vector2
var jumpEndPos   : Vector2
var originalPos  : Vector2       

var target : Node2D = null
var isAttacking : bool = false
var isReturning : bool = false    
var attackTurn:bool = false
var isDead:bool = false

func _ready() -> void:
	currentHP = maxHP
	
func play_anim(anim):
	if(not isDead):
		$AnimatedSprite2D.play(anim)

func _process(delta: float) -> void:
	if not isBlocked and not isAttacking and not isDead:
		move_local_x(-(speed * delta))
	if target == null or not is_instance_valid(target):
		isBlocked = false


func take_damage(dmg: int) -> void:
	currentHP -= dmg
	
	if currentHP <= 0:
		currentHP = 0
		die()

func die() ->void :
	if(not isDead):
		isDead = true
		if($AnimatedSprite2D.sprite_frames.has_animation("death")):
			$AnimatedSprite2D.play("death")
			await $AnimatedSprite2D.animation_finished
		dead.emit()
		queue_free()

func destroy() -> void:
	destroyed.emit()
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Unit") and not isAttacking:
		isBlocked = true
		attackTurn = true
		target = area
		#print(target)
		attack()

func _my_turn() ->void :
	attackTurn = true
	attack()


# SAUT AVANT

func attack() -> void:
	if not is_instance_valid(target):
		isAttacking = false
		return
		
	if(attackTurn): 
		attackTurn = false
		play_anim("attack")

		isAttacking = true
		isReturning = false

		originalPos = global_position       

		jumpStartPos = originalPos
		if is_instance_valid(target) and target.is_in_group("Unit"):
			jumpEndPos   = target.global_position
		jumpEndPos.y = originalPos.y - 30  

		var tween = create_tween()
		tween.tween_method(
			Callable(self, "_update_jump_attack"),
			0.0, 1.0, jumpTime
		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(_on_jump_attack_finished)


func _update_jump_attack(t: float) -> void:
	var base_pos: Vector2 = jumpStartPos.lerp(jumpEndPos, t)

	var h = jumpHeight
	var vertical_offset = -4.0 * h * (t - 0.5) * (t - 0.5) + h
	global_position = base_pos + Vector2(0, -vertical_offset)


func _on_jump_attack_finished() -> void:
	if not isReturning:
		if is_instance_valid(target) and target.is_in_group("Unit"):
			if global_position.distance_to(target.global_position) < 32.0:
				if target.has_method("take_damage"):
					await $AnimatedSprite2D.animation_finished
					target.take_damage(damages)
					#print("damage slime")

		_start_return_jump()
	elif(not isDead):
		play_anim("moving")
		isAttacking = false
		await get_tree().create_timer(AttackCooldown).timeout
		_my_turn()


# SAUT DE RETOUR

func _start_return_jump() -> void:
	isReturning = true

	jumpStartPos = global_position      
	jumpEndPos   = originalPos          
	
	jumpEndPos.y = originalPos.y

	var tween = create_tween()
	tween.tween_method(
		Callable(self, "_update_jump_attack"),
		0.0, 1.0, jumpTime
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(_on_jump_attack_finished)
	
