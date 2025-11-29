extends CanvasLayer

signal done

func _ready():
	if PlayerData.obj:
		$PlayerSprite.global_position = PlayerData.obj.position
		$Heart.global_position = PlayerData.obj.position
		var dir = PlayerData.obj.direction
		dir[0] = dir[0].to_upper()
		$PlayerSprite.texture = PlayerData.obj.Character_Sprite.get("Idle"+dir)
	for i in range(3):
		$PlayerSprite.visible = true
		$AudioStreamPlayer.play()
		await get_tree().process_frame
		await get_tree().process_frame
		$PlayerSprite.visible = false
		await get_tree().process_frame
		await get_tree().process_frame
	$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_battlefall.wav")
	$AudioStreamPlayer.play()
	await create_tween().tween_property($Heart,"global_position",Vector2(23.5,227),0.5).set_ease(Tween.EASE_IN_OUT).set_ease(Tween.EASE_IN_OUT).finished
	await fader.fadeOut()
	get_tree().change_scene_to_packed(preload("res://Scenes/Battle.tscn"))
	queue_free()
