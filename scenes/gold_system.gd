extends Node2D

var gold_label:Label
var coin_sprite:AnimatedSprite2D

@export var gold:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gold_label = get_parent().get_node("Main/HUD/Gold")
	coin_sprite = gold_label.get_node("CoinSprite")

func updateGold(amount:int, increase:bool = false ):
	if (increase):
		gold += amount
	else:
		gold -= amount
	gold_label.text = str(gold)
	coin_sprite.play("flip")
