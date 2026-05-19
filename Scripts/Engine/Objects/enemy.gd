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
var lastchoice := 0

# important variables related to scripts
var hasUpdateScript := false
var hasPreDialogueScript := false
var hasDamageScript := false

var predialogue = false
var ready_for_next_turn = true

var has_hurt_sprite = false

# state of the enemy
enum ENEMY_STATE {DEAD,ALIVE,SPARED}
var state = ENEMY_STATE.ALIVE

# variables for scripts (NOTE: this is a leftover from the old programming system)
var vars : Dictionary = {}

# fires when enemy has stopped shaking and/or dies
signal damage_done
# fired by battle scene (TODO)
#signal next

func _predialogue():
	if hasPreDialogueScript:
		scr.run_script("Enemies/"+enemy_data.name+"/PreDialogue.utscript")

# Called when the node enters the scene tree for the first time.
func _ready():
	scr.persistentVars["damaging"] = UMVar.new()
	scr.persistentVars["damaging"].type = Token.TokenType.TYPE_BOOL
	# setup
	position += enemy_data.offset
	$SpeechBubble.pos = enemy_data.BubbleOffset
	spare = enemy_data.InstantSpare
	$SpeechBubble.bubbleType = enemy_data.BubbleType
	if enemy_data.EnemyHurtSprite:
		has_hurt_sprite = true
	if has_hurt_sprite:
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
	if UTScript.loadScriptFromFile("Enemies/"+enemy_data.name+"/PreDialogue.utscript"):
		hasPreDialogueScript = true
	if UTScript.loadScriptFromFile("Enemies/"+enemy_data.name+"/Damage.utscript"):
		hasDamageScript = true

func getAttack() -> String:
	if nextattack != "":
		var attack = nextattack
		return "Enemies/"+enemy_data.name+"/Attacks/"+attack#+".utscript"
	elif enemy_data.Attacks.size() == 0:
		return ""
	else:
		return "Enemies/"+enemy_data.name+"/Attacks/"+enemy_data.Attacks.pick_random()#+".utscript"

func getAttackConfig(attack : String):
	var attackPath : StringName = attack
	#if nextattack != "":
		#attackPath = "Enemies/"+enemy_data.name+"/Attacks/"+attack+".utscript"
	
	var configPath : StringName = attackPath.get_basename()+".txt"
	if FileAccess.file_exists(Undermaker.Path+"Scripts/"+configPath):
		var config = FileAccess.open(Undermaker.Path+"Scripts/"+configPath,FileAccess.READ)
		var configtext : Array[String] = []
		while !config.eof_reached():
			configtext.append(config.get_line())
		config.close()
		var index = -1
		for i in configtext:
			index += 1
			if i == "":
				configtext.remove_at(index)
				index -= 1
		
		if configtext.size() != 3:
			print("Invalid number of attack parameters")
			return null
		
		var attack_config = AttackData.new()
		attack_config.attack_script = attack
		attack_config.boxSize = Vector2(float(configtext[0]),float(configtext[1]))
		attack_config.mode = fmod(int(configtext[2]),2)
		
		return attack_config
	else:
		print("Attack config for "+attackPath.get_file()+" does not exist")
		return null

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
	if hasDamageScript:
		scr.damage = damage
		scr.run_script("Enemies/"+enemy_data.name+"/Damage.utscript")
		return
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
	var Dialogue = enemy_data.RandomDialogs.pick_random()
	if nextdialogue != "":
		Dialogue = nextdialogue
		nextdialogue = ""
	if Dialogue != "":
		talking = true
	else:
		return
	await get_tree().process_frame
	$SpeechBubble.visible = true
	$AudioStreamPlayer2.stream = Loader.load_file("Audio/Sounds/snd_TXT2.wav")
	talking = true
	var mettaton = false
	$SpeechBubble/TextObject.text = "[color:0:0:0]"
	var skip = 0
	
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
						if cmand[1] == "mettaton":
							mettaton = true
						else:
							mettaton = false
							$AudioStreamPlayer2.stream = Loader.load_file("Audio/Sounds/"+cmand[1]+".wav")
					"pause":
						while !Input.is_action_just_pressed("Select"):
							await get_tree().process_frame
					"clear":
						$SpeechBubble/TextObject.text = "[color:0:0:0]"
					"font":
						var font = FontFile.new()
						font.load_dynamic_font(Undermaker.Path+"Fonts/"+cmand[1])
						$SpeechBubble/TextObject.font = font
					"font_size":
						$SpeechBubble/TextObject.size = int(cmand[1])
						$SpeechBubble/TextObject.character_spacing = float(cmand[2])
						$SpeechBubble/TextObject.line_spacing = float(cmand[3])
					"set":
						var variable = $ScriptRunner.getVariable(cmand[1])
						if variable:
							if variable.type == Token.TokenType.TYPE_STRING:
								variable.value = cmand[2]
							elif variable.type == Token.TokenType.TYPE_NUM:
								variable.value = float(cmand[2])
							elif variable.type == Token.TokenType.TYPE_BOOL:
								if cmand[2] == "true":
									variable.value = true
								elif cmand[2] == "false":
									variable.value = false
					"playsnd":
						var audio = AudioStreamPlayer.new()
						audio.stream = Loader.load_file("Audio/Sounds/"+cmand[1]+".wav")
						add_child(audio)
						audio.play()
						audio.finished.connect(audio.queue_free)
					"skip":
						if mettaton:
							$AudioStreamPlayer2.stream = load("res://Audio/Sounds/snd_mtt"+str(randi_range(1,9))+".wav")
						$AudioStreamPlayer2.play()
						skip = float(cmand[1])
					"visibility":
						if cmand[1] == "true":
							$SpeechBubble.visible = true
						elif cmand[1] == "false":
							$SpeechBubble.visible = false
					_:
						$SpeechBubble/TextObject.text += "["+command+"]"
			_:
				if cmd:
					command += i
				else:
					$SpeechBubble/TextObject.text += i
					if i != " " and skip == 0:
						if mettaton:
							$AudioStreamPlayer2.stream = load("res://Audio/Sounds/snd_mtt"+str(randi_range(1,9))+".wav")
						$AudioStreamPlayer2.play()
					if skip == 0:
						await get_tree().process_frame
						await get_tree().process_frame
					else:
						skip -= 1
						if skip == 0:
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
	#if predialogue:
		#scr.script_to_run = "Enemies/"+enemy_data.name+"/PreDialogue.utscript"
	#if hasUpdateScript or predialogue:
	if hasUpdateScript:
		scr.run_script()
		#if predialogue:
			#predialogue = false
			#await scr.script_finished
			#ready_for_next_turn = true
	if damaging:
		sprite.texture = enemy_data.EnemyHurtSprite
	elif state == 2:
		sprite.texture = enemy_data.EnemySpareSprite
	else:
		sprite.texture = enemy_data.EnemySprite
