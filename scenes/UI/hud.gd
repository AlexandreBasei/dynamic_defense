extends CanvasLayer

signal start_game
signal spawnDefenderPressed(unitNumber:int)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_wave(wave:int) -> void:
	show_text_with_fade($Wave,"Wave " + str(wave),0.5,2.5,0.5)

func _on_button_button_down() -> void:
	$Message.hide()
	$StartButton.hide()
	$ColorRect.hide()
	$HealthBar.show()
	$Wave.show()
	start_game.emit()

func fade_in_text(target: Label, duration: float):
	var tween = create_tween()
	tween.tween_property(target, "modulate:a", 1.0, duration)

func fade_out_text(target: Label, duration: float):
	var tween = create_tween()
	tween.tween_property(target, "modulate:a", 0.0, duration)


func show_text_with_fade(target: Label, new_text: String, fade_in_time: float, visible_time: float, fade_out_time: float):
	target.text = new_text
	target.modulate.a = 0.0
	fade_in_text(target, fade_in_time)
	await get_tree().create_timer(visible_time).timeout
	fade_out_text(target, fade_out_time)


func _on_spawn_defender_button_down() -> void:
	spawnDefenderPressed.emit(0)


func _on_spawn_archer_button_down() -> void:
	spawnDefenderPressed.emit(1)


func _on_pause_button_button_down() -> void:
	PauseMenu.pause_game()
