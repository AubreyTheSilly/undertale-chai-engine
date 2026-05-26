extends Node2D

@export_enum("White","Blue","Orange","Green") var attack_type : String = "White"
@export var damage := 1
@export var kr_damage := 10

var transition : Tween.TransitionType = Tween.TRANS_QUAD

func _ready():
	$AudioStreamPlayer.play()
	$AnimatedSprite2D.position.y -= 560
	await create_tween().tween_property($AnimatedSprite2D,"position:y",0,1.1).set_ease(Tween.EASE_OUT).set_trans(transition).finished
	$AnimatedSprite2D.play("ready")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("fire")
	$AudioStreamPlayer2.play()
	$Sprite2D.visible = true
	$attack/CollisionShape2D.disabled = false
	#get_tree().current_scene.camerashake = 10
	create_tween().tween_property($AnimatedSprite2D,"position:y",-560,2.5).set_ease(Tween.EASE_OUT).set_trans(transition)
	animate_beam()
	await get_tree().create_timer(0.95).timeout
	$attack/CollisionShape2D.disabled = true
	while $Sprite2D.modulate.a > 0.05 and is_inside_tree():
		await get_tree().process_frame
	await $AudioStreamPlayer2.finished
	queue_free()

func animate_beam():
	create_tween().tween_property($Sprite2D,"scale:x",3,0.5).set_ease(Tween.EASE_OUT).set_trans(transition)
	create_tween().tween_property($attack,"scale:x",3,0.5).set_ease(Tween.EASE_OUT).set_trans(transition)
	await create_tween().tween_property($Sprite2D,"modulate:a",1,0.2).set_ease(Tween.EASE_OUT).set_trans(transition).finished
	create_tween().tween_property($Sprite2D,"modulate:a",0,0.75).set_ease(Tween.EASE_IN).set_trans(transition)
	create_tween().tween_property($Sprite2D,"scale:x",0,0.75).set_ease(Tween.EASE_IN).set_trans(transition)
	create_tween().tween_property($attack,"scale:x",0,0.75).set_ease(Tween.EASE_IN).set_trans(transition)

func _process(_delta):
	$Sprite2D.position = $AnimatedSprite2D.position
	$attack.position = $AnimatedSprite2D.position
	
	match attack_type.to_lower():
		"blue":
			modulate = Color(0.251,1,1)
		"orange":
			modulate = Color(1,0.65,0)
		"green":
			modulate = Color(0,1,0)
		_:
			modulate = Color(1,1,1)
