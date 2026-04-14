extends Node
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var mage    : CharacterTemplate = preload("res://data/combat/characters/mage.tres")
var strzyga : CharacterTemplate = preload("res://data/combat/characters/strzyga.tres")
var enemies : Array[CharacterTemplate] = [mage, strzyga]

var player : CharacterTemplate = preload("res://data/combat/characters/player.tres").duplicate()
var jacek  : CharacterTemplate = preload("res://data/combat/characters/jacek.tres").duplicate()
var recruitable: Dictionary[String, CharacterTemplate] = {
	"jacek": jacek
}
var party: Array[CharacterTemplate] = []
var all : Array[CharacterTemplate] = [player, jacek, mage, strzyga]
var intro_played   : bool = false
var jacek_recruited : bool = false

const battle_scene := "res://scenes/combat/combat.tscn"
var return_scene_path: String = ""
var return_position: Vector2 = Vector2.ZERO
var current_enemies: Array[CharacterTemplate] = []

func _ready() -> void:
	rng.randomize()
	party.append(player)
	for character in all:
		character.hp = character.max_hp
		character.mp = character.max_mp
	
func add_party_member(_name : String) -> void:
	party.append(recruitable[_name])

func start_battle(from_location: Node, enemy_arr: Array[CharacterTemplate]) -> void:
	return_scene_path = from_location.scene_file_path
	return_position = from_location.player.global_position
	scene_manager.player = from_location.player
	scene_manager.player.get_parent().remove_child(scene_manager.player)
	current_enemies.clear()
	for enemy in enemy_arr:
		current_enemies.append(enemy.duplicate())
	from_location.get_tree().call_deferred("change_scene_to_file", battle_scene)

func end_battle(victory: bool) -> void:
	if !victory: get_tree().quit()
	for character in party:
		if (character.hp > 0):
			character.exp += 25
			if character.exp >= character.next_lvl:
				handle_level_up(character)
	get_tree().change_scene_to_file(return_scene_path)

func handle_level_up(character : CharacterTemplate) -> void:
	character.exp = 0
	character.next_level *= character.next_lvl_formula
