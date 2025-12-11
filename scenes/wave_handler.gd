extends Node2D

signal wave_change
signal win

@export var waves : Array[Wave]
@export var flyingSpawnPointOffset:int = -50

var nbWaves: int
var currentWaveNumber: int = 0
var currentWave:Wave
var mobsRemaining:int = 0

func _ready() -> void:
	$MobSpawnLocation.position = position
	$FlyingSpawnLocation.position = Vector2(position.x, position.y + flyingSpawnPointOffset)
	nbWaves = waves.size()
	currentWave = Wave.new()
	currentWave.presets = waves[0].presets.duplicate()
	
func _process(delta: float) -> void:
	pass
	
	
func reset_waves():
	currentWaveNumber = 0
	mobsRemaining = 0
	currentWave = Wave.new()
	currentWave.presets = waves[0].presets.duplicate()
	
func get_wave(num):
	return waves[min(num, (nbWaves - 1))]

## Checks if we need to move to the next wave
func checkWave():
	
	if mobsRemaining == 0 and currentWave.presets.is_empty():
		
		currentWaveNumber += 1
		currentWave = Wave.new()
		currentWave.presets = get_wave(currentWaveNumber).presets.duplicate()
		
		mobsRemaining = 0
		$MobSpawnTimer.stop()
		$WaveTimer.start()
		await get_tree().create_timer(3).timeout
		wave_change.emit()
	#elif nbEnemiesSpawned == wave.enemyCount and currentWaveNumber == nbWaves - 1:
		#$MobSpawnTimer.stop()
		#nbEnemiesSpawned = 0
		#win.emit()

func get_random_preset():
	var preset:WavePreset = currentWave.presets[randi_range(0,currentWave.presets.size() -1)]
	return preset

func _on_mob_spawn_timer_timeout() -> void:
	checkWave()
	
	if (not currentWave.presets.is_empty()):
		var preset = get_random_preset()
		preset.enemyCount -= 1
		
		# Calcule la somme totale des poids
		var total_weight = 0.0
		
		for r in preset.mobs.values():
			total_weight += r
		
		# Tire un nombre aléatoire entre 0 et total_weight
		var pick = randf() * total_weight
		
		# Trouve quel mob correspond à ce tirage
		var cumulative = 0.0
		var chosen_mob = null
		
		for mob in preset.mobs :
			cumulative += preset.mobs[mob]
			if(pick <= cumulative):
				chosen_mob = mob.instantiate()
				#print(chosen_mob)
				chosen_mob.connect("dead", mob_killed.bind(chosen_mob.goldDropped,chosen_mob))
				chosen_mob.connect("destroyed", mob_destroyed.bind())
				break
		
		# Instancie le mob choisi
		chosen_mob.position = $MobSpawnLocation.position if !chosen_mob.isFlying else $FlyingSpawnLocation.position
		add_sibling(chosen_mob)
		mobsRemaining += 1
		
		if (preset.enemyCount <= 0):
			currentWave.presets.erase(preset)

func mob_killed(goldDropped:int,mobKilled):
	GoldSystem.gain_gold_anim(goldDropped,mobKilled)
	mobsRemaining -= 1
	
func mob_destroyed():
	mobsRemaining -= 1
	
func _on_wave_timer_timeout() -> void:
	$MobSpawnTimer.start()
