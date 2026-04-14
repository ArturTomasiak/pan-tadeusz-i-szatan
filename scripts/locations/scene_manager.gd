class_name SceneManager extends Node

var player : Player
var last_scene : String
const scene_path : String = "res://scenes/maps/"

func change_scene(from, to : String) -> void:
	last_scene = from.name
	player = from.player
	player.get_parent().remove_child(player)
	var path : String = scene_path + to + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", path)
