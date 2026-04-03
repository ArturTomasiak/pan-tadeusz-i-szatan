extends Node
func intro_fade_in() -> void:
	var fade_rect = get_node_or_null("/root/intro/fade_rect")
	if fade_rect: fade_rect.fade_in(1)
func intro_god_visible() -> void:
	var god = get_node_or_null("/root/intro/god")
	god.visible = true
func after_intro() -> void:
	var god = get_node_or_null("/root/intro/god")
	var satan = get_node_or_null("/root/intro/szatan")
	if god and satan:
		god.queue_free()
		satan.queue_free()
func after_jacek_recruit() -> void:
	var jacek = get_tree().current_scene.get_node_or_null("jacek")
	if jacek:
		game_state.jacek_recruited = true
		if jacek:
			jacek.queue_free()
