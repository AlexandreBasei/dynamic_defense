extends Label

var cost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cost = int(text)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (GoldSystem.gold < cost):
		modulate = Color("c8c8c8ff")
	else:
		modulate = Color("#ffffff")
