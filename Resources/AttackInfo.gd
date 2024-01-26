extends Resource
class_name AttackInfo


@export var range : float = 0
@export var speedMulitplier : float = 0
@export var animation : StringName = ""
@export var priority : float = 0
@export var hurtboxName : NodePath = ""
@export var nextState : EnemyState = EnemyState.Grounded

@export var anticipate : bool = false;
@export var cooldown : bool = false;

enum EnemyState{
	Grounded,
	Airborne,
	Attacking,
	Stunned,
	Prone,
}
