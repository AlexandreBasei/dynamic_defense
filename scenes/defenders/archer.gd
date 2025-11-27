extends Defender

@onready var arrow_anim = $ArrowAnims
@onready var arrow_spawn = $ArrowSpawnPoint

@export var arrowScene:PackedScene

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("mobs"):
		isAttacking = true
		animations.play("attack")
		# TODO lancer une loop d'attaque tant qu'il y a des ennemis dans la zone de détection (actuellement il n'attaque qu'une fois par ennemi qui entre dans la zone)

func _on_animated_sprite_2d_animation_finished() -> void:
	var last_anim = animations.get_animation()
	
	if (last_anim == "attack"):
		arrow_anim.play("default")
		var arrow = arrowScene.instantiate()
		arrow.global_position = arrow_spawn.global_position
		arrow.connect("hit", Callable(self, "mob_killed"))
		add_sibling(arrow)
		isAttacking = false

#func mob_killed(mob:Node2D) -> void:
	
