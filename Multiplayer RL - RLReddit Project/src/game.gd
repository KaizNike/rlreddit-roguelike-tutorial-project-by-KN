extends Node

var players = 0
var ready_to_play = false

@export var player = PackedScene.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	$GameUI/VBoxContainer/Continue.visible = false
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("k1_interact"):
		TurnManager.new_player("k1")
		players += 1
		%P1K1.text = "["+str(players)+"] PRESS E - WASD: MOVE, Z: SLEEP"
		pass
	if event.is_action_pressed("k2_interact"):
		TurnManager.new_player("k2")
		players += 1
		%P2K2.text = "["+str(players)+"] PRESS ENTER - ARROWS: MOVE, ALT: SLEEP"
		pass
	if event.is_action_pressed("c1_interact"):
		TurnManager.new_player("c1")
		players += 1
		%P3C1.text = "["+str(players)+"] CONTROLLER 0 - PRESS RIGHT SHOULDER - DPAD:MOVE, LEFT SHOULDER: SLEEP"
		pass
	# ADD C2 - Controller 1
	if players > 0:
		$GameUI/VBoxContainer/Continue.visible = true
		ready_to_play = true
	if ready_to_play and event.is_action_pressed("start"):
		start()


func start():
	TurnManager.generate_map()
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