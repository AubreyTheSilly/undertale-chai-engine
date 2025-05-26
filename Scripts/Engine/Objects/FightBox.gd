extends Node2D

func _attack(enemydata : EnemyData) -> int:
	var side = randi_range(0,1)
	$AnimatedSprite2D.position.x = 6.5+(275*side)
	create_tween().tween_property($Sprite2D,"scale:x",0.5,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property($Sprite2D,"modulate:a",1,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property($AnimatedSprite2D,"modulate:a",1,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var attacked = false
	var perfect = 144.0
	while Input.is_action_just_pressed("Select"):
		await get_tree().process_frame
	if side == 0:
		while $AnimatedSprite2D.position.x != 281.5 and !Input.is_action_just_pressed("Select"):
			$AnimatedSprite2D.position.x += 5
			await get_tree().process_frame
		if $AnimatedSprite2D.position.x != 281.5:
			attacked = true
	else:
		while $AnimatedSprite2D.position.x != 6.5 and !Input.is_action_just_pressed("Select"):
			$AnimatedSprite2D.position.x -= 5
			await get_tree().process_frame
		if $AnimatedSprite2D.position.x != 6.5:
			attacked = true
	if attacked:
		print("successfully attacked")
		var x = $AnimatedSprite2D.position.x
		var bonusfactor = abs(x - perfect)
		var dmg := 0
		dmg += randi_range(0,2)
		print(bonusfactor)
		if bonusfactor <= 12:
			dmg = round(((PlayerData.ATK+10) - enemydata.DEF + randi_range(0,2)) * 2.2)
		if bonusfactor > 12:
			dmg = round(((PlayerData.ATK+10) - enemydata.DEF + randi_range(0,2)) * (1 - bonusfactor/273) * 2)
		return dmg
	print("miss :(")
	return 0

func _close() -> void:
	create_tween().tween_property($Sprite2D,"scale:x",0.01,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property($Sprite2D,"modulate:a",0,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property($AnimatedSprite2D,"modulate:a",0,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
