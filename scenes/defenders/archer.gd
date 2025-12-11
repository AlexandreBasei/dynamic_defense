extends Defender

@onready var arrow_anim = $ArrowAnims
@onready var arrow_spawn = $ArrowSpawnPoint

@export var arrowScene:PackedScene

var targets_c:int = 0

func _process(delta: float) -> void:
	super._process(delta)
	
	if targets_c > 0 and !isAttacking:
		attack()

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("mobs"):
		targets_c += 1

func _on_animated_sprite_2d_animation_finished() -> void:
	var last_anim = animations.get_animation()
	
	if (last_anim == "attack"):
		arrow_anim.play("default")
		var arrow = arrowScene.instantiate()
		arrow.global_position = arrow_spawn.global_position
		arrow.damages = damages
		get_tree().root.add_child(arrow)
		animations.play("idle")
		await get_tree().create_timer(atkCooldown).timeout
		isAttacking = false

func _on_attack_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("mobs"):
		targets_c -= 1


func attack():
	isAttacking = true
	animations.play("attack")
