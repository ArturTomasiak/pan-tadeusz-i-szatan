extends Node2D
const actor_scene = preload("res://scenes/combat/actor.tscn")
var party_data : Array[CharacterTemplate] = []
var enemy_data : Array[CharacterTemplate] = []
var party_actors : Array[Actor] = []
var enemy_actors : Array[Actor] = []
var turn_order   : Array[Actor] = []
var turn_index : int = 0
var ongoing : bool = true
var victory : bool
var herd : Actor
var herd_focus  : Actor

@onready var party : Node2D = $party
@onready var enemy : Node2D = $enemy
@onready var ui : Control = $CanvasLayer/ui

const enemy_positions : Array[Vector2] = [
	Vector2(-50, -20),
	Vector2(-55, -60),
	Vector2(-50, -100)
]
const party_positions : Array[Vector2] = [
	Vector2(0, -25),
	Vector2(5, -65),
	Vector2(0, -105)
]

func _ready() -> void:
	party_data = game_state.party
	enemy_data = game_state.current_enemies
	spawn_party()
	spawn_enemies()
	build_turn_order()
	ui.set_ui(party_actors, enemy_actors)
	ui.update_party_status()
	reset_round_states()
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
	ui.update_party_status(actor.character)
	if actor.is_dead():
		turn_index += 1
		return
	if actor.is_enemy:
		await enemy_turn(actor)
	else:
		await player_turn(actor)
	refresh_actor_states()
	turn_index += 1
	await get_tree().create_timer(1.0).timeout

func player_turn(actor : Actor) -> void:
	var action : Dictionary = await ui.choose_player_action(actor)
	match action.type:
		"attack":
			perform_attack(actor, action.target)
		"ability":
			perform_ability(actor, action.target, action.ability)
		"defend":
			actor.is_defending = true

func enemy_turn(actor : Actor) -> void:
	var targets : Array[Actor] = living(party_actors)
	if targets.is_empty():
		return
	var target : Actor
	match (actor.character.targeting):
		CharacterTemplate.Targeting.HERD:
			target = herd
		CharacterTemplate.Targeting.FOCUS:
			if actor.target.isdead():
				actor.target = targets[game_state.rng.randi() % targets.size()]
			target = actor.target
		CharacterTemplate.Targeting.RANDOM:
			target = targets[game_state.rng.randi() % targets.size()]
		CharacterTemplate.Targeting.HERD_FOCUS:
			if herd_focus.is_dead():
				herd_focus = targets[game_state.rng.randi() % targets.size()]
			target = herd_focus
	perform_attack(actor, target)

func damage_formula(attribute_val : int, mod : float = 1) -> float:
	var base_damage : float = attribute_val * 2
	return base_damage * game_state.rng.randi_range(mod, mod + 0.1)

func perform_attack(attacker : Actor, target : Actor) -> void:
	await attacker.play_animation()
	await target.play_hit_animation()
	deal_damage(target, false, attacker.character.strength)

func deal_damage (target : Actor, magic : bool, attribute_val : int, mod : float = 1) -> void:
	var dmg : float = damage_formula(attribute_val, mod)
	if target.is_defending:
		dmg = dmg * 0.6
	if magic:
		dmg += target.status_effect[AbilityData.StatusEffect.MAGIC] * (attribute_val/4)
	else:
		dmg += target.status_effect[AbilityData.StatusEffect.PHYS] * (attribute_val/4)
	var defence : float = target.character.defense / 3
	defence += target.status_effect[AbilityData.StatusEffect.DEFENCE] * (defence/2)
	dmg -= defence
	target.character.hp -= int(round(dmg))
	target.spawn_damage_label(dmg, Color.RED)

