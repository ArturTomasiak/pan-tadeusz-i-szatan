class_name Actor extends Node2D

const growl_lines : int = 4
const human_lines : int = 9
const orc_lines : int = 3
var status_effect  : Array[int] = []
var special_effect : Array[int] = []

var character: CharacterTemplate
var is_enemy : bool
var is_defending : bool = false
var target : Actor = null

@onready var sprite : AnimatedSprite2D = $sprite
@onready var audio : AudioStreamPlayer2D = $audio
@onready var damage : Label = $damage
@onready var status : HBoxContainer = $status
var damage_tween : Tween

func setup(data: CharacterTemplate, enemy: bool) -> void:
	status_effect.resize(AbilityData.StatusEffect.size())
	special_effect.resize(AbilityData.SpecialEffect.size())
	for entry in AbilityData.StatusEffect.values():
		status_effect[entry] = 0
	for entry in AbilityData.SpecialEffect.values():
		special_effect[entry] = 0
	character = data
	is_enemy = enemy
	var frames : SpriteFrames = SpriteFrames.new()
	for animation in data.animations:
		add_animation_from_folder(frames, animation, character.sprite_path + animation, data.animations[animation], 5.0, false)
	sprite.sprite_frames = frames
	sprite.play("idle")

func can_use_ability(ability : AbilityData) -> bool:
	var amount : int
	if ability.ability_type == AbilityData.AbilityType.MAGIC and special_effect[AbilityData.SpecialEffect.NO_MAGIC] != 0:
		return false
	if   ability.cost_type == AbilityData.CostType.MP: amount = character.mp
	elif ability.cost_type == AbilityData.CostType.HP: amount = character.hp
	return ability.cost_amount < amount

func is_dead() -> bool:
	return character == null or character.hp <= 0

func play_animation(_name : String = "") -> void:
	if _name != "" and sprite.sprite_frames.has_animation(_name):
		sprite.play(_name)
		await sprite.animation_finished 
	elif sprite.sprite_frames.has_animation("attack"):
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
	match character.sound:
		CharacterTemplate.Sound.HUMAN:
			if !is_enemy:
				i = game_state.rng.randi_range(0, human_lines)
				audio.stream = load("res://data/combat/human/" + str(i) + ".mp3")
		CharacterTemplate.Sound.GROWL:
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
 
func _add_status_icon(path : String) -> void:
	if !ResourceLoader.exists(path): return
	var rect := TextureRect.new()
	rect.texture = load(path)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.custom_minimum_size = Vector2(8, 8)
	status.add_child(rect)

func update_status() -> void:
	for child in status.get_children():
		child.queue_free()
	for effect_index in range(status_effect.size()):
		var level : int = status_effect[effect_index]
		if level != 0:
			var path : String = "res://data/icons/effect/" + str(effect_index) + "/" + str(level) + ".png"
			_add_status_icon(path)
	for effect_index in range(special_effect.size()):
		if special_effect[effect_index] != 0:
			var path : String = "res://data/icons/special/" + str(effect_index) + ".png"
			if path != "":
				_add_status_icon(path)
	status.visible = status.get_child_count() > 0

func spawn_damage_label(dmg: int, color : Color) -> void:
	damage.modulate.a = 0.0
	damage.position = get_node("damage_pos" + str(game_state.rng.randi_range(1, 3))).position
	damage.text = str(dmg)
	damage.add_theme_color_override("font_color", color)
	if damage_tween:
		damage_tween.kill()
	damage_tween = damage.create_tween()
	damage_tween.tween_property(damage, "modulate:a", 1.0, 0.12)
	damage_tween.tween_interval(0.2)
	damage_tween.tween_property(damage, "position:y", -30.0, 0.6)
	damage_tween.parallel().tween_property(damage, "modulate:a", 0.0, 0.6)
	await damage_tween.finished
