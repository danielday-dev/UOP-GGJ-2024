extends Resource
class_name AttackInfo


@export var range : float = 0
@export var speedMulitplier : float = 0
@export var animation : StringName = ""
@export var priority : float = 0
@export var damage : float = 0
@export var hurtboxName : StringName = ""
@export var nextState : EnemyState = EnemyState.Grounded

enum EnemyState{
	Grounded,
	Airborne,
	Attacking,
	Stunned,
	Prone,
}