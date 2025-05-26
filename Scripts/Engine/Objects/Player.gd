extends Character

func _process(_delta) -> void:
	var can_move = !DialogueHandler.visible and Undermaker.player_can_move
	if can_move:
		velocity = Vector2(Input.get_axis("Move Left","Move Right"),Input.get_axis("Move Up","Move Down"))*(30*Speed)
	handleAnimation(velocity/(30*Speed))
	move_and_slide()
