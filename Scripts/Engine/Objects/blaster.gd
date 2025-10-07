extends Node2D

@export_enum("White","Blue","Orange","Green") var attack_type : String = "White"
@export var damage := 1

func _ready():
	$AnimatedSprite2D.position.y -= 560
	await create_tween().tween_property($AnimatedSprite2D,"position:y",0,1.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).finished
	$AnimatedSprite2D.play("ready")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("fire")
	$AudioStreamPlayer2.play()
	$Sprite2D.visible = true
	$attack/CollisionShape2D.disabled = false
	create_tween().tween_property($Sprite2D,"scale:x",3,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property($attack,"scale:x",3,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await create_tween().tween_property($Sprite2D,"modulate:a",1,0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).finished
	create_tween().tween_property($Sprite2D,"scale:x",0,0.75).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property($attack,"scale:x",0,0.75).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property($AnimatedSprite2D,"position:y",-560,1.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property($Sprite2D,"modulate:a",0,0.75).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(0.5).timeout
	$attack/CollisionShape2D.disabled = true
	await get_tree().create_timer(0.25).timeout
	await $AudioStreamPlayer2.finished
	queue_free()

func _process(_delta):
	$Sprite2D.position = $AnimatedSprite2D.position
	
	match attack_type.to_lower():
		"blue":
			modulate = Color(0.251,1,1)
		"orange":
			modulate = Color(1,0.65,0)
		"green":
			modulate = Color(0,1,0)
		_:
			modulate = Color(1,1,1)
