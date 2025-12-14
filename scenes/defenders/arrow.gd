extends Area2D

@export var speed:float = 200

var damages:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(10.0).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_local_x(speed * delta)




func _on_area_entered(area: Area2D) -> void:
	if (area.is_in_group("mobs")):
		area.take_damage(damages)
		queue_free()
