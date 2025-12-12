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
	currentWave = duplicate_wave(waves[0])
	
func _process(delta: float) -> void:
	pass

func duplicate_wave(wave: Wave) -> Wave:
	var new_wave = Wave.new()
	for preset in wave.presets:
		new_wave.presets.append(preset.duplicate(true))  # Duplique chaque preset
	return new_wave	

func reset_waves():
	currentWaveNumber = 0
	mobsRemaining = 0
	currentWave = duplicate_wave(waves[0])
	
func get_wave(num):
	return waves[min(num, (nbWaves - 1))]

## Checks if we need to move to the next wave
func checkWave():
	
	if mobsRemaining == 0 and currentWave.presets.is_empty():
		
		currentWaveNumber += 1
		currentWave = Wave.new()
		currentWave = duplicate_wave(get_wave(currentWaveNumber))
		
		mobsRemaining = 0
		wave_change.emit()
		$WaveTimer.start()
		await $WaveTimer.timeout

func get_random_preset():
	var preset:WavePreset = currentWave.presets[randi_range(0,currentWave.presets.size() -1)]
	return preset

func _on_mob_spawn_timer_timeout() -> void:
	await checkWave()
	
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
