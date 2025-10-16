extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_base_hit() -> void:
	$HUD.update_hp($Tower.current_HP)
	$Camera2D.apply_shake()


func _on_hud_start_game() -> void:
	$Tower.reset()
	$HUD.update_hp($Tower.current_HP)
	$WaveHandler/MobSpawnTimer.start()


func _on_base_game_over() -> void:
	$WaveHandler/MobSpawnTimer.stop()
	var all_mobs = get_tree().get_nodes_in_group("mobs")
	for mob in all_mobs:
		mob.queue_free()
	await get_tree().create_timer(1.5).timeout
	$HUD/HP.hide()
	$HUD/Wave.hide()
	$HUD/Message.show()
	$HUD/Message.text = "Game Over !"
	await get_tree().create_timer(3).timeout
	$Tower.set_particles($Tower.smoke_particles,false,true)
	$HUD/ColorRect.show()
	$HUD/StartButton.text = "Restart"
	$HUD/StartButton.show()
	$HUD/Message.text = "Dynamic Defense"


func _on_wave_handler_wave_change() -> void:
	$HUD.update_wave($WaveHandler.currentWave + 1)
