extends Node
const intro : String = "res://scenes/maps/intro.tscn"
@onready var main_panel     : Control = $main
@onready var settings_panel : Control = $settings
@onready var new_game : Button = $main/new
@onready var load     : Button = $main/load
@onready var settings : Button = $main/settings
@onready var exit     : Button = $main/exit
@onready var back     : Button = $settings/back
@onready var fson     : TextureButton = $settings/fson
@onready var fsoff    : TextureButton = $settings/fsoff
@onready var volume   : HSlider = $settings/volume
func _ready() -> void:
	settings_panel.visible = false
	fson.visible          = false
	new_game.grab_focus()
	new_game.pressed.connect(on_new_game)
	load.pressed.connect(on_load)
	settings.pressed.connect(on_settings)
	exit.pressed.connect(on_exit)
	back.pressed.connect(on_back)
	fson.pressed.connect(on_fson)
	fsoff.pressed.connect(on_fsoff)
	volume.value_changed.connect(on_volume_changed)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event : InputEvent):
	if event is InputEventMouse:
		get_viewport().set_input_as_handled()

func on_new_game() -> void:
	get_tree().change_scene_to_file(intro)

func on_load() -> void:
	print("TODO")

func on_settings() -> void:
	main_panel.visible = false
	settings_panel.visible = true
	back.grab_focus()

func on_exit() -> void:
	get_tree().quit()
	
func on_back() -> void:
	main_panel.visible = true
	settings_panel.visible = false
	new_game.grab_focus()
	
func on_fson() -> void:
	fson.visible = false
	fsoff.visible = true
	fsoff.grab_focus()
	get_window().mode = Window.MODE_WINDOWED

func on_fsoff() -> void:
	fson.visible = true
	fsoff.visible = false
	fson.grab_focus()
	get_window().mode = Window.MODE_FULLSCREEN

func on_volume_changed(value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index("Master")
	if value <= 0.0:
		AudioServer.set_bus_mute(bus_index, true)
		return
	AudioServer.set_bus_mute(bus_index, false)
	var db: float = lerp(-20.0, 20.0, value / 100.0)
	AudioServer.set_bus_volume_db(bus_index, db)
