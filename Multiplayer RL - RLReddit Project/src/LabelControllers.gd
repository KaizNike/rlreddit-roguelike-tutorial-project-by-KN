extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	text = "CONTROLLERS FOUND: " + str(Input.get_connected_joypads()) + " #: " + str(Input.get_connected_joypads().size())
	Input.joy_connection_changed.connect(Callable(self, "controllers_changed"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func controllers_changed(device, connected):
	print("New controller!")
	text = "NEW CONTROLLERS! NOW #: " + str(Input.get_connected_joypads().size()) + " , " + str(Input.get_connected_joypads())
	pass
