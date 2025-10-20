extends Node2D

signal wave_change
signal win

@export var waves : Array[Node2D]

var nbWaves: int
var nbEnemiesSpawned: int
var currentWave: int = 0

func _ready() -> void:
	$MobSpawnLocation.position = position
	nbWaves = waves.size()
	
func _process(delta: float) -> void:
	pass

func checkWave():
	if currentWave < nbWaves:
		var wave:Node2D = waves[currentWave]
		if nbEnemiesSpawned == wave.nbEnemiesInWave and currentWave != nbWaves - 1:
			currentWave += 1
			nbEnemiesSpawned = 0
			$MobSpawnTimer.stop()
			$WaveTimer.start()
			await get_tree().create_timer(3).timeout
			wave_change.emit()
		elif nbEnemiesSpawned == wave.nbEnemiesInWave and currentWave == nbWaves - 1:
			$MobSpawnTimer.stop()
			win.emit()

func _on_mob_spawn_timer_timeout() -> void:
	if currentWave < nbWaves:
		var wave: Node2D = waves[currentWave]
		var mobs = wave.mobs
		var rates = wave.spawnRate
		
		# Calcule la somme totale des poids
		var total_weight = 0.0
		for r in rates:
			total_weight += r
		
		# Tire un nombre aléatoire entre 0 et total_weight
		var pick = randf() * total_weight
		
		# Trouve quel mob correspond à ce tirage
		var cumulative = 0.0
		var chosen_index = 0
		for i in range(mobs.size()):
			cumulative += rates[i]
			if pick <= cumulative:
				chosen_index = i
				break
		
		# Instancie le mob choisi
		var mob = mobs[chosen_index].instantiate()
		mob.position = $MobSpawnLocation.position
		add_sibling(mob)
		nbEnemiesSpawned += 1
	checkWave()

	
func _on_wave_timer_timeout() -> void:
	$MobSpawnTimer.start()
