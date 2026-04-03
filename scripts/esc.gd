extends Control

@onready var inventory : Button = $topbar/HBoxContainer/inventory
@onready var abilities : Button = $topbar/HBoxContainer/abilities
@onready var save      : Button = $topbar/HBoxContainer/save
@onready var load      : Button = $topbar/HBoxContainer/load
@onready var settings  : Button = $topbar/HBoxContainer/settings
@onready var quit      : Button = $topbar/HBoxContainer/quit

func _ready() -> void:
	inventory.grab_focus()
	inventory.pressed.connect(on_inventory)
	abilities.pressed.connect(on_abilities)
	save.pressed.connect(on_save)
	load.pressed.connect(on_load)
	settings.pressed.connect(on_settings)
	quit.pressed.connect(on_quit)

func on_inventory() -> void:
	print("todo")

func on_abilities() -> void:
	print("todo")

func on_save() -> void:
	print("todo")

func on_load() -> void:
	print("todo")

func on_settings() -> void:
	print("todo")

func on_quit() -> void:
	get_tree().quit()
