class_name AbilityData extends Resource
enum CostType {
	NONE,
	MP,
	HP
}
enum TargetType {
	SELF,
	SINGLE_ALLY,
	SINGLE_ENEMY,
	ALL_ALLIES,
	ALL_ENEMIES,
	RANDOM
}
enum AbilityType {
	MAGIC,
	PHYSICAL
}
enum EffectType {
	DAMAGE,
	HEAL,
	STATUS,
	SPECIAL,
	DAMAGE_STATUS
}
enum StatusEffect {
	NONE,
	DEFENCE,
	MAGIC,
	PHYS
}
enum EffectDelta {
	INCREMENT,
	DECREMENT,
	MAX,
	MIN
}
enum SpecialEffect {
	NONE,
	SLEEP,
	NO_SLEEP,
	NO_MAGIC,
	COVER
}
@export_group("General")
@export var ability_type : AbilityType = AbilityType.MAGIC
@export var effect_type : EffectType = EffectType.DAMAGE
@export var display_name : String = ""
@export_multiline var description : String = ""
@export var animation_name : String = ""
@export var cost_type : CostType = CostType.MP
@export var cost_amount : int = 0
@export var target_type : TargetType = TargetType.SINGLE_ENEMY
@export_group("Damage")
@export var repetition_from : int = 1
@export var repetition_to : int = 1
@export var damage_multiplier : float = 1
@export_group("Heal")
@export var heal_multiplier : float = 1
@export_group("Status")
@export var status_effect : StatusEffect = StatusEffect.NONE
@export var effect_delta  : EffectDelta  = EffectDelta.INCREMENT
@export_group("Special")
@export var special_effect : SpecialEffect = SpecialEffect.NONE
@export var special_length : int = 3
