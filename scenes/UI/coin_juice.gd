extends Sprite2D

@export var animTime:float = 0.35

var startPos:Vector2
var endPos:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func moveToGoldLabel(targetPosition:Vector2):
	var originalPos = global_position       

	startPos = originalPos
	endPos = targetPosition  

	var tween = create_tween()
	tween.tween_method(
		Callable(self, "_update_gold_anim"),
		0.0, 1.0, animTime
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(_on_anim_finished)
	
func _update_gold_anim(t: float) -> void:
	var base_pos: Vector2 = startPos.lerp(endPos, t)
	
	global_position = base_pos
	
func _on_anim_finished():
	queue_free()
