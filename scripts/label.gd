extends Label
func show_value(value : int, world_pos : Vector2) -> void:
	var text : String = str(value)
	global_position = world_pos
	var tween : Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position:y", global_position.y - 24, 0.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()
