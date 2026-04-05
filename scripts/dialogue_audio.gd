extends Node
var player : AudioStreamPlayer = null
func _ready():
	if !player: 
		player = AudioStreamPlayer.new()
		add_child(player)
func play(file_name: String, volume_modify: int = 0):
	if player.playing:
		player.stop()
	player.stream = load("res://data/dialogues/" + file_name + ".mp3")
	player.volume_db = 0 + volume_modify
	player.play()
func stop():
	player.stop()
