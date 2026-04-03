class_name CharacterTemplate extends Resource
enum Sound {
	HUMAN,
	ORC,
	GROWL
}
@export var display_name : String = ""
@export var max_hp : int = 100
@export var max_mp : int = 20
@export var hp : int = 0
@export var mp : int = 0
@export var abilities : Array[AbilityData] = []
@export var sound : Sound = Sound.HUMAN
@export var attack : int = 12
@export var defense : int = 4
@export var agility : int = 5
@export var sprite_path : String = ""
@export var animations : Dictionary[String, int] = {}
