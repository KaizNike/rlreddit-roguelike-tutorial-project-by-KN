extends Node

# BUGS TO FIX:
## 1. input not clear on different keyboards
## 2. Input on players mapped to framerate which is maxxed at 6, which is weird

var players = 0
var controllers = []
var ready_to_play = false
var started = false

@export var player = PackedScene.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	%Continue.visible = false
	#var inputs = ['k1','k2','c1','c2']
	var inputs = ["k1"]
	for input in inputs:
		set_up_player_labels(input)
	#$GameUI/VBoxContainer/Continue
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("k1_interact") and "k1" not in controllers:
		controllers.append("k1")
		TurnManager.new_player("k1")
		players += 1
		%P1K1.text = "["+str(players)+"] PRESS E - WASD: MOVE, Z: SLEEP"
		pass
	if event.is_action_pressed("k2_interact") and "k2" not in controllers:
		controllers.append("k2")
		TurnManager.new_player("k2")
		players += 1
		%P2K2.text = "["+str(players)+"] PRESS ENTER - ARROWS: MOVE, ALT: SLEEP"
		pass
	if event.is_action_pressed("c1_interact") and "c1" not in controllers:
		controllers.append("c1")
		TurnManager.new_player("c1")
		players += 1
		%P3C1.text = "["+str(players)+"] CONTROLLER 0 - PRESS RIGHT SHOULDER - DPAD:MOVE, LEFT SHOULDER: SLEEP"
		pass
	if event.is_action_pressed("c2_interact") and "c2" not in controllers:
		controllers.append("c2")
		TurnManager.new_player("c2")
		players += 1
		%P4C2.text = "["+str(players)+"] CONTROLLER 1 - PRESS RIGHT SHOULDER - DPAD:MOVE, LEFT SHOULDER: SLEEP"
		pass
	# ADD C2 - Controller 1
	if players > 0:
		%Continue.visible = true
		ready_to_play = true
	if ready_to_play and not started and event.is_action_pressed("start"):
		started = true
		start()
		%Continue.text = "FEEL FREE TO MOVE THE SCREENS!"


func set_up_player_labels(player:String):
	var text = "[_] PRESS "
	if player.contains("c"):
		print("Controller")
		text = "[_] CONTROLLER " + str(int(player[1])+1) + " - PRESS RIGHT SHOULDER - DPAD:MOVE, LEFT SHOULDER: SLEEP"
		match player:
			"c1":
				%P3C1.text = text
			"c2":
				%P4C2.text = text
		return
	var inputs = [player+"_interact",player+"_move_n",player+"_move_w",player+"_move_e",player+"_sleep"]
	for input in inputs:
		var check = InputMap.action_get_events(input)
		check = check[0].as_text()
		print(check)
	

func start():
	TurnManager.generate_map()
	print("SEEDS #: " + str(TurnManager.seeds.size()) + " WORLDSEEDS #: " + str(TurnManager.worldSeeds.size()))
	TurnManager.generate_monsters()
	if TurnManager.players.size() > 1:
		TurnManager.multiplePlayers = true
	for Player in TurnManager.players:
		Player = TurnManager.players[Player].duplicate(true)
		var new = player.instantiate()
		new.Id = Player.id
		new.playerController = Player.playerController
		var Loc = TurnManager.seeds.pop_front()
		TurnManager.map[Loc.y][Loc.x] = "☻"
		TurnManager.players[Player.id].loc = Loc
		match new.playerController:
			"k1":
				new.title = "P1"
			"k2":
				new.title = "TEST"
			"c1":
				new.title = "P3"
		self.add_child(new)
		pass
	pass
