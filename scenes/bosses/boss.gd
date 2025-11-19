extends Mob

@export var projectile : PackedScene
var projectileBaseCooldown = 5.0
var currentProjectileCooldown : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func attack() :
	$BossAnims.play("attack")
	isAttacking = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if(!isAttacking):
		$BossAnims.play("idle" if isBlocked else "walk")
	
	currentProjectileCooldown -= delta
	if(currentProjectileCooldown < 0):
		currentProjectileCooldown = projectileBaseCooldown
		var proj = projectile.instantiate()
		proj.position = position
		proj.position.x -= 20
		proj.position.y -= 250
		add_sibling(proj)
		

func _on_boss_anims_animation_finished() -> void:
	$BossAnims.play("idle")
	isAttacking = false


func _on_block_area_area_entered(area: Area2D) -> void:
	super._on_area_2d_area_entered(area)
