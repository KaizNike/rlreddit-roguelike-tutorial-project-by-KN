extends Node

var multiplePlayers = false
var players = {}
var player = {"id":0, "playerController": "k1", "loc": Vector2.ZERO, "localLoc":Vector2.ZERO}
var actors = []
var seeds = []
var map = []
var map_size = Vector2(300,300)
@onready var drunk_steps = int((map_size.y*map_size.x)/8)
@onready var drunk_minor_steps = int(drunk_steps * 0.75)

signal synch_moves
signal input_not_handled
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#map = generate_map()
	#print("Loaded map!")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called after a generate
func new_player(controller):
	var new = player.duplicate(true)
	new.id = randi()
	while new.id in players.keys():
		new.id = randi()
	new.playerController = controller
	players[new.id] = new.duplicate(true)
	print(players)
	

func manage_turn():
	if multiplePlayers:
		return true
	return true
	
# Borrowed from Breath of the Roguelike
func generate_map():
	var a = []
	var minor_caves = randi() % 8
	print("Minors: ", minor_caves)
	var portion = 0.05
	var steps = 0
	for y in range(map_size.y):
		for x in range(map_size.x):
			steps += 1
	portion = int(steps * portion)
	steps = 0
	for y in range(map_size.y):
		var new_line = []
		for x in range(map_size.x):
			new_line.append("#")
			steps += 1
			if steps % portion == 0:
				pass
				#await get_tree().physics_frame
		a.append(new_line)
	print("CAVE GEN STEP 1: Base Coat")
	var start = Vector2(map_size/2)
	seeds.append(start)
	for step in range(drunk_steps):
		a[start.y][start.x] = " "
		var dir = Vector2.ZERO
		if step % portion == 0:
			if start not in seeds:
				seeds.append(start)
		dir.x = (randi() % 3) - 1
		if dir.x == 0:
			dir.y = (randi() % 3) - 1
		var end = start + dir
		if end.x == 0 or end.y == 0 or end.x == map_size.x - 1 or end.y == map_size.y-1:
			a[end.y][end.x] = "#"
			continue
		else:
			start = end 
		
	#print(a)
	print("CAVE GEN DONE!")
	seeds.shuffle()
	map = a.duplicate(true)
	#return a
