extends Node2D

signal wave_change

@export var waves : Array[Node2D]

var nbWaves: int
var nbEnemiesSpawned: int
var currentWave: int = 0

func _ready() -> void:
	$MobSpawnLocation.position = position
	nbWaves = waves.size() - 1
	
func _process(delta: float) -> void:
	pass

func checkWave():
	var wave:Node2D = waves[currentWave]
	if nbEnemiesSpawned == wave.nbEnemiesInWave && currentWave < nbWaves - 1:
		++currentWave
		wave_change.emit()
		$MobSpawnTimer.stop()
		$WaveTimer.start()

func _on_mob_spawn_timer_timeout() -> void:
	var wave:Node2D = waves[currentWave]
	var mob
	var spawnRate = randf_range(0.1,100)
	for i in range(wave.mobs.size()):
		print(spawnRate)
		if wave.spawnRate[i] <= spawnRate:
			mob = wave.mobs[i].instantiate()
			
	mob.position = $MobSpawnLocation.position
	add_sibling(mob)
	
func _on_wave_timer_timeout() -> void:
	$MobSpawnTimer.start()
