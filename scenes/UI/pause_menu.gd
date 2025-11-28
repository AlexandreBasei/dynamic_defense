extends CanvasLayer

@onready var pause_btn = $PauseButton
@onready var menu = $Menu

func _ready() -> void:
	menu.hide()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()


func _on_pause_button_button_down() -> void:
	pause_game()

func _on_resume_button_button_down() -> void:
	resume_game()

func pause_game():
	menu.show()
	pause_btn.hide()
	get_tree().paused = true
	
func resume_game():
	menu.hide()
	pause_btn.show()
	get_tree().paused = false
