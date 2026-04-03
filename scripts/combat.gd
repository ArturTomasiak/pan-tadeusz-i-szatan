extends Node2D

const actor_scene = preload("res://scenes/combat/actor.tscn")
const label_scene = preload("res://scenes/combat/label.tscn")

var party_data : Array[CharacterTemplate] = []
var enemy_data : Array[CharacterTemplate] = []
var party_actors : Array[Actor] = []
var enemy_actors : Array[Actor] = []
var turn_order   : Array[Actor] = []
var turn_index : int = 0
var ongoing : bool = true
var victory : bool

@onready var party : Node2D = $party
@onready var enemy : Node2D = $enemy
@onready var ui : Control = $CanvasLayer/ui

const enemy_positions : Array[Vector2] = [
	Vector2(-50, 20),
	Vector2(-55, -20),
	Vector2(-50, -60)
]
const party_positions : Array[Vector2] = [
	Vector2(0, 25),
	Vector2(5, -25),
	Vector2(0, -65)
]

func _ready() -> void:
	party_data = game_state.party
	enemy_data = game_state.current_enemies
	spawn_party()
	spawn_enemies()
	build_turn_order()
	ui.set_party(party_data)
	ui.update_party_status()
	while ongoing: await combat()
	game_state.end_battle(victory)

func spawn_party() -> void:
	for i in party_data.size():
		var actor : Actor = actor_scene.instantiate()
		party.add_child(actor)
		actor.position = party_positions[i]
		actor.setup(party_data[i], false)
		party_actors.append(actor)

func spawn_enemies() -> void:
	for i in enemy_data.size():
		var actor : Actor = actor_scene.instantiate()
		enemy.add_child(actor)
		actor.position = enemy_positions[i]
		actor.setup(enemy_data[i], true)
		enemy_actors.append(actor)

func build_turn_order() -> void:
	turn_order.clear()
	turn_order.append_array(party_actors)
	turn_order.append_array(enemy_actors)
	turn_order.sort_custom(func(a: Actor, b: Actor): return a.character.agility > b.character.agility)

func combat() -> void:
	if all_dead(party_actors):
		victory = false
		ongoing = false
		return
	if all_dead(enemy_actors):
		victory = true
		ongoing = false
		return
	if turn_index >= turn_order.size():
		turn_index = 0
		reset_round_states()
	var actor : Actor = turn_order[turn_index]
	if actor.is_dead():
		turn_index += 1
		return
	if actor.is_enemy:
		await enemy_turn(actor)
	else:
		await player_turn(actor)
	ui.update_party_status(actor.character)
	refresh_actor_states()
	turn_index += 1

func player_turn(actor : Actor) -> void:
	var action : Dictionary = await ui.choose_player_action(actor.character, enemy_actors)
	match action.type:
		"attack":
			var target: Actor = action.target
			await perform_attack(actor, target)
		"defend":
			actor.is_defending = true

func enemy_turn(actor : Actor) -> void:
	var targets : Array[Actor] = living_party()
	if targets.is_empty():
		return
	var target: Actor = targets[randi() % targets.size()]
	await perform_attack(actor, target)

func perform_attack(attacker : Actor, target : Actor) -> void:
	if attacker.is_dead() or target.is_dead():
		return
	await attacker.play_attack_animation()
	var dmg : int = attacker.character.attack + game_state.rng.randi_range(-1, 1)
	if target.is_defending:
		dmg = int(round(dmg * 0.6))
	target.character.hp = max(0, target.character.hp - dmg)
	spawn_damage_popup(target, dmg)
	await target.play_hit_animation()

func refresh_actor_states() -> void:
	for actor in party_actors + enemy_actors:
		actor.update_visual_state()

func living_party() -> Array[Actor]:
	var arr: Array[Actor] = []
	for actor in party_actors:
		if not actor.is_dead():
			arr.append(actor)
	return arr

func all_dead(actors : Array[Actor]) -> bool:
	for actor in actors:
		if actor.character.hp > 0:
			return false
	return true	

func reset_round_states() -> void:
	for actor in party_actors + enemy_actors:
		actor.is_defending = false

func spawn_damage_popup(target_actor : Actor, amount : int) -> void:
	var popup : Label = label_scene.instantiate()
	add_child(popup)
	popup.show_value(amount, target_actor.marker.global_position)
