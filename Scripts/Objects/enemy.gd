class_name Enemy
extends Node2D

@export var enemy_data : EnemyData
@onready var sprite = $Sprite2D
@onready var flavorbox = get_parent().get_node("FlavorBox")

var spareable := false
var talking = false

enum ENEMY_STATE {DEAD,ALIVE,SPARED}
var state = ENEMY_STATE.ALIVE

signal damage_done

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = enemy_data.EnemySprite
	spareable = enemy_data.InstantSpare
	$SpeechBubble.bubbleType = enemy_data.BubbleType
	$GPUParticles2D.process_material.set_shader_parameter("sprite",enemy_data.EnemyHurtSprite)
	$HPBar.max_value = enemy_data.HP
	$HPBar.value = enemy_data.HP

func _dust():
	state = ENEMY_STATE.DEAD
	$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_vaporized.wav")
	$AudioStreamPlayer.play()
	$Sprite2D.visible = false
	$GPUParticles2D.start()

func shudder():
	var shudder = 16
	sprite.texture = enemy_data.EnemyHurtSprite
	while shudder != 0:
		if (shudder < 0):
			shudder = (-((shudder + 2)))
		else:
			shudder = (-shudder)
		sprite.position.x = shudder
		await get_tree().process_frame
		await get_tree().process_frame
	#for i in range(15):
		#await get_tree().process_frame
	$DamageText.visible = false
	$HPBar.visible = false
	if $HPBar.value == 0:
		_dust()
		state = ENEMY_STATE.DEAD
	else:
		sprite.texture = enemy_data.EnemySprite
	damage_done.emit()

func _damage(damage : float):
	if damage > 0:
		$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_laz_c.wav")
		$AudioStreamPlayer.play()
		$AnimatedSprite2D.play()
		await get_tree().create_timer(1.0).timeout
		$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_damage_c.wav")
		$AudioStreamPlayer.play()
		shudder()
		$DamageText/Label.label_settings.font_color = Color.RED
		$DamageText/Label.text = str(int(damage))
		$DamageText.bounce()
		$HPBar.visible = true
		var ogHP = $HPBar.value
		while $HPBar.value > (ogHP-damage):
			$HPBar.value -= (damage/15)
			await get_tree().process_frame
	else:
		$DamageText/Label.label_settings.font_color = Color.GRAY
		$DamageText/Label.text = "MISS"
		$DamageText.bounce()
		var shudder = 16
		while shudder != 0:
			if (shudder < 0):
				shudder = (-((shudder + 2)))
			else:
				shudder = (-shudder)
			await get_tree().process_frame
			await get_tree().process_frame
		$DamageText.visible = false
		damage_done.emit()
		

func act(Act : String) -> void:
	if Act == "Check":
		await flavorbox.StartBattleDialogue(enemy_data.Check)
	if Act == "Talk" and enemy_data.EnemyName == "Dummy":
		await flavorbox.StartBattleDialogue(["* You talk to the DUMMY.[wait 2][speed 3] ...","* It doesn't seem much for[newline]  conversation.","* Dummy will remember that."])

func dialogue() -> void:
	talking = true
	$SpeechBubble.visible = true
	$SpeechBubble/Label.text = ""
	var Dialogue = enemy_data.RandomDialogs.pick_random()
	for i in Dialogue:
		match i:
			"&":
				$SpeechBubble/Label.text += "\n"
			_:
				$SpeechBubble/Label.text += i
				if i != " ":
					$AudioStreamPlayer2.play()
		await get_tree().process_frame
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	$SpeechBubble.visible = false
	talking = false
