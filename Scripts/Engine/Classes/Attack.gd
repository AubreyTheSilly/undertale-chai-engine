class_name Attack
extends Resource

enum AttackMode {once,FrameByFrame}
@export var attack_script : String
@export var boxSize : Vector2
@export var mode : AttackMode = 0
