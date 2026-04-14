class_name CharacterTemplate extends Resource
enum Sound {
	HUMAN,
	ORC,
	GROWL
}
enum Targeting {
	HERD,          # every HERD chooses a target together, seperate from HERD_FOCUS
	FOCUS,         # pick one till they die 
	RANDOM,        # pick at random
	HERD_FOCUS     # HERD till target dies
}
@export var vitality : int = 9
@export var strength : int = 9
@export var intelligence : int = 9
@export var mysticism : int = 9
@export var defense : int = 9
@export var agility : int = 9
@export var display_name : String = ""
@export var abilities : Array[AbilityData] = []
@export var sound : Sound = Sound.HUMAN
@export var sprite_path : String = ""
@export var animations : Dictionary[String, int] = {}
@export var targeting : Targeting = Targeting.RANDOM
var max_hp : int:
	get:
		return vitality * vitality + 10
var max_mp : int:
	get:
		return intelligence * 5 + 10
var hp : int = max_hp
var mp : int = max_mp
var exp : int = 0
var lvl : int = 1
var next_lvl : int = 300
var next_lvl_formula : float = 1.5
