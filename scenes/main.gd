extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_base_hit() -> void:
	$Camera2D.apply_shake()
	$HUD/HealthBar.health = $Tower.current_HP
	
func _on_hud_start_game() -> void:
	$Tower.reset()
	$WaveHandler/MobSpawnTimer.start()
	$HUD.update_wave($WaveHandler.currentWave + 1)
	$HUD/HealthBar.init_HP($Tower.current_HP)

func _on_base_game_over() -> void:
	end_game()


func _on_wave_handler_wave_change() -> void:
	$HUD.update_wave($WaveHandler.currentWave + 1)


func _on_wave_handler_win() -> void:
	end_game(true)

func end_game(isWin:bool=false):
	$WaveHandler/MobSpawnTimer.stop()
	var all_mobs = get_tree().get_nodes_in_group("mobs")
	for mob in all_mobs:
		mob.queue_free()
	await get_tree().create_timer(1.5).timeout
	$HUD/Wave.hide()
	$HUD/HealthBar.hide()
	$HUD/Message.show()
	$HUD/Message.text = "Game Over !" if !isWin else "You Survived !!"
	await get_tree().create_timer(3).timeout
	$Tower.set_particles($Tower.smoke_particles,false,true)
	$HUD/ColorRect.show()
	$HUD/StartButton.text = "Restart"
	$HUD/StartButton.show()
	$HUD/Message.text = "Dynamic Defense"
	$WaveHandler.currentWave = 0
