extends Window

## Main Player Window - to be copied between players

var visibleFloor = []
var rememberedMap = []
var visibleIndex = Vector2.ZERO
var stam = 5
var health = 100
var status = "IN ROOM"
var visible_size = Vector2(21,14)
var light_radius = 4

# Change on creation
var playerController = "k1"
var Id = 0
#@export var loc = Vector2.ZERO

const COLLIDES = ["#", "D", "X", "*"]

const ENTITIES = ["B","k", "☻"]

const INTERACTS = ["D", "/"]

const MYSTERY = ["?"]

const ALL = {"#": "WALL", " ": "FLOOR", ".": "FOOTSTEP", "☻": "FREN",
#INTERACTS
"D": "DOOR", "/": "AJAR DOOR",
#ENTITIES
"k": "KOBOLD", "B": "BEAR",
#MYsTERy
"?": "UNKNOWN"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	#visibleFloor = _get_text_as_array(%"⌂TextEdit".text)
	visibleFloor = _get_visible_floor() #TurnManager.generate_map())
	%"⌂TextEdit".text = _return_array_to_text(visibleFloor)
	TurnManager.connect("synch_moves",Callable(self,"synch"))
	TurnManager.connect("input_not_handled", Callable(self,"check_input"))
	pass # Replace with function body.


func _input(event):
	var dir = Input.get_vector(playerController+"_move_w",playerController+"_move_e",playerController+"_move_n",playerController+"_move_s")
	var wait = Input.is_action_pressed(playerController+"_sleep")
	var tab_dir = int(Input.is_action_pressed(playerController+"_tab_right")) - int(Input.is_action_pressed(playerController+"_tab_left"))
	print(tab_dir)
	#if Input.is_action_pressed(playerController+"_tab_right"):
		#print("This works!")
		#print(int(Input.is_action_pressed(playerController+"_tab_right")))
		#return
	if tab_dir != 0:
		$TabContainer.current_tab = clamp($TabContainer.current_tab+tab_dir,0,$TabContainer.get_tab_count())
		return
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
				stam = clamp(stam,0,5)
				write_stat2()
			

func input_deferred(event):
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	

func check_input():
	pass

#func _find_player(array) -> Vector2:
	#var Pos = Vector2.ZERO
	#for y in array:
		#for x in y:
			#if x == "☻":
				#return Pos
			#Pos.x += 1
		#Pos.x = 0
		#Pos.y += 1
	##Pos = TurnManager.players[Id].loc
	#return Pos

func synch():
	update_visible_floor()


func _get_visible_floor() -> Array:
	var a = []
	var pos = TurnManager.players[Id].loc #Vector2(_find_player(array))
	TurnManager.players[Id].localLoc = Vector2(int(visible_size.x/2-1),int(visible_size.y/2-1))
	var find = pos - Vector2(int(visible_size.x/2-1),int(visible_size.y/2-1))
	visibleIndex = find
	for y in range(visible_size.y):
		var new_line = []
		find.x = pos.x - int(visible_size.x/2-1)
		for x in range(visible_size.x):
			if find.y < 0 or find.x < 0 or find.y > TurnManager.map_size.y or find.x > TurnManager.map_size.x:
				continue
			var item = TurnManager.map[find.y][find.x]
			if pos.distance_to(find) <= light_radius and is_cell_visible(find):
				new_line.append(item)
			else:
				new_line.append("?")
			find.x += 1
		a.append(new_line)
		find.y += 1
	return a


func update_visible_floor():
	var pos = Vector2(TurnManager.players[Id].loc)
	var a = []
	var find = visibleIndex
	for y in range(visible_size.y):
		var new_line = []
		find.x = visibleIndex.x
		for x in range(visible_size.x):
			if find.y < 0 or find.x < 0 or find.y > TurnManager.map_size.y or find.x > TurnManager.map_size.x:
				continue
			var item = TurnManager.map[find.y][find.x]
			if pos.distance_to(find) <= light_radius and is_cell_visible(find):
				new_line.append(item)
			else:
				new_line.append("?")
			find.x += 1
		a.append(new_line)
		find.y += 1
	visibleFloor = a.duplicate(true)
	%"⌂TextEdit".text = _return_array_to_text(visibleFloor)

func is_cell_visible(cell_pos):
	var steps = 0
	# Bresenham by Copilot
	var player_position = TurnManager.players[Id].loc
	var x0 = int(player_position.x)
	var y0 = int(player_position.y)
	var x1 = int(cell_pos.x)
	var y1 = int(cell_pos.y)
	
	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var sx =  1 if x0 < x1 else -1
	var sy =  1 if y0 < y1 else -1
	var err = dx - dy
	
	while true:
		if TurnManager.map[y0][x0] in COLLIDES: # Check if the cell is an obstacle
			if steps > 0:
				return false
			steps += 1
		if x0 == x1 and y0 == y1:
			return true
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x0 += sx
		if e2 < dx:
			err += dx
			y0 += sy


func move_player(dir):
	var status_changed = false
	var pos = TurnManager.players[Id].localLoc#_find_player(visibleFloor)
	var globalPos = TurnManager.players[Id].loc#Vector2(_find_player(TurnManager.map))
	if not pos:
		print("player not found")
		return false
	var localLoc = pos + dir
	var globalLoc = globalPos + dir
	if localLoc.x < 0 or localLoc.x > visibleFloor[0].size() - 1 or localLoc.y < 0 or localLoc.y > visibleFloor.size() - 1:
		visibleFloor = _get_visible_floor()
		%"⌂TextEdit".text = _return_array_to_text(visibleFloor)
		if localLoc.x < 0 or localLoc.x > visibleFloor[0].size() - 1 or localLoc.y < 0 or localLoc.y > visibleFloor.size() - 1:
			%"⌂Stat1".text = "FEEL: " + "VOID"
			return false
		else:
			pass
	var Dest = visibleFloor[localLoc.y][localLoc.x]
	var globalDest = TurnManager.map[globalLoc.y][globalLoc.x]
	if Dest in MYSTERY:
		%"⌂Stat1".text = "FIND: " + ALL[globalDest]
		Dest = globalDest
		%"⌂TextEdit".text = _return_array_to_text(visibleFloor)
		return
	if Dest in INTERACTS or Dest in ENTITIES:
		_handle_player_interaction(localLoc,Dest)
		status_changed = true
	if Dest in COLLIDES or Dest in ENTITIES:
		%"⌂Stat1".text = "FEEL: " + ALL[Dest]
		return
		pass
	TurnManager.map[globalPos.y][globalPos.x] = "."
	visibleFloor[pos.y][pos.x] = "."
	TurnManager.map[globalPos.y+dir.y][globalPos.x+dir.x] = "☻"
	visibleFloor[localLoc.y][localLoc.x] = "☻"
	TurnManager.players[Id].localLoc = localLoc
	TurnManager.players[Id].loc = Vector2(globalPos.x+dir.x,globalPos.y+dir.y)
	
	if TurnManager.multiplePlayers:
		TurnManager.emit_signal("synch_moves")
	if not status_changed:
		#print(dir)
		var dirs = {"(0, 1)": "SOUTH", "(0, -1)": "NORTH", "(1, 0)": "WEST", "(-1, 0)": "EAST"}
		if str(dir) in dirs.keys():
			var text = "MOVE: " + dirs[str(dir)]
			%"⌂Stat1".text = text
	update_visible_floor()
	#%"⌂TextEdit".text = _return_array_to_text(visibleFloor)
	

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
