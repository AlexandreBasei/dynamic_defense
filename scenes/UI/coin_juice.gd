extends Sprite2D

@export var animTime:float = 1
var startPos:Vector2
var endPos:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move_to_gold_sprite(target_position:Vector2, gold_amount:int):
	startPos = global_position
	endPos = target_position
	var tween = create_tween()
	tween.tween_property(self, "global_position", endPos, animTime)\
		 .set_trans(Tween.TRANS_QUAD)\
		 .set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(Callable(self, "_on_anim_finished").bind(gold_amount))

func _on_anim_finished(gold_amount):
	GoldSystem.gain_gold(gold_amount)
	queue_free()
