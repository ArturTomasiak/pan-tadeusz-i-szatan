extends ColorRect
var tween : Tween
func fade_in(time) -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0.0, time)
	await tween.finished
func fade_out(time) -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1.0, time)
	await tween.finished
