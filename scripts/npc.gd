class_name NPC extends Node
@export var file_name : String
func interact(player : CharacterBody2D) -> void:
	var dialogue = load("res://data/dialogues/" + file_name + ".dialogue")
	DialogueManager.show_dialogue_balloon(dialogue)
	await DialogueManager.dialogue_ended
