extends Control

signal action_selected(action_data : Dictionary)

@onready var party_panel   : VBoxContainer  = $c/h/p2/party
@onready var action_panel  : VBoxContainer  = $c/h/p1/action
@onready var ability_panel : HFlowContainer = $c/h/p1/abilities
@onready var target_node   : Control = $target
@onready var attack    : Button = $c/h/p1/action/attack
@onready var abilities : Button = $c/h/p1/action/abilities
@onready var defend    : Button = $c/h/p1/action/defend

var party   : Array[Actor] = []
var enemies : Array[Actor] = []
var current : Actor

func _ready() -> void:
	attack.pressed.connect(on_attack_pressed)
	abilities.pressed.connect(on_abilities_pressed)
	defend.pressed.connect(defend_logic)
	action_panel.hide()
	target_node.hide()
	ability_panel.hide()

func on_attack_pressed() -> void:
	action_panel.hide()
	show_targets()

func on_abilities_pressed() -> void:
	action_panel.hide()
	show_abilities()

func defend_logic() -> void:
	action_panel.hide()
	target_node.hide()
	action_selected.emit({
		"type": "defend"
	})

func set_ui(_party : Array[Actor], _enemies) -> void:
	enemies = _enemies
	party   = _party
	_rebuild_party_panel()

func _rebuild_party_panel() -> void:
	for child in party_panel.get_children():
		child.queue_free()

	for member in party:
		var data : CharacterTemplate = member.character
		var label : Label = Label.new()
		label.name = data.display_name
		party_panel.add_child(label)

func update_party_status(active_character : CharacterTemplate = null) -> void:
	for i in party_panel.get_child_count():
		var label  : Label = party_panel.get_child(i)
		var member : CharacterTemplate = party[i].character
		var name_text := member.display_name
		if member == active_character:
			label.add_theme_color_override("font_color", Color.YELLOW)
		label.text = "%s  HP %d/%d  MP %d/%d" % [
			name_text,
			member.hp,
			member.max_hp,
			member.mp,
			member.max_mp
		]

func choose_player_action(current_character : Actor) -> Dictionary:
	current = current_character 
	action_panel.show()
	target_node.hide()
	attack.grab_focus()
	return await action_selected

func _returnbtn() -> void:
	ability_panel.hide()
	action_panel.show()
	attack.call_deferred("grab_focus")

func show_abilities() -> void:
	for child in ability_panel.get_children():
		child.queue_free()
	var return_button : Button = Button.new()
	return_button.text = "wróć"
	return_button.pressed.connect(_returnbtn)
	ability_panel.add_child(return_button)
	for ability in current.character.abilities:
		var usable : bool = true
		var amount : int
		if ability.ability_type == AbilityData.AbilityType.MAGIC:
			if current.special_effect[AbilityData.SpecialEffect.NO_MAGIC] != 0:
				usable = false
		if   ability.cost_type == AbilityData.CostType.MP: amount = current.character.mp
		elif ability.cost_type == AbilityData.CostType.HP: amount = current.character.hp
		if ability.cost_amount > amount: usable = false
		var button : Button = Button.new()
		button.text = ability.display_name
		if !usable: button.disabled = true
		button.pressed.connect(func():
			show_targets(ability)
		)
		ability_panel.add_child(button)
	ability_panel.show()
	return_button.call_deferred("grab_focus")

func show_targets(ability : AbilityData = null) -> void:
	for child in target_node.get_children():
		child.queue_free()
	var buttons : Array[Button] = []
	var targets : Array[Actor]
	var type    : String
	if ability != null:
		type = "ability"
		match (ability.target_type):
			AbilityData.TargetType.SINGLE_ENEMY:
				targets = enemies
			AbilityData.TargetType.SINGLE_ALLY:
				targets = party
			_:
				ability_panel.hide()
				action_panel.hide()
				target_node.hide()
				action_selected.emit({
					"type": type,
					"target": null,
					"ability": ability
				})
				return
	else: 
		targets = enemies
		type    = "attack"
	for target in targets:
		if target.is_dead():
			continue
		var button : Button = Button.new()
		button.text = target.character.display_name
		button.pressed.connect(func():
			ability_panel.hide()
			action_panel.hide()
			target_node.hide()
			action_selected.emit({
				"type": type,
				"target": target,
				"ability": ability
			})
		)
		target_node.add_child(button)
		var marker : Marker2D = target.get_node("name_marker")
		var screen_pos : Vector2 = marker.get_global_transform_with_canvas().origin
		var local_pos  : Vector2 = target_node.get_global_transform_with_canvas().affine_inverse() * screen_pos
		button.position = local_pos - Vector2(button.size.x * 0.5, button.size.y)
		buttons.append(button)
	if buttons.is_empty():return
	target_node.show()
	buttons[0].call_deferred("grab_focus")
