extends Control

signal action_selected(action_data: Dictionary)

@onready var party_panel  : VBoxContainer = $vh/t2/party
@onready var action_panel : VBoxContainer = $vh/t1/action
@onready var target    : Control = $target
@onready var attack    : Button = $vh/t1/action/attack
@onready var abilities : Button = $vh/t1/action/abilities
@onready var defend    : Button = $vh/t1/action/defend

var party_data: Array[CharacterTemplate] = []
var current_target_actors: Array = []

func _ready() -> void:
	attack.pressed.connect(on_attack_pressed)
	defend.pressed.connect(on_defend_pressed)
	abilities.disabled = true
	action_panel.hide()
	target.hide()

func on_attack_pressed() -> void:
	action_panel.hide()
	show_targets()

func on_defend_pressed() -> void:
	action_panel.hide()
	target.hide()
	action_selected.emit({
		"type": "defend"
	})

func set_party(party : Array[CharacterTemplate]) -> void:
	party_data = party
	_rebuild_party_panel()

func _rebuild_party_panel() -> void:
	for child in party_panel.get_children():
		child.queue_free()

	for member in party_data:
		var label : Label = Label.new()
		label.name = member.display_name
		party_panel.add_child(label)

func update_party_status(active_character: CharacterTemplate = null) -> void:
	for i in party_panel.get_child_count():
		var label: Label = party_panel.get_child(i)
		var member: CharacterTemplate = party_data[i]
		var name_text := member.display_name
		if member == active_character:
			name_text = "obecny: %s" % name_text
		label.text = "%s  HP %d/%d  MP %d/%d" % [
			name_text,
			member.hp,
			member.max_hp,
			member.mp,
			member.max_mp
		]

func choose_player_action(_character: CharacterTemplate, enemy_actors: Array) -> Dictionary:
	current_target_actors = enemy_actors
	action_panel.show()
	target.hide()
	attack.grab_focus()
	return await action_selected

func show_targets() -> void:
	target.show()
	for child in target.get_children():
		child.queue_free()
	var buttons: Array[Button] = []
	for enemy_actor in current_target_actors:
		if enemy_actor.is_dead():
			continue
		var button : Button = Button.new()
		button.text = enemy_actor.character.display_name
		button.custom_minimum_size = Vector2(120, 32)
		button.focus_mode = Control.FOCUS_ALL

		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = Color(1, 1, 0, 0.4)
		button.add_theme_stylebox_override("hover", hover_style)

		button.pressed.connect(func():
			action_panel.hide()
			target.hide()
			action_selected.emit({
				"type": "attack",
				"target": enemy_actor
			})
		)

		target.add_child(button)
		print(str(enemy_actor.position.x), str(enemy_actor.position.y))
		button.position = enemy_actor.position + Vector2(260, 155)
		buttons.append(button)

	for i in range(buttons.size()):
		var button := buttons[i]

		if i > 0:
			button.focus_neighbor_left = button.get_path_to(buttons[i - 1])
		if i < buttons.size() - 1:
			button.focus_neighbor_right = button.get_path_to(buttons[i + 1])

	if buttons.size() > 0:
		buttons[0].call_deferred("grab_focus")
