extends Node2D

signal wave_change
signal win

@export var waves : Array[Wave]
@export var flyingSpawnPointOffset:int = -50

var nbWaves: int
var nbEnemiesSpawned: int
var currentWave: int = 0

func _ready() -> void:
	$MobSpawnLocation.position = position
	$FlyingSpawnLocation.position = Vector2(position.x, position.y + flyingSpawnPointOffset)
	nbWaves = waves.size()
	
func _process(delta: float) -> void:
	pass
	
func get_wave(num):
	return waves[min(num, (nbWaves - 1))]

## Checks if we need to move to the next wave
func checkWave():
	var wave:Wave = get_wave(currentWave)
	if nbEnemiesSpawned == wave.enemyCount : #and currentWave != nbWaves - 1
		currentWave += 1
		nbEnemiesSpawned = 0
		$MobSpawnTimer.stop()
		$WaveTimer.start()
		await get_tree().create_timer(3).timeout
		wave_change.emit()
	#elif nbEnemiesSpawned == wave.enemyCount and currentWave == nbWaves - 1:
		#$MobSpawnTimer.stop()
		#nbEnemiesSpawned = 0
		#win.emit()

func _on_mob_spawn_timer_timeout() -> void:
	var wave:Wave = get_wave(currentWave)
	
	# Calcule la somme totale des poids
	var total_weight = 0.0
	for r in wave.mobs.values():
		total_weight += r
	
	# Tire un nombre aléatoire entre 0 et total_weight
	var pick = randf() * total_weight
	
	# Trouve quel mob correspond à ce tirage
	var cumulative = 0.0
	var chosen_mob = null
	
	for mob in wave.mobs :
		cumulative += wave.mobs[mob]
		if(pick <= cumulative):
			chosen_mob = mob.instantiate()
			print(chosen_mob)
			chosen_mob.connect("dead", mob_killed.bind(chosen_mob.goldDropped))
			break
	
	# Instancie le mob choisi
	chosen_mob.position = $MobSpawnLocation.position if !chosen_mob.isFlying else $FlyingSpawnLocation.position
	add_sibling(chosen_mob)
	nbEnemiesSpawned += 1
	
	checkWave()

func mob_killed(goldDropped:int):
	GoldSystem.updateGold(goldDropped)
	
func _on_wave_timer_timeout() -> void:
	$MobSpawnTimer.start()
