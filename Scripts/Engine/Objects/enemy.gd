class_name Enemy
extends Node2D

# enemy data. loaded from a json file
@export var enemy_data : EnemyData
# objects. self explanatory
@onready var sprite = $Sprite2D
@onready var flavorbox = get_parent().get_node("FlavorBox")

# enemy variables
var spare := false
var talking = false

# state of the enemy
enum ENEMY_STATE {DEAD,ALIVE,SPARED}
var state = ENEMY_STATE.ALIVE

# variables for scripts
var vars : Dictionary = {}

# fires when enemy has stopped shaking and/or dies
signal damage_done

# Called when the node enters the scene tree for the first time.
func _ready():
	# setup
	sprite.texture = enemy_data.EnemySprite
	spare = enemy_data.InstantSpare
	$SpeechBubble.bubbleType = enemy_data.BubbleType
	$GPUParticles2D.process_material.set_shader_parameter("sprite",enemy_data.EnemyHurtSprite)
	$HPBar.max_value = enemy_data.HP
	$HPBar.value = enemy_data.HP

func _dust():
	# so long gay bowser
	state = ENEMY_STATE.DEAD
	$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_vaporized.wav")
	$AudioStreamPlayer.play()
	$Sprite2D.visible = false
	$GPUParticles2D.start()

func Shudder():
	# enemy shake
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
	# hide the shit
	$DamageText.visible = false
	$HPBar.visible = false
	if $HPBar.value == 0:
		# the enemy fucking dies
		_dust()
		state = ENEMY_STATE.DEAD
	else:
		# make it not hurt
		sprite.texture = enemy_data.EnemySprite
	damage_done.emit()

func _spare():
	if spare == true:
		state = ENEMY_STATE.SPARED
		modulate.a = 0.5
		sprite.texture = enemy_data.EnemySpareSprite
		$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_vaporized.wav")
		$AudioStreamPlayer.play()

func _damage(damage : float):
	if damage > 0:
		# enemy hurt :(
		$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_laz_c.wav")
		$AudioStreamPlayer.play()
		$AnimatedSprite2D.play()
		await get_tree().create_timer(1.0).timeout
		$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_damage_c.wav")
		$AudioStreamPlayer.play()
		Shudder()
		$DamageText/Label.label_settings.font_color = Color.RED
		$DamageText/Label.text = str(int(damage))
		$DamageText.bounce()
		$HPBar.visible = true
		var ogHP = $HPBar.value
		while $HPBar.value > (ogHP-damage):
			$HPBar.value -= (damage/15)
			await get_tree().process_frame
	else:
		# you missed dumbass
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
		# constant for all enemies
		await flavorbox.StartBattleDialogue(enemy_data.Check)
	else:
		# run script
		if UTScript.new().loadScript("Enemies/"+enemy_data.EnemyName.to_lower()+"/Acts/"+Act+".utscript") == OK:
			var scr = UTScript.new()
			scr.loadScript("Enemies/"+enemy_data.EnemyName.to_lower()+"/Acts/"+Act+".utscript")
			await runScript(scr)
		else:
			await flavorbox.StartBattleDialogue(["* Error!"])

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

func runScript(scr : UTScript):
	var runNext = true
	for i in scr.data:
		if runNext == false:
			if i.name == "end":
				runNext = true
			continue
		match i.name:
			"print":
				var text = ""
				for j in i.parameters:
					text += j+" "
				print(text)
			"dialog":
				await flavorbox.StartBattleDialogue(i.parameters)
			"set":
				if get(i.parameters[0]) != null:
					if i.parameters[1].is_valid_int():
						set(i.parameters[0],int(i.parameters[1]))
					elif i.parameters[1] == "true" and get(i.parameters[0]) is bool:
						set(i.parameters[0],true)
					elif i.parameters[1] == "false" and get(i.parameters[0]) is bool:
						set(i.parameters[0],false)
					else:
						set(i.parameters[0],i.parameters[1])
				else:
					if i.parameters[1].is_valid_int():
						vars[i.parameters[0]] = int(i.parameters[1])
					else:
						vars[i.parameters[0]] = i.parameters[1]
			"add":
				if vars[i.parameters[0]] is int:
					vars[i.parameters[0]] += int(i.parameters[1])
			"if":
				var compare = i.parameters[0]
				if i.flags.has("-not"):
					if !vars.has(compare):
						continue
					if vars[compare] == i.parameters[1]:
						runNext = false
				else:
					if !vars.has(compare):
						runNext = false
						continue
					if vars[compare] != i.parameters[1]:
						runNext = false
			"stop":
				break
