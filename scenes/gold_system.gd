extends Node2D

var gold_label:Label
var gain_popup:Label
var coin_sprite:AnimatedSprite2D

@export var base_gold:int
@export var coinJuiceScene:PackedScene

var gold:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gold_label = get_parent().get_node("Main/HUD/Gold")
	gain_popup = gold_label.get_node("GainPopup")
	coin_sprite = gold_label.get_node("CoinSprite")
	gold = base_gold
	gold_label.text = str(gold)

func gainGold(amount:int, mobKilled):
	gold += amount
	gold_label.text = str(gold)
	coin_sprite.play("flip")
	gain_popup.text = "+" + str(amount)
	gain_popup_fade_in_out()

func loseGold(amount:int):
	gold -= amount
	gold_label.text = str(gold)
	coin_sprite.play("flip")
	gain_popup.text = "-" + str(amount)
	gain_popup_fade_in_out()
	
func reset_gold():
	gold = base_gold

func gain_popup_fade_in_out(duration:float = 0.2):
	var tween = create_tween()
	tween.tween_property(gain_popup, "modulate:a", 1.0, duration)
	
	await get_tree().create_timer(duration).timeout
	
	var tween2 = create_tween()
	tween2.tween_property(gain_popup, "modulate:a", 0.0, duration)
