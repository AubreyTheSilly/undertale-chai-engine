extends CharacterBody2D

@onready var battle = get_parent()
const SPEED := 2

func _process(_delta) -> void:
	velocity = Vector2.ZERO
	match battle.state:
		battle.ENEMY_DIALOGUE:
			visible = true
			position = Vector2(159.5,159.75)
		battle.ENEMY_ATTACK:
			visible = true
			match battle.soulMode:
				Battle.SOULMODES.RED:
					velocity = Input.get_vector("Move Left","Move Right","Move Up","Move Down")*(30*SPEED)
		_:
			visible = false
	move_and_slide()
