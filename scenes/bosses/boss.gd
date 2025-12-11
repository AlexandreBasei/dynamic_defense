extends Mob

@export var projectile : PackedScene
@export var projectileBaseCooldown = 5.0
@export var projectileLaunchInterval = 0.5
@export var projectileLaunchCount = 1
var currentProjectileCooldown : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentProjectileCooldown = projectileBaseCooldown
	super._ready()
	
func play_anim(anim):
	if(not isDead):
		$BossAnims.play(anim)

func die():
	if(not isDead):
		play_anim("death")
		isDead = true
		await $BossAnims.animation_finished
		dead.emit()
		queue_free()
	
func attack() :
	if not is_instance_valid(target):
		isAttacking = false
		return
		
	play_anim("attack")
	isAttacking = true
	await $BossAnims.animation_finished
	if is_instance_valid(target) && target.has_method("take_damage"):
		target.take_damage(damages)
	
func projectile_launch_sequence():
	for i in projectileLaunchCount:
		var proj = projectile.instantiate()
		proj.position = position
		proj.position.x -= 20
		proj.position.y -= 250
		add_sibling(proj)
		await get_tree().create_timer(projectileLaunchInterval).timeout
	isAttacking = false
	currentProjectileCooldown = projectileBaseCooldown
	
func _process(delta: float) -> void:
	super._process(delta)
	if(!isAttacking):
		play_anim("idle" if isBlocked else "walk")
	currentProjectileCooldown -= delta
	if(currentProjectileCooldown < 0 && !isAttacking):
		isAttacking = true
		await projectile_launch_sequence()

func _on_boss_anims_animation_finished() -> void:
	play_anim("idle")
	isAttacking = false

func _on_block_area_area_entered(area: Area2D) -> void:
	super._on_area_2d_area_entered(area)
