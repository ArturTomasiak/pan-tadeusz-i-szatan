extends Location
func _ready():
	if game_state.intro_played: 
		super._ready()
		$szatan.queue_free()
		$god.queue_free()
		if game_state.jacek_recruited:
			$jacek.queue_free()
		return
	var dialogue = load("res://data/dialogues/intro.dialogue")
	DialogueManager.show_dialogue_balloon(dialogue)
	game_state.intro_played = true