func damage(actor : Actor, target : Actor, ability : AbilityData) -> void:
	var magic : bool
	var attribute_val : int
	var mod : float = ability.damage_multiplier
	if ability.ability_type == ability.AbilityType.MAGIC:
		magic = true
		attribute_val = actor.character.mysticism
	else:
		magic = false
		attribute_val = actor.character.strength
	var targets : Array[Actor] 
	if actor.is_enemy: targets = living(party_actors)
	else:              targets = living(enemy_actors)
	if ability.target_type == AbilityData.TargetType.ALL_ENEMIES:
		for _target in targets:
			deal_damage(_target, magic, attribute_val, mod)
			await _target.play_hit_animation()
	else:
		var repetition : int = game_state.rng.randi_range(ability.repetition_from, ability.repetition_to)
		for i in range (0, repetition):
			if ability.target_type == AbilityData.TargetType.RANDOM:
				target = targets[game_state.rng.randi() % targets.size()]
			deal_damage(target, magic, attribute_val, mod)
			await target.play_hit_animation()

func get_target(target : Actor, ability : AbilityData) -> Array[Actor]:
	match ability.target_type:
		AbilityData.TargetType.ALL_ALLIES:
			return living(party_actors)
		AbilityData.TargetType.ALL_ENEMIES:
			return living(enemy_actors)
		_:  return [target]

func heal(actor : Actor, target : Actor, ability : AbilityData) -> void:
	var targets : Array[Actor] = get_target(target, ability)
	for _target in targets:
		_target.character.hp -= ability.heal_multiplier * actor.character.mysticism
		_target.spawn_damage_label(ability.heal, Color.GREEN)

func status(actor : Actor, target : Actor, ability : AbilityData) -> void:
	var targets : Array[Actor] = get_target(target, ability)
	for _target in targets:
		match ability.effect_delta:
			AbilityData.EffectDelta.MAX:
				_target.status_effect[ability.status_effect] = 3
			AbilityData.EffectDelta.MIN:
				_target.status_effect[ability.status_effect] = 0
			AbilityData.EffectDelta.INCREMENT:
				if _target.status_effect[ability.status_effect] < 3:
					_target.status_effect[ability.status_effect] += 1
			AbilityData.EffectDelta.DECREMENT:
				if _target.status_effect[ability.status_effect] > -3:
					_target.status_effect[ability.status_effect] -= 1
		_target.update_status()

func special(target : Actor, ability : AbilityData) -> void:
	var targets : Array[Actor] = get_target(target, ability)
	for _target in targets:
		_target.special_effect[ability.special_effect] = ability.special_length

func perform_ability(actor : Actor, target : Actor, ability : AbilityData) -> void:
	if ability.cost_type == AbilityData.CostType.HP:
		actor.character.hp -= ability.cost_amount
		actor.spawn_damage_label(ability.cost_amount, Color.RED)
	elif ability.cost_type == AbilityData.CostType.MP:
		actor.character.mp -= ability.cost_amount
	await actor.play_animation(ability.animation_name)
	match ability.effect_type:
		AbilityData.EffectType.DAMAGE:
			damage(actor, target, ability)
		AbilityData.EffectType.HEAL:
			heal(actor, target, ability)
		AbilityData.EffectType.STATUS:
			status(actor, target, ability)
		AbilityData.EffectType.SPECIAL:
			special(target, ability)
		AbilityData.EffectType.DAMAGE_STATUS:
			damage(actor, target, ability)
			status(actor, target, ability)

func refresh_actor_states() -> void:
	for actor in party_actors + enemy_actors:
		actor.update_visual_state()

func living(input : Array[Actor]) -> Array[Actor]:
	var arr : Array[Actor] = []
	for actor in input:
		if not actor.is_dead():
			arr.append(actor)
	return arr

func all_dead(actors : Array[Actor]) -> bool:
	for actor in actors:
		if actor.character.hp > 0:
			return false
	return true

func reset_round_states() -> void:
	var targets : Array[Actor] = living(party_actors)
	herd = targets[game_state.rng.randi() % targets.size()]
	for actor in party_actors + enemy_actors:
		actor.is_defending = false
