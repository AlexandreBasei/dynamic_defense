extends Area2D

signal hit
signal game_over

@export var max_HP = 100
var current_HP

@export var max_hp_texture: Texture2D
@export var mid_hp_texture: Texture2D
@export var no_hp_texture: Texture2D

var smoke_particles
@export var smoke_offset = 214

var fire_particles

var isFirstGame = false
var is_parrying = false

func _ready():
	current_HP = max_HP
	smoke_particles = get_tree().get_nodes_in_group("smoke_particles")
	fire_particles = get_tree().get_nodes_in_group("fire_particles")
	$ShieldFX.visible = false
	
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("parry") && $ParryCooldown.is_stopped() && $ParryTimer.is_stopped()):
		$ParryTimer.start()
		is_parrying = true
		$ShieldFX.visible = true
	if($ShieldFX.visible == true):
		$ShieldFX.rotation += delta * TAU
		## TODO : change scale depending on rotation
		#var c = cos($ShieldFX.rotation)
		#var s = sin($ShieldFX.rotation)
		#$ShieldFX.scale = Vector2(c-s, s+c)
	
func take_damage(dmg: int) -> void:
	current_HP -= dmg
	if current_HP <= 0:
		current_HP = 0
		$Particles/Game_Over_Particles.emitting = true
		game_over.emit()
	hit.emit()

	var damage_particles = get_tree().get_nodes_in_group("damage_particles")
	for particle in damage_particles:
		particle.emitting = true
	set_tower_texture()
	$Sprite2D.modulate = Color(0.94,0,0,1)
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color(1,1,1,1)
		

func reset() -> void:
	current_HP = max_HP
	set_tower_texture()
	if isFirstGame:
		set_particles(smoke_particles,false,true)
	set_particles(fire_particles, false)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("mobs"):
		if(!area.isFlying || !is_parrying):
			take_damage(area.damages)
			area.queue_free()
		else :
			## todo : knockback
			area.take_damage(10)
		
	if area.is_in_group("projectile"):
		if(!is_parrying) : take_damage(area.damages)
		area.queue_free()

func set_tower_texture() -> void:
	if current_HP > max_HP / 2.0:
		$Sprite2D.texture =  max_hp_texture
	elif current_HP <= max_HP / 2.0 && current_HP > 0.0:
		$Sprite2D.texture =  mid_hp_texture
		set_particles(smoke_particles,true, true)
	else:
		$Sprite2D.texture =  no_hp_texture
		for particle in smoke_particles:
			particle.position.y += smoke_offset
		set_particles(fire_particles, true)

func set_particles(particles, activated:bool, offset:bool = false):
	for particle in particles:
		if activated:
			particle.lifetime = 5
			particle.emitting = true
		else:
			particle.lifetime = 0.1
			particle.emitting = false
			if offset:
				particle.position.y -= smoke_offset


func _on_parry_timer_timeout() -> void:
	is_parrying = false
	$ShieldFX.visible = false
	$ParryCooldown.start()
