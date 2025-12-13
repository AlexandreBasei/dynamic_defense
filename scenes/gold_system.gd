extends Node2D

var gold_label:Label
var gain_popup:Label
var coin_sprite:AnimatedSprite2D

@export var base_gold:int
@export var coinJuiceScene:PackedScene
@onready var SfxOnPickup = $CoinPickup

var gold:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gold_label = get_parent().get_node("Main/HUD/Gold")
	gain_popup = gold_label.get_node("GainPopup")
	coin_sprite = gold_label.get_node("CoinSprite")
	gold = base_gold
	gold_label.text = str(gold)

func gain_gold_anim(amount:int, mobKilled):
	var coin_juice = coinJuiceScene.instantiate()
	var hud = get_parent().get_node("Main/HUD")
	hud.add_child(coin_juice)
	
	var cam := get_viewport().get_camera_2d()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var start_screen: Vector2 = (mobKilled.global_position - cam.global_position) * cam.zoom + viewport_size * 0.5
	coin_juice.global_position = start_screen
	coin_juice.move_to_gold_sprite(coin_sprite.global_position, amount)

func gain_gold(amount:int):
	gold += amount
	gold_label.text = str(gold)
	coin_sprite.play("flip")
	gain_popup.text = "+" + str(amount)
	gain_popup_fade_in_out()
	SfxOnPickup.play()

func lose_gold(amount:int):
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
