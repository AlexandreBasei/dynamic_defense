extends Area2D

class_name Mob
signal hit

@export var maxHP = 10
var currentHP : int

@export var damages = 5
@export var speed = 200
@export var isFlying = false
@export var isBlocked = false

const jumpTime  = 0.35
const jumpHeight = 100.0

var jumpStartPos : Vector2
var jumpEndPos   : Vector2
var originalPos  : Vector2       

var target : Node2D = null
var isAttacking : bool = false
var isReturning : bool = false    


func _ready() -> void:
	currentHP = maxHP


func _process(delta: float) -> void:
	if not isBlocked and not isAttacking:
		move_local_x(-(speed * delta))


func take_damage(dmg: int) -> void:
	hit.emit()
	currentHP -= dmg
	
	if currentHP < 0:
		currentHP = 0


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Unit") and not isAttacking:
		isBlocked = true
		target = area
		attack()


# SAUT AVANT

func attack() -> void:
	if target == null or not is_instance_valid(target):
		isBlocked = false
		return

	isAttacking = true
	isReturning = false

	originalPos = global_position       

	jumpStartPos = originalPos
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

		if is_instance_valid(target):
			if global_position.distance_to(target.global_position) < 32.0:
				if target.has_method("take_damage"):
					target.take_damage(damages)

		_start_return_jump()
	else:
		isAttacking = false

		target = null


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
