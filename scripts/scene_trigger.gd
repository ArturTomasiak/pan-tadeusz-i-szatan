class_name SceneTrigger extends Area2D
@export var connected_scene : String
@onready var fade_rect : ColorRect     = $"../fade_rect"
func _ready():
	body_entered.connect(_on_body_entered)
func _on_body_entered(body):
	if body is Player:
		await fade_rect.fade_out(0.3)
		scene_manager.change_scene(get_owner(), connected_scene)
