class_name DialogueTrigger extends Area2D
@export var file_name : String
func _ready():
	body_entered.connect(_on_body_entered)
func _on_body_entered(body):
	if body is Player:
		var dialogue = load("res://data/dialogues/" + file_name + ".dialogue")
		DialogueManager.show_dialogue_balloon(dialogue)
		await DialogueManager.dialogue_ended
