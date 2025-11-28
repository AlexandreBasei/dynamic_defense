extends CanvasLayer

@onready var pause_btn
@onready var menu = $Menu
@onready var settings = $Options
@onready var background = $PauseBg

var is_game_started:bool = false

func _ready() -> void:
	pause_btn = get_parent().get_node("Main/HUD/PauseButton")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and is_game_started:
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

func _on_resume_button_button_down() -> void:
	resume_game()

func _on_settings_button_button_down() -> void:
	menu.hide()
	settings.show()
	
func pause_game():
	background.show()
	menu.show()
	settings.hide()
	pause_btn.hide()
	get_tree().paused = true
	
func resume_game():
	background.hide()
	menu.hide()
	settings.hide()
	pause_btn.show()
	get_tree().paused = false
