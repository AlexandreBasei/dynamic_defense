extends Mob

func attack() -> void:
	$AnimatedSprite2D.play("attack")
	if target == null or not is_instance_valid(target):
		isBlocked = false
		return
	
	isAttacking = true


func _on_animated_sprite_2d_animation_finished() -> void:
	var last_anim = $AnimatedSprite2D.get_animation()
	
	if (last_anim == "attack"):
		if is_instance_valid(target):
			if global_position.distance_to(target.global_position) < 32.0:
				if target.has_method("take_damage"):
					target.take_damage(damages)
		isAttacking = false
		
