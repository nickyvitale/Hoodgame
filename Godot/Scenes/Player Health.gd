extends Label

var player = null
var slime = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player = get_node("../Player")
	slime = get_node("../Slime")
	if player and player.health > 0 and slime and slime.health > 0:
		self.text = "Player Health:d " + str(player.health) + ",		Slime Health: " + str(slime.health)
	elif player and player.health > 0:
		self.text = "YOU WIN"
	elif slime and slime.health > 0:
		self.text = "GAME OVER"
