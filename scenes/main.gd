extends Node2D

@onready var unitSpawn = $UnitSpawnPoint
@onready var unitSpawnPanel = $HUD/UnitSpawnPanel

@onready var MainMenuMusic = $Sounds/MainMenuMusic
@onready var GameMusic = $Sounds/GameMusic
@onready var BossMusic = $Sounds/BossMusic
var CurrentMusic
@export var music_trans_duration = 1.0 

@export var units: Array[PackedScene]

const UNIT_OFFSET = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_music(MainMenuMusic)
	GameMusic.volume_db = -80
	BossMusic.volume_db = -80

func queue_music_in(MusicStream, duration):
	MusicStream.play()
	var tween = create_tween()
	tween.tween_property(MusicStream, "volume_db", 0, duration)
	CurrentMusic = MusicStream
	
func queue_music_out(MusicStream, duration):
	var tween = create_tween()
	tween.tween_property(MusicStream, "volume_db", -80, duration)
	tween.tween_callback(func() : MusicStream.stop())

func play_music(MusicStream):
	if(MusicStream != CurrentMusic):
		if(CurrentMusic != null): queue_music_out(CurrentMusic, music_trans_duration)
		queue_music_in(MusicStream, music_trans_duration)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_base_hit() -> void:
	$Camera2D.apply_shake()
	$HUD/HealthBar.health = $Tower.current_HP
	
func _on_hud_start_game() -> void:
	$Tower.reset()
	GoldSystem.reset_gold()
	
	var all_mobs = get_tree().get_nodes_in_group("mobs")
	var all_units = get_tree().get_nodes_in_group("Unit")
	
	for mob in all_mobs:
		mob.queue_free()
	
	for unit in all_units:
		unit.queue_free()
	

	
	$WaveHandler/MobSpawnTimer.start()
	$HUD.update_wave($WaveHandler.currentWaveNumber + 1)
	$HUD/HealthBar.init_HP($Tower.current_HP)
	unitSpawnPanel.show()
	$HUD/Gold.show()
	$HUD/PauseButton.show()
	play_music(GameMusic)
	PauseMenu.is_game_started = true

func _on_base_game_over() -> void:
	end_game()

func _on_wave_handler_wave_change() -> void:
	$HUD.update_wave($WaveHandler.currentWaveNumber + 1)
	if($WaveHandler.currentWaveNumber + 1 % 5 == 0): #boss wave
		play_music(BossMusic)
	else:
		play_music(GameMusic)

func _on_wave_handler_win() -> void:
	end_game(true)

func end_game(isWin:bool=false):
	PauseMenu.is_game_started = false
	$HUD/PauseButton.hide()
	$WaveHandler/MobSpawnTimer.stop()
	var all_mobs = get_tree().get_nodes_in_group("mobs")
	for mob in all_mobs:
		mob.queue_free()
	await get_tree().create_timer(1.5).timeout
	$HUD/Wave.hide()
	$HUD/HealthBar.hide()
	unitSpawnPanel.hide()
	$HUD/Gold.hide()
	$HUD/Message.show()
	$HUD/Message.text = "Game Over !" if !isWin else "You Survived !!"
	await get_tree().create_timer(3).timeout
	$Tower.set_particles($Tower.smoke_particles,false,true)
	$HUD/StartButton.text = "Restart"
	$HUD/StartButton.show()
	$HUD/Message.text = "Dynamic Defense"
	$WaveHandler.reset_waves()

func _on_hud_spawn_defender_pressed(unitNumber: int) -> void:
	var unit = units[unitNumber].instantiate()
	if (unit.cost <= GoldSystem.gold):
		unit.position = unitSpawn.position
		
		# Mémoriser la position de base de la première unité
		unit.set_meta("base_walk_stop", unit.walkStop)
		
		# Compter les unités vivantes du groupe
		var group_name = "warrior" if unitNumber == 0 else "archer"
		var alive_count = get_tree().get_nodes_in_group(group_name).size()
		
		# Positionner la nouvelle unité: base - (nombre de vivantes * OFFSET)
		unit.walkStop = unit.walkStop - (alive_count * UNIT_OFFSET)
		
		unit.connect("dead", unit_died.bind(unitNumber))
		add_child(unit)
		GoldSystem.lose_gold(unit.cost)

func unit_died(unitNumber):
	var group_name = "warrior" if unitNumber == 0 else "archer"
	var alive_group = get_tree().get_nodes_in_group(group_name)
	
	# Faire avancer tous les survivants de l'offset
	for unit in alive_group:
		unit.walkStop += UNIT_OFFSET
	
