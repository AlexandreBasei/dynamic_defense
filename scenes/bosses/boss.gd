extends Mob

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func attack() :
	$BossAnims.play("attack")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if(!isBlocked):
		$BossAnims.play("walk")

func _on_boss_anims_animation_finished() -> void:
	$BossAnims.play("idle")


func _on_block_area_area_entered(area: Area2D) -> void:
	super._on_area_2d_area_entered(area)
