extends Area2D

signal hit(mob:Node2D)

@export var speed:float = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_local_x(speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("mobs")):
		hit.emit(body)
