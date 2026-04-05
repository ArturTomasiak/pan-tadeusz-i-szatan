class_name Location extends Node
var last_scene : String
var safe : bool = false
@onready var entrance_marker : Node2D = $entrance_marker
@onready var fade_rect : ColorRect    = $fade_rect
@onready var player : Player          = get_node_or_null("player")
const music : PackedScene = preload("res://scenes/misc/overworld.tscn")

var distance_accumulation: float = 0.0
var last_player_pos: Vector2 = Vector2(0,0)

func _ready():
	fade_rect.fade_in(0.3)
	if scene_manager.player:
		if player:
			player.queue_free()
		player = scene_manager.player
		add_child(player)
	if not has_node("Camera2D"):
		add_camera()
	position_player()
	add_child(music.instantiate())

func position_player() -> void:
	if game_state.return_scene_path == scene_file_path and game_state.return_position != Vector2.ZERO:
		player.global_position = game_state.return_position
		game_state.return_position = Vector2.ZERO
		return
	last_scene = scene_manager.last_scene
	for entrance in entrance_marker.get_children():
		if entrance is Marker2D and entrance.name == last_scene:
			player.global_position = entrance.global_position

func add_camera() -> void:
	var camera = Camera2D.new()
	player.add_child(camera)
	camera.enabled = true
	camera.position = Vector2.ZERO

func handle_random_encounters() -> void:
	if last_player_pos == Vector2(0,0):
		last_player_pos = player.global_position
		return
	const treshold : float = 30
	var moved : float = player.global_position.distance_to(last_player_pos)
	last_player_pos = player.global_position
	if moved <= 0.0:
		return
	distance_accumulation += moved
	while distance_accumulation >= treshold:
		distance_accumulation -= treshold
		if game_state.rng.randf() < 0.10:
			trigger_random_battle()
			return

var encounters = [
	[
		game_state.mage
	] as Array[CharacterTemplate],
	[
		game_state.strzyga
	] as Array[CharacterTemplate],
	[
		game_state.mage,
		game_state.mage
	] as Array[CharacterTemplate],
	[
		game_state.mage,
		game_state.strzyga
	] as Array[CharacterTemplate],
]

func trigger_random_battle() -> void:
	var enemies : Array[CharacterTemplate] = encounters[game_state.rng.randi_range(0, encounters.size() - 1)]
	game_state.start_battle(self, enemies)
