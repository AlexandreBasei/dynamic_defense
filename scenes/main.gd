extends Node2D

@onready var card_manager = $CardManager
@onready var deck = $CardManager/Deck
@onready var player_hand = $CardManager/PlayerHand
@onready var discard_pile = $CardManager/DiscardPile
@onready var unitSpawn = $UnitSpawnPoint

@export var units: Array[PackedScene]

var warrior_offset:int = 0
var archer_offset:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#setup_game()
	pass

func setup_game():
	# Create a deck of cards
	create_standard_deck()

func create_standard_deck():
	var names = ["fireball","fireball","fireball","fireball","fireball","fireball","fireball","fireball"]
	for _name in names:
		var card_name = _name
		var card = card_manager.card_factory.create_card(card_name, deck)
		print(card_name)
		deck.add_card(card)

func deal_cards_to_hand(count: int):
	for i in count:
		if deck.get_card_count() > 0:
			var card = deck.get_top_cards(1).front()
			player_hand.move_cards([card])
			# Deal initial hand
	deal_cards_to_hand(5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_base_hit() -> void:
	$Camera2D.apply_shake()
	$HUD/HealthBar.health = $Tower.current_HP
	
func _on_hud_start_game() -> void:
	$Tower.reset()
	$WaveHandler/MobSpawnTimer.start()
	$HUD.update_wave($WaveHandler.currentWave + 1)
	$HUD/HealthBar.init_HP($Tower.current_HP)
	$HUD/SpawnDefender.show()
	$HUD/SpawnArcher.show()
	$HUD/Gold.show()

func _on_base_game_over() -> void:
	end_game()


func _on_wave_handler_wave_change() -> void:
	$HUD.update_wave($WaveHandler.currentWave + 1)

func _on_wave_handler_win() -> void:
	end_game(true)

func end_game(isWin:bool=false):
	$WaveHandler/MobSpawnTimer.stop()
	var all_mobs = get_tree().get_nodes_in_group("mobs")
	for mob in all_mobs:
		mob.queue_free()
	await get_tree().create_timer(1.5).timeout
	$HUD/Wave.hide()
	$HUD/HealthBar.hide()
	$HUD/SpawnDefender.hide()
	$HUD/SpawnArcher.hide()
	$HUD/Gold.hide()
	$HUD/Message.show()
	$HUD/Message.text = "Game Over !" if !isWin else "You Survived !!"
	await get_tree().create_timer(3).timeout
	$Tower.set_particles($Tower.smoke_particles,false,true)
	$HUD/ColorRect.show()
	$HUD/StartButton.text = "Restart"
	$HUD/StartButton.show()
	$HUD/Message.text = "Dynamic Defense"
	$WaveHandler.currentWave = 0

func _on_hud_spawn_defender_pressed(unitNumber: int) -> void:
	var unit = units[unitNumber].instantiate()
	var offset = warrior_offset if unitNumber == 0 else archer_offset
	if (unit.cost <= GoldSystem.get_gold()):
		unit.position = unitSpawn.position
		unit.walkStop = unit.walkStop - offset
		add_child(unit)
		if (unitNumber == 0): warrior_offset += 50
		if (unitNumber == 1): archer_offset += 50
		GoldSystem.updateGold(unit.cost)
