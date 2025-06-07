class_name Enemy
extends Node2D

# enemy data. loaded from a json file
@export var enemy_data : EnemyData
# objects. self explanatory
@onready var sprite = $Sprite2D
@onready var flavorbox = get_parent().get_node("FlavorBox")

# generic variables. can be altered and accessed via scripts
var spare := false
var talking := false
var nextdialogue := ""
var frame := 0
var damaging = false
var sin : float = 0
var cos : float = 0

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
	if UTScript.new().loadScript("Enemies/"+enemy_data.name+"/Create.utscript") == OK:
		var scr = UTScript.new()
		scr.loadScript("Enemies/"+enemy_data.name+"/Create.utscript")
		await runScript(scr)
	if UTScript.new().loadScript("Enemies/"+enemy_data.name+"/Update.utscript") == OK:
		hasUpdateScript = true

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
		state = ENEMY_STATE.DEAD
	else:
		# make it not hurt
		sprite.texture = enemy_data.EnemySprite
	damaging = false
	damage_done.emit()

func _spare():
	if spare == true:
		state = ENEMY_STATE.SPARED
		modulate.a = 0.5
		sprite.texture = enemy_data.EnemySpareSprite
		for i in range(14):
			var cloud = preload("res://Scenes/Objects/dustcloud.tscn").instantiate()
			add_child(cloud)
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
		if UTScript.new().loadScript("Enemies/"+enemy_data.name+"/Acts/"+Act+".utscript") == OK:
			var scr = UTScript.new()
			scr.loadScript("Enemies/"+enemy_data.name+"/Acts/"+Act+".utscript")
			await runScript(scr)
		else:
			await flavorbox.StartBattleDialogue(["* Error!"])

func dialogue() -> void:
	talking = true
	$SpeechBubble.visible = true
	$SpeechBubble/Label.text = ""
	var Dialogue = enemy_data.RandomDialogs.pick_random()
	if nextdialogue != "":
		Dialogue = nextdialogue
		nextdialogue = ""
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
	if enemy_data.autodialog:
		await get_tree().create_timer(0.5).timeout
	else:
		await next
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
					if get(j):
						text += str(get(j))+" "
					else:
						text += j+" "
				print(text)
			"dialog":
				var dialog = []
				for j in i.parameters:
					dialog.append(str(str_to_var(j)))
				await flavorbox.StartBattleDialogue(dialog)
			"set":
				if get(i.parameters[0]) != null:
					set(i.parameters[0],str_to_var(i.parameters[1]))
				else:
					vars[i.parameters[0]] = str_to_var(i.parameters[1])
			"set_enemydata":
				if enemy_data.get(i.parameters[0]) != null:
					if str(i.parameters[0]) == "EnemySprite" or str(i.parameters[0]) == "EnemyHurtSprite" or str(i.parameters[0]) == "EnemySpareSprite":
						enemy_data.set(i.parameters[0],load("res://Sprites/Battle/Enemies/"+i.parameters[1]+".png"))
					else:
						enemy_data.set(i.parameters[0],str_to_var(i.parameters[1]))
			"create_sprite":
				var sprite = Sprite2D.new()
				sprite.name = str(i.parameters[0])
				sprite.position = Vector2(int(i.parameters[1]),int(i.parameters[2]))
				sprite.texture = load("res://Sprites/"+str(i.parameters[3]))
				if i.parameters.size() >= 5:
					sprite.z_index = int(i.parameters[4])
				if i.parameters.size() >= 7:
					sprite.offset = Vector2(int(i.parameters[5]),int(i.parameters[6]))
				if i.flags.has("-scene"):
					get_tree().current_scene.add_child(sprite)
				else:
					add_child(sprite)
			"add":
				if vars[i.parameters[0]] is int:
					vars[i.parameters[0]] += int(i.parameters[1])
			"if":
				var compare = str(i.parameters[0])
				if i.flags.has("-not"):
					if get(compare):
						if i.parameters.size() == 1:
							runNext = false
						elif get(compare) == str_to_var(i.parameters[1]):
							runNext = false
						continue
					if !vars.has(compare):
						continue
					if vars[compare] == str_to_var(i.parameters[1]):
						runNext = false
				else:
					if get(compare):
						if i.parameters.size() == 1:
							runNext = true
						elif get(compare) == str_to_var(i.parameters[1]):
							runNext = true
						else:
							runNext = false
						continue
					if !vars.has(compare):
						runNext = false
						continue
					if vars[compare] != str_to_var(i.parameters[1]):
						runNext = false
			"stop":
				break

func _process(_delta):
	frame += 1
	sin = sin(frame)
	cos = cos(frame)
	if hasUpdateScript:
		var scr = UTScript.new()
		scr.loadScript("Enemies/"+enemy_data.name+"/Update.utscript")
		await runScript(scr)
	if damaging:
		sprite.texture = enemy_data.EnemyHurtSprite
	elif state == 2:
		sprite.texture = enemy_data.EnemySpareSprite
	else:
		sprite.texture = enemy_data.EnemySprite
