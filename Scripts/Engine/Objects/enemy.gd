class_name Enemy
extends Node2D

# enemy data. loaded from a json file
@export var enemy_data : EnemyData
# objects. self explanatory
@onready var sprite = $Sprite2D
@onready var flavorbox = get_parent().get_node("FlavorBox")
@onready var scr : ScriptRunner = $ScriptRunner

# generic variables. can be altered and accessed via scripts
var spare := false
var talking := false
var nextdialogue := ""
var frame := 0
var damaging = false
var nextattack := ""

# important variables related to scripts
var hasUpdateScript := false

# state of the enemy
enum ENEMY_STATE {DEAD,ALIVE,SPARED}
var state = ENEMY_STATE.ALIVE

# variables for scripts
var vars : Dictionary = {}

# fires when enemy has stopped shaking and/or dies
signal damage_done
# fired by battle scene
signal next

# Called when the node enters the scene tree for the first time.
func _ready():
	scr.persistentVars["damaging"] = UMVar.new()
	scr.persistentVars["damaging"].type = Token.TokenType.TYPE_BOOL
	# setup
	position += enemy_data.offset
	$SpeechBubble.pos = enemy_data.BubbleOffset
	spare = enemy_data.InstantSpare
	$SpeechBubble.bubbleType = enemy_data.BubbleType
	$GPUParticles2D.process_material.set_shader_parameter("sprite",enemy_data.EnemyHurtSprite)
	var sprite_size = $GPUParticles2D.process_material.get_shader_parameter("sprite").get_size()
	$GPUParticles2D.position = -(sprite_size/2)
	$GPUParticles2D.amount = (sprite_size.x*sprite_size.y)
	$HPBar.max_value = enemy_data.HP
	$HPBar.value = enemy_data.HP
	if UTScript.loadScriptFromFile("Enemies/"+enemy_data.name+"/Create.utscript"):
		scr.script_to_run = "Enemies/"+enemy_data.name+"/Create.utscript"
		await scr.run_script()
	if UTScript.loadScriptFromFile("Enemies/"+enemy_data.name+"/Update.utscript"):
		hasUpdateScript = true

func getAttack() -> String:
	return "Enemies/"+enemy_data.name+"/Attacks/"+enemy_data.Attacks.pick_random()+".utscript"

func _dust():
	# so long gay bowser
	state = ENEMY_STATE.DEAD
	$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_vaporized.wav")
	$AudioStreamPlayer.play()
	$Sprite2D.visible = false
	$GPUParticles2D.start()

func Shudder():
	# enemy shake
	damaging = true
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
	else:
		# make it not hurt
		sprite.texture = enemy_data.EnemySprite
	damaging = false
	damage_done.emit()

func _spare():
	if spare == true:
		state = ENEMY_STATE.SPARED
		if hasUpdateScript:
			scr.script_to_run = "Enemies/"+enemy_data.name+"/Update.utscript"
			scr.run_script()
		modulate.a = 0.5
		sprite.texture = enemy_data.EnemySpareSprite
		for i in range(14):
			var cloud = preload("res://Scenes/Objects/dustcloud.tscn").instantiate()
			add_child(cloud)
		$AudioStreamPlayer.stream = preload("res://Audio/Sounds/snd_vaporized.wav")
		$AudioStreamPlayer.play()

func _damage(damage : float):
	if damage >= 0:
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
		if UTScript.loadScriptFromFile("Enemies/"+enemy_data.name+"/Acts/"+Act+".utscript"):
			scr.script_to_run = "Enemies/"+enemy_data.name+"/Acts/"+Act+".utscript"
			await scr.run_script()
		else:
			# uh oh!
			await flavorbox.StartBattleDialogue(["* Error!"])

func dialogue() -> void:
	talking = true
	$SpeechBubble.visible = true
	var Dialogue = enemy_data.RandomDialogs.pick_random()
	$AudioStreamPlayer2.stream = Loader.load_file("Audio/Sounds/snd_TXT2.wav")
	talking = true
	$SpeechBubble/TextObject.text = "[color:0:0:0]"
	if nextdialogue != "":
		Dialogue = nextdialogue
		nextdialogue = ""
	
	if Dialogue == "":
		$SpeechBubble.visible = false
		talking = false
		return
	
	var cmd = false
	var command = ""
	for i in Dialogue:
		match i:
			"[":
				cmd = true
				command = ""
			"]":
				cmd = false
				var cmand = command.split(":",false)
				match cmand[0]:
					"wait":
						for k in range(int(cmand[1])):
							await get_tree().process_frame
					"sound":
						$AudioStreamPlayer2.stream = Loader.load_file("Audio/Sounds/"+cmand[1]+".wav")
					_:
						$SpeechBubble/TextObject.text += "["+command+"]"
			_:
				if cmd:
					command += i
				else:
					$SpeechBubble/TextObject.text += i
					if i != " ":
						$AudioStreamPlayer2.play()
					await get_tree().process_frame
					await get_tree().process_frame
	if enemy_data.autodialog:
		await get_tree().create_timer(0.5).timeout
	else:
		while !Input.is_action_just_pressed("Select"):
			await get_tree().process_frame
	$SpeechBubble.visible = false
	talking = false

func _process(_delta):
	scr.persistentVars["damaging"].value = damaging
	
	frame += 1
	if hasUpdateScript and state == 1:
		scr.script_to_run = "Enemies/"+enemy_data.name+"/Update.utscript"
		scr.run_script()
	if damaging:
		sprite.texture = enemy_data.EnemyHurtSprite
	elif state == 2:
		sprite.texture = enemy_data.EnemySpareSprite
	else:
		sprite.texture = enemy_data.EnemySprite
