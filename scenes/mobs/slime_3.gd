extends Mob

var aoe_targets:Array[Area2D]

func attack() -> void:
	if is_instance_valid(target):
		$AnimatedSprite2D.play("attack")
		$AttackParticles.emitting = true
	else:
		isBlocked = false
		return
	
	isAttacking = true

func _on_attack_area_area_entered(area: Area2D) -> void:
	if (area.is_in_group("Unit")):
		aoe_targets.append(area)

func _on_attack_area_area_exited(area: Area2D) -> void:
	if is_instance_valid(area) and area.is_in_group("Unit"):
		aoe_targets.erase(area)


func _on_animated_sprite_2d_animation_looped() -> void:
	var last_anim = $AnimatedSprite2D.get_animation()
	
	if (last_anim == "attack"):
		$AttackParticles.restart()
		if is_instance_valid(target):
			for defender in aoe_targets:
				if is_instance_valid(defender):
					defender.take_damage(damages)
		else:
			isAttacking = false
			$AnimatedSprite2D.play("moving")
		
