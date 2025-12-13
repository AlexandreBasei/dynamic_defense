extends Mob

var aoe_targets:Array[Area2D]

func attack() -> void:
	# Déclenche une aoe lorsque des unités sont dans la zone
	if isAttacking:
		return
	
	if aoe_targets.is_empty():
		isBlocked = false
		isAttacking = false
		return

	attackTurn = false
	isAttacking = true
	play_anim("attack")
	$AttackParticles.emitting = true

	await $AnimatedSprite2D.animation_finished

	for defender in aoe_targets:
		if is_instance_valid(defender) and defender.is_in_group("Unit"):
			if defender.has_method("take_damage"):
				defender.take_damage(damages)

	$AttackParticles.emitting = false
	isAttacking = false

	await get_tree().create_timer(AttackCooldown).timeout

	if not aoe_targets.is_empty() and not isDead:
		_my_turn()
	else:
		play_anim("moving")
		isBlocked = false

func _on_attack_area_area_entered(area: Area2D) -> void:
	if (area.is_in_group("Unit")):
		aoe_targets.append(area)

func _on_attack_area_area_exited(area: Area2D) -> void:
	if is_instance_valid(area) and area.is_in_group("Unit"):
		aoe_targets.erase(area)
		
