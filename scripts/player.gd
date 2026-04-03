class_name Player extends CharacterBody2D
const speed : float = 60.0
var last_facing : Vector2
const esc : PackedScene = preload("res://scenes/ui/esc.tscn")
var esc_instance : Control = null
@export var active : bool = true
@onready var sprite : AnimatedSprite2D = $sprite
@onready var raycast : RayCast2D       = $raycast
var parent : Node2D
const direction: Dictionary[String, Vector2] = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN,
}
func _ready():
	add_to_group("player")
func _physics_process(_delta: float) -> void:
	if not active or esc_instance: return
	process_movement()
	move_and_slide()
	parent = get_node("..")
	if !parent.safe: 
		parent.handle_random_encounters()

func process_movement() -> void:
	var chosen_action : String = ""
	for action in direction:
		if Input.is_action_pressed(action):
			chosen_action = action
			break
	if chosen_action == "":
		velocity = Vector2.ZERO
		sprite.stop()
	else:
		last_facing = direction[chosen_action]
		velocity = last_facing * speed
		sprite.play(chosen_action)

func _input(event : InputEvent) -> void:
	if event is InputEventMouse:
		get_viewport().set_input_as_handled()
	if not active: return
	if event.is_action_pressed("esc"):
		handle_esc()
	if esc_instance: return
	if event.is_action_pressed("ui_accept"):
		try_interact()

func handle_esc() -> void:
	if esc_instance:
		esc_instance.queue_free()
		esc_instance = null
	else:
		sprite.stop()
		esc_instance = esc.instantiate()
		get_tree().get_root().add_child(esc_instance)
		esc_instance.global_position = get_viewport().get_camera_2d().global_position - Vector2(145, 88)

func try_interact() -> void:
	raycast.target_position = last_facing * 20.0
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider := raycast.get_collider()
		if collider and collider.has_method("interact"):
			sprite.stop()
			collider.interact(self)
