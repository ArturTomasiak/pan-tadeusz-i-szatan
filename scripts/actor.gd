class_name Actor extends Node2D

const growl_lines : int = 5
const human_lines : int = 18
const orc_lines : int = 3

var character: CharacterTemplate
var is_enemy : bool
var is_defending : bool = false

@onready var sprite : AnimatedSprite2D = $sprite
@onready var marker : Marker2D = $marker
@onready var audio : AudioStreamPlayer2D = $audio

func setup(data: CharacterTemplate, enemy: bool) -> void:
	character = data
	is_enemy = enemy
	var frames : SpriteFrames = SpriteFrames.new()
	for animation in data.animations:
		add_animation_from_folder(frames, animation, character.sprite_path + animation, data.animations[animation], 5.0, false)
	sprite.sprite_frames = frames
	sprite.play("idle")

func is_dead() -> bool:
	return character == null or character.hp <= 0

func play_attack_animation() -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")
		await sprite.animation_finished
	sprite.play("idle")

func play_hit_animation() -> void:
	hit_sound()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.2, 0.06)
	tween.tween_property(self, "modulate:a", 1.0, 0.06)
	tween.tween_property(self, "modulate:a", 0.2, 0.06)
	tween.tween_property(self, "modulate:a", 1.0, 0.06)
	await tween.finished

func hit_sound() -> void:
	var i : int
	if character.sound == CharacterTemplate.Sound.HUMAN && !is_enemy: 
		i = game_state.rng.randi_range(0, human_lines)
		audio.stream = load("res://data/combat/human/" + str(i) + ".mp3")
	else: 
		i = game_state.rng.randi_range(0, growl_lines)
		audio.stream = load("res://data/combat/growl/" + str(i) + ".mp3")
	if audio.playing:
		audio.stop()
	audio.play()

func add_animation_from_folder(
	frames : SpriteFrames,
	anim_name : String,
	folder_path : String,
	frame_count : int,
	fps : float = 8.0,
	loop : bool = true
) -> void:
	if not frames.has_animation(anim_name):
		frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, fps)
	frames.set_animation_loop(anim_name, loop)
	for i in range(0, frame_count):
		var texture: Texture2D = load(folder_path + "/" + str(i) + ".png")
		if texture:
			frames.add_frame(anim_name, texture)

func update_visual_state() -> void:
	visible = true
	modulate.a = 0.45 if character.hp <= 0 else 1.0
