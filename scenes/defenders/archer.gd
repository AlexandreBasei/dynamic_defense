extends Defender

@onready var arrow_anim = $ArrowAnims
@onready var arrow_spawn = $ArrowSpawnPoint

@export var arrowScene:PackedScene

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("mobs"):
		isAttacking = true
		animations.play("attack")

func _on_animated_sprite_2d_animation_finished() -> void:
	var last_anim = animations.get_animation()
	
	if (last_anim == "attack"):
		arrow_anim.play("default")
		var arrow = arrowScene.instantiate()
		arrow.position = arrow_spawn.position
		arrow.connect("hit", Callable(self, "mob_killed"))
		add_child(arrow) # TODO MODIFIER POUR ADD SIBLING
		isAttacking = false

#func mob_killed(mob:Node2D) -> void:
	
