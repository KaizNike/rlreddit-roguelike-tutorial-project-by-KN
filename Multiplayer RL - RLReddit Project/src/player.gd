extends Window

## Main Player Window - to be copied between players

var Floor = []
var stam = 5
var health = 100
var status = "IN ROOM"

@export var playerController = "k1"

const COLLIDES = ["#", "D", "X", "*"]

const ENTITIES = ["B","k"]

const INTERACTS = ["D", "/"]

const ALL = {"#": "WALL", " ": "FLOOR", ".": "FOOTSTEP",
#INTERACTS
"D": "DOOR", "/": "AJAR DOOR",
#ENTITIES
"k": "KOBOLD", "B": "BEAR"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Floor = _get_text_as_array(%"⌂TextEdit".text)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	var dir = Input.get_vector(playerController+"_move_w",playerController+"_move_e",playerController+"_move_n",playerController+"_move_s")
	var wait = event.is_action_pressed(playerController+"_sleep")
	if dir or wait:
		if TurnManager.manage_turn():
			print("Yay!")
			if dir:
				if stam:
					print("Moving " + str(dir))
					move_player(dir)
					stam -= 1
					write_stat2()
				else:
					print("Too tired!")
					%"⌂Stat1".text = "REST: " + "NEEDED"
			else:
				print("Resting")
				%"⌂Stat1".text = "REST: " + "+1"
				stam += 1
				write_stat2()
			
		pass
	

func _find_player(array) -> Vector2:
	var Pos = Vector2.ZERO
	for y in array:
		for x in y:
			if x == "☻":
				return Pos
			Pos.x += 1
		Pos.x = 0
		Pos.y += 1
	return Pos


func move_player(dir):
	var status_changed = false
	var pos = _find_player(Floor)
	if not pos:
		print("player not found")
		return false
	var loc = pos + dir
	if loc.x < 0 or loc.x > Floor[0].size() - 1 or loc.y < 0 or loc.y > Floor.size() - 1:
		%"⌂Stat1".text = "FEEL: " + "VOID"
		return false
	var Dest = Floor[loc.y][loc.x]
	if Dest in INTERACTS or Dest in ENTITIES:
		_handle_player_interaction(loc,Dest)
		status_changed = true
	if Dest in COLLIDES or Dest in ENTITIES:
		%"⌂Stat1".text = "FEEL: " + ALL[Dest]
		return
		pass
	Floor[pos.y][pos.x] = "."
	Floor[loc.y][loc.x] = "☻"
	if not status_changed:
		#print(dir)
		var dirs = {"(0, 1)": "SOUTH", "(0, -1)": "NORTH", "(1, 0)": "WEST", "(-1, 0)": "EAST"}
		if str(dir) in dirs.keys():
			var text = "MOVE: " + dirs[str(dir)]
			%"⌂Stat1".text = text
	%"⌂TextEdit".text = _return_array_to_text(Floor)
	

func _handle_player_interaction(loc,obj):
	%"⌂Stat1".text = "FIND: " + ALL[obj]
	#match obj:
		#pass
	pass


func _get_text_as_array(text : String) -> Array:
	var a = []
	var c = text.split("\n", false)
	var longestTextLength = 0
	for line in c:
		if line.length() > longestTextLength:
			longestTextLength = line.length()
#	print(c)
	for line in c:
		var A = []
#		var b = line.split("", false)
#		print(b)
		for Char in line:
			A.append(Char)
#			print(Char)
		if longestTextLength > line.length():
			for spot in range(longestTextLength - line.length()):
				A.append(" ")
		a.append(A)
#	print(a)
	return a


func _return_array_to_text(a:Array) -> String:
	var Return = ""
	for row in a:
		for Char in row:
			Return += Char
		Return += "\n"
	print(Return)
	return Return
	

func write_stat1():
	%"⌂Stat1".text = "STAT: " + status


func write_stat2():
	var stamText = ""
	for spot in range(5):
		if stam > spot:
			stamText += "#"
		else:
			stamText += "_"
	%"⌂Stat2".text = "STAM: [" + stamText + "] ♥ : " + str(health)
	pass
