class_name AbilityData extends Resource
enum CostType {
	MP,
	HP
}
enum TargetType {
	SELF,
	SINGLE_ALLY,
	SINGLE_ENEMY,
	ALL_ALLIES,
	ALL_ENEMIES
}
@export var display_name : String = ""
@export_multiline var description : String = ""
@export var cost_type : CostType = CostType.MP
@export var cost_amount : int = 0
@export var power : int = 10
@export var target_type : TargetType = TargetType.SINGLE_ENEMY
@export var can_target_dead : bool = false
@export var hp_delta : int = 0
@export var mp_delta : int = 0
