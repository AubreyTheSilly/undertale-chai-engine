extends Node2D

@onready var FlavorBox = $FlavorBox
@onready var buttons : Array[Node2D] = [$FightButton,$ActButton,$ItemButton,$MercyButton]
@onready var BGM = $BGM
@onready var MenuSound = $MenuSound

var enemies : Array[Node2D] = []
@onready var enemyamount = Battle.loadedBattle["enemies"].size()

enum {PLAYER_BUTTON_CHOICE,PLAYER_ENEMY_CHOICE_FIGHT,PLAYER_ENEMY_CHOICE_ACT,PLAYER_ACT_CHOICE,PLAYER_ITEM_CHOICE,PLAYER_MERCY_CHOICE,ENEMY_DIALOGUE,ENEMY_ATTACK,PLAYER_ATTACK,PLAYER_ACT,BATTLE_END_FIGHT,BATTLE_END_MERCY}

var state = PLAYER_BUTTON_CHOICE
var soulMode = Battle.SOULMODES.RED
var playerbuttonchoice = 0
var playerenemychoice = 0
var playeractchoice = 0
var playermercychoice = 0
var firstTurn = true

# Called when the node enters the scene tree for the first time.
func _ready():
	var enemyindex = -1
	for i in Battle.loadedBattle["enemies"]:
		enemyindex += 1
		var enemyData = Undermaker.loadJsonAsDictionary("Data/Enemies/"+i+".json")
		var enemyObj = preload("res://Scenes/Objects/Enemy.tscn").instantiate()
		enemyObj.position = Vector2(132,94.5)
		enemyObj.enemy_data = Battle.DictionaryToEnemyData(enemyData)
		enemyObj.name = "Enemy"+str(enemyindex)
		add_child(enemyObj)
		enemies.append(enemyObj)
	_PlayerTurn()

func _process(_delta):
	for i in buttons:
		i.selected = false
	buttons[playerbuttonchoice].selected = true
	match state:
		PLAYER_BUTTON_CHOICE:
			$HeartButtonChoice.visible = true
			$ChoiceBox.visible = false
			if Input.is_action_just_pressed("Move Left"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playerbuttonchoice -= 1
				if playerbuttonchoice > 3:
					playerbuttonchoice = 0
				elif playerbuttonchoice < 0:
					playerbuttonchoice = 3
			if Input.is_action_just_pressed("Move Right"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playerbuttonchoice += 1
				if playerbuttonchoice > 3:
					playerbuttonchoice = 0
				elif playerbuttonchoice < 0:
					playerbuttonchoice = 3
			if Input.is_action_just_pressed("Select"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_select.wav")
				MenuSound.play()
				match str(playerbuttonchoice):
					"0":
						state = PLAYER_ENEMY_CHOICE_FIGHT
					"1":
						state = PLAYER_ENEMY_CHOICE_ACT
					"2":
						state = PLAYER_ITEM_CHOICE
					"3":
						state = PLAYER_MERCY_CHOICE
		PLAYER_ENEMY_CHOICE_ACT:
			$HeartButtonChoice.visible = false
			$ChoiceBox.visible = true
			$ChoiceBox/HeartChoice.position = $ChoiceBox.get_node("Choice"+str(playerenemychoice*2)).position+Vector2(-13.5,9)
			$ChoiceBox/Choice0.text = "* "+enemies[0].enemy_data.EnemyName
			$ChoiceBox/Choice1.visible = false
			$ChoiceBox/Choice2.visible = false
			$ChoiceBox/Choice3.visible = false
			$ChoiceBox/Choice4.visible = false
			$ChoiceBox/Choice5.visible = false
			if Input.is_action_just_pressed("Move Up") and playerenemychoice != 0:
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playerenemychoice -= 1
			if Input.is_action_just_pressed("Move Down") and playerenemychoice != (enemyamount-1):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playerenemychoice += 1
			if Input.is_action_just_pressed("Back"):
				state = PLAYER_BUTTON_CHOICE
			if Input.is_action_just_pressed("Select"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_select.wav")
				MenuSound.play()
				state = PLAYER_ACT_CHOICE
		PLAYER_ENEMY_CHOICE_FIGHT:
			$HeartButtonChoice.visible = false
			$ChoiceBox.visible = true
			$ChoiceBox/HeartChoice.position = $ChoiceBox.get_node("Choice"+str(playerenemychoice*2)).position+Vector2(-13.5,9)
			$ChoiceBox/Choice0.text = "* "+enemies[0].enemy_data.EnemyName
			$ChoiceBox/Choice1.visible = false
			$ChoiceBox/Choice2.visible = false
			$ChoiceBox/Choice3.visible = false
			$ChoiceBox/Choice4.visible = false
			$ChoiceBox/Choice5.visible = false
			if Input.is_action_just_pressed("Move Up") and playerenemychoice != 0:
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playerenemychoice -= 1
			if Input.is_action_just_pressed("Move Down") and playerenemychoice != (enemyamount-1):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playerenemychoice += 1
			if Input.is_action_just_pressed("Back"):
				state = PLAYER_BUTTON_CHOICE
			if Input.is_action_just_pressed("Select"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_select.wav")
				MenuSound.play()
				state = PLAYER_ATTACK
		PLAYER_MERCY_CHOICE:
			$HeartButtonChoice.visible = false
			$ChoiceBox.visible = true
			$ChoiceBox/HeartChoice.position = $ChoiceBox.get_node("Choice"+str(playermercychoice)).position+Vector2(-13.5,9)
			$ChoiceBox/Choice0.text = "* Spare"
			$ChoiceBox/Choice2.text = "* Flee"
			$ChoiceBox/Choice2.visible = true
			$ChoiceBox/Choice1.visible = false
			$ChoiceBox/Choice3.visible = false
			$ChoiceBox/Choice4.visible = false
			$ChoiceBox/Choice5.visible = false
			if Input.is_action_just_pressed("Move Up") and playermercychoice == 2:
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playermercychoice = 0
			if Input.is_action_just_pressed("Move Down") and playermercychoice == 0:
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playermercychoice = 2
			if Input.is_action_just_pressed("Back"):
				state = PLAYER_BUTTON_CHOICE
			if Input.is_action_just_pressed("Select"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_select.wav")
				MenuSound.play()
		PLAYER_ACT_CHOICE:
			$HeartButtonChoice.visible = false
			$ChoiceBox.visible = true
			$ChoiceBox/HeartChoice.position = $ChoiceBox.get_node("Choice"+str(playeractchoice)).position+Vector2(-13.5,9)
			$ChoiceBox/Choice0.visible = false
			$ChoiceBox/Choice1.visible = false
			$ChoiceBox/Choice2.visible = false
			$ChoiceBox/Choice3.visible = false
			$ChoiceBox/Choice4.visible = false
			$ChoiceBox/Choice5.visible = false
			var choicei := -1
			var choices = enemies[playerenemychoice].enemy_data.acts.size()
			for i in enemies[playerenemychoice].enemy_data.acts:
				choicei += 1
				$ChoiceBox.get_node("Choice"+str(choicei)).visible = true
				$ChoiceBox.get_node("Choice"+str(choicei)).text = "* "+i
			
			if Input.is_action_just_pressed("Move Up") and (playeractchoice != 0 and playeractchoice != 1):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playeractchoice -= 2
			if Input.is_action_just_pressed("Move Down") and not ((choices == 1 or choices == 2) or ((choices == 3 or choices == 4) and (playeractchoice == 2 or playeractchoice == 3)) or ((choices == 5 or choices == 6) and (playeractchoice == 4 or playeractchoice == 5))):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playeractchoice += 2
			if Input.is_action_just_pressed("Move Left") and (playeractchoice != 0 and playeractchoice != 2 and playeractchoice != 4):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playeractchoice -= 1
			if Input.is_action_just_pressed("Move Right") and (playeractchoice != 1 and playeractchoice != 3 and playeractchoice != 5):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playeractchoice += 1
			if Input.is_action_just_pressed("Back"):
				state = PLAYER_ENEMY_CHOICE_ACT
			if Input.is_action_just_pressed("Select"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_select.wav")
				MenuSound.play()
				state = PLAYER_ACT
				await enemies[playerenemychoice].act(enemies[playerenemychoice].enemy_data.acts[playeractchoice])
				state = ENEMY_DIALOGUE
		PLAYER_ACT:
			$HeartButtonChoice.visible = false
			$ChoiceBox.visible = false
		_:
			pass
	$HeartButtonChoice.position.x = buttons[playerbuttonchoice].position.x-19.5

func _PlayerTurn():
	state = PLAYER_BUTTON_CHOICE
	playerbuttonchoice = 0
	playerenemychoice = 0
	playeractchoice = 0
	if firstTurn:
		FlavorBox.StartFlavorDialogue(Battle.loadedBattle["encounterText"])
	else:
		FlavorBox.StartFlavorDialogue(Battle.loadedBattle["encounterText"])
