extends Node2D

# onready nodes
@onready var FlavorBox = $FlavorBox
@onready var buttons : Array[Node2D] = [$FightButton,$ActButton,$ItemButton,$MercyButton]
@onready var BGM = $BGM
@onready var MenuSound = $MenuSound

# enemies
var enemies : Array[Node2D] = []
@onready var enemyamount = Battle.loadedBattle["enemies"].size()

# battle state enum
enum {PLAYER_BUTTON_CHOICE,PLAYER_ENEMY_CHOICE_FIGHT,PLAYER_ENEMY_CHOICE_ACT,PLAYER_ACT_CHOICE,PLAYER_ITEM_CHOICE,PLAYER_MERCY_CHOICE,ENEMY_DIALOGUE,ENEMY_ATTACK,ENEMY_ATTACK_END,PLAYER_ATTACK,PLAYER_ACT,BATTLE_END,PLAYER_ITEM_USE}

# general variables about the battle.
var state = PLAYER_BUTTON_CHOICE
var soulMode = Battle.SOULMODES.RED
var playerbuttonchoice = 0
var playerenemychoice = 0
var playeractchoice = 0
var playeritemchoice = 0
var itemmenu = 0
var playermercychoice = 0
var firstTurn = true
var EnemyDialogStarted = false
var battleOver := false
var attackStarted := false
var dialoguejustStarted = false

var camerashake := 0.0

func _ready():
	fader.fadeIn()
	$BGM.stream = Loader.load_file("Audio/BGM/"+Battle.loadedBattle["music"]+".ogg")
	$BGM.play()
	if !Battle.loadedBattle["bg"]:
		$background.visible = false
	var enemyindex = -1
	var occurences = {}
	for i in Battle.loadedBattle["enemies"]:
		enemyindex += 1
		if occurences.has(i):
			occurences[i] += 1
		else:
			occurences[i] = 1
		var enemyData = Undermaker.loadJsonAsDictionary("Data/Enemies/"+i+".json")
		var enemyObj = preload("res://Scenes/Objects/Enemy.tscn").instantiate()
		if Battle.loadedBattle["enemies"].size() == 2:
			if enemyindex == 0:
				enemyObj.position = Vector2(111,88)
			else:
				enemyObj.position = Vector2(199,88)
		elif Battle.loadedBattle["enemies"].size() == 3:
			if enemyindex == 0:
				enemyObj.position = Vector2(58,88)
			elif enemyindex == 1:
				enemyObj.position = Vector2(160,88)
			else:
				enemyObj.position = Vector2(260,88)
		else:
			enemyObj.position = Vector2(160,88)
		enemyObj.enemy_data = Battle.DictionaryToEnemyData(enemyData)
		if Battle.loadedBattle["enemies"].count(i) >= 2:
			enemyObj.enemy_data.EnemyName += [" A"," B"," C"][occurences[i]-1]
		enemyObj.name = "Enemy"+str(enemyindex)
		add_child(enemyObj)
		enemies.append(enemyObj)
	state = Battle.loadedBattle["state"]
	if state == 0:
		_PlayerTurn()

	#await get_tree().process_frame
	#visible = true

func _process(_delta):
	if camerashake < 1:
		camerashake = 0
	elif camerashake != 0:
		camerashake *= 0.6
	$Camera2D.offset = Vector2(randf_range(-camerashake,camerashake),randf_range(-camerashake,camerashake))
	
	if Undermaker.grey_empty:
		if PlayerData.inventory.size() != 0:
			$ItemButton.NormalSprite = preload("res://Sprites/Battle/Buttons/spr_itembt_0.png")
			$ItemButton.SelectSprite = preload("res://Sprites/Battle/Buttons/spr_itembt_1.png")
		else:
			$ItemButton.NormalSprite = preload("res://Sprites/Battle/Buttons/spr_itembt_empty_0.png")
			$ItemButton.SelectSprite = preload("res://Sprites/Battle/Buttons/spr_itembt_empty_1.png")
	
	$PlayerName.text = PlayerData.Name
	$LV.text = "LV "+str(PlayerData.LV)
	$HP.text = str(PlayerData.HP)+" / "+str(PlayerData.MaxHP)
	$HPBar.size.x = (12.5/20)*PlayerData.MaxHP
	$HPBar.value = PlayerData.HP
	$HPBar.max_value = PlayerData.MaxHP
	$HP.position.x = (137+$HPBar.size.x)+6.5
	
	if PlayerData.HP == 0:
		get_tree().change_scene_to_file("res://Scenes/gameover.tscn")
	
	$ChoiceBox/Choice0.modulate = Color(255,255,255)
	$ChoiceBox/Choice1.modulate = Color(255,255,255)
	$ChoiceBox/Choice2.modulate = Color(255,255,255)
	$ChoiceBox/Choice3.modulate = Color(255,255,255)
	$ChoiceBox/Choice4.modulate = Color(255,255,255)
	$ChoiceBox/Choice5.modulate = Color(255,255,255)
	
	$ChoiceBox/EnemyHealth1.visible = false
	$ChoiceBox/EnemyHealth2.visible = false
	$ChoiceBox/EnemyHealth3.visible = false
	
	match state:
		PLAYER_BUTTON_CHOICE:
			$HeartButtonChoice.visible = true
			$FlavorBox.visible = true
			$ChoiceBox.visible = false
			$AttackBox.visible = false
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
						if PlayerData.inventory.size() != 0:
							state = PLAYER_ITEM_CHOICE
					"3":
						state = PLAYER_MERCY_CHOICE
			for i in buttons:
				i.selected = false
			buttons[playerbuttonchoice].selected = true
		PLAYER_ENEMY_CHOICE_ACT:
			$HeartButtonChoice.visible = false
			$ChoiceBox.visible = true
			$ChoiceBox/HeartChoice.position = $ChoiceBox.get_node("Choice"+str(playerenemychoice*2)).position+Vector2(-13.5,9)
			$ChoiceBox/Choice0.text = "* "+enemies[0].enemy_data.EnemyName
			if enemies[0].spare == true:
				$ChoiceBox/Choice0.modulate = Color(255,255,0)
			if enemies[0].state != 1:
				$ChoiceBox/Choice0.visible = false
			$ChoiceBox/Choice1.visible = false
			$ChoiceBox/Choice2.visible = false
			$ChoiceBox/Choice3.visible = false
			$ChoiceBox/Choice4.visible = false
			$ChoiceBox/Choice5.visible = false
			if enemies.size() >= 2:
				if enemies[1].state == 1:
					$ChoiceBox/Choice2.text = "* "+enemies[1].enemy_data.EnemyName
					$ChoiceBox/Choice2.visible = true
					if enemies[1].spare == true:
						$ChoiceBox/Choice2.modulate = Color(255,255,0)
			if enemies.size() == 3:
				if enemies[2].state == 1:
					$ChoiceBox/Choice4.text = "* "+enemies[2].enemy_data.EnemyName
					$ChoiceBox/Choice4.visible = true
					if enemies[2].spare == true:
						$ChoiceBox/Choice4.modulate = Color(255,255,0)
			if enemies[playerenemychoice].state != 1:
				playerenemychoice+= 1
			if Input.is_action_just_pressed("Move Up") and playerenemychoice != 0 and enemies[playerenemychoice-1].state == 1:
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playerenemychoice -= 1
			if Input.is_action_just_pressed("Move Down") and playerenemychoice != (enemyamount-1) and enemies[playerenemychoice+1].state == 1:
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
			if enemies[0].spare == true:
				$ChoiceBox/Choice0.modulate = Color(255,255,0)
			if enemies[0].state != 1:
				$ChoiceBox/Choice0.visible = false
			else:
				$ChoiceBox/EnemyHealth1.visible = true
				$ChoiceBox/EnemyHealth1.position.x = 95+((enemies[0].enemy_data.EnemyName).length()*8)
				$ChoiceBox/EnemyHealth1.value = enemies[0].get_node("HPBar").value
				$ChoiceBox/EnemyHealth1.max_value = enemies[0].get_node("HPBar").max_value
			$ChoiceBox/Choice1.visible = false
			$ChoiceBox/Choice2.visible = false
			$ChoiceBox/Choice3.visible = false
			$ChoiceBox/Choice4.visible = false
			$ChoiceBox/Choice5.visible = false
			if enemies.size() >= 2:
				if enemies[1].state == 1:
					$ChoiceBox/Choice2.text = "* "+enemies[1].enemy_data.EnemyName
					$ChoiceBox/Choice2.visible = true
					$ChoiceBox/EnemyHealth2.visible = true
					$ChoiceBox/EnemyHealth2.position.x = 95+((enemies[1].enemy_data.EnemyName).length()*8)
					$ChoiceBox/EnemyHealth2.value = enemies[1].get_node("HPBar").value
					$ChoiceBox/EnemyHealth2.max_value = enemies[1].get_node("HPBar").max_value
					if enemies[1].spare == true:
						$ChoiceBox/Choice2.modulate = Color(255,255,0)
			if enemies.size() == 3:
				if enemies[2].state == 1:
					$ChoiceBox/Choice4.text = "* "+enemies[2].enemy_data.EnemyName
					$ChoiceBox/Choice4.visible = true
					$ChoiceBox/EnemyHealth3.visible = true
					$ChoiceBox/EnemyHealth3.position.x = 95+((enemies[2].enemy_data.EnemyName).length()*8)
					$ChoiceBox/EnemyHealth3.value = enemies[2].get_node("HPBar").value
					$ChoiceBox/EnemyHealth3.max_value = enemies[2].get_node("HPBar").max_value
					if enemies[2].spare == true:
						$ChoiceBox/Choice4.modulate = Color(255,255,0)
			if enemies[playerenemychoice].state != 1:
				playerenemychoice+= 1
			if Input.is_action_just_pressed("Move Up") and playerenemychoice != 0 and enemies[playerenemychoice-1].state == 1:
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playerenemychoice -= 1
			if Input.is_action_just_pressed("Move Down") and playerenemychoice != (enemyamount-1) and enemies[playerenemychoice+1].state == 1:
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playerenemychoice += 1
			if Input.is_action_just_pressed("Back"):
				state = PLAYER_BUTTON_CHOICE
			if Input.is_action_just_pressed("Select"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_select.wav")
				MenuSound.play()
				state = PLAYER_ATTACK
				var dmg = await $FightBox._attack(enemies[playerenemychoice].enemy_data)
				enemies[playerenemychoice]._damage(dmg)
				await enemies[playerenemychoice].damage_done
				$FightBox._close()
				state = ENEMY_DIALOGUE
		PLAYER_MERCY_CHOICE:
			var canspare = false
			for i in enemies:
				if i.spare and i.state == 1:
					canspare = true
			$HeartButtonChoice.visible = false
			$ChoiceBox.visible = true
			$ChoiceBox/HeartChoice.position = $ChoiceBox.get_node("Choice"+str(playermercychoice)).position+Vector2(-13.5,9)
			$ChoiceBox/Choice0.text = "* Spare"
			if canspare:
				$ChoiceBox/Choice0.modulate = Color(255,255,0)
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
				match playermercychoice:
					0:
						for i in enemies:
							if i.spare and i.state == 1:
								i._spare()
				state = ENEMY_DIALOGUE
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
			if Input.is_action_just_pressed("Move Right") and (playeractchoice != 1 and playeractchoice != 3 and playeractchoice != 5) and enemies[playerenemychoice].enemy_data.acts.size() != 1:
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
		PLAYER_ACT,PLAYER_ITEM_USE:
			$HeartButtonChoice.visible = false
			$ChoiceBox.visible = false
		PLAYER_ATTACK:
			$HeartButtonChoice.visible = false
			$ChoiceBox.visible = false
			$FlavorBox.visible = false
			$FightBox.visible = true
			for i in buttons:
				i.selected = false
		ENEMY_DIALOGUE:
			if dialoguejustStarted == false:
				dialoguejustStarted = true
				var attackconfigs : Array[AttackData] = []
				var attack_exists = false
				for i in enemies:
					await i._predialogue()
					var attack = i.getAttack()
					if attack != "":
						attack_exists = true
					else:
						continue
					var config = i.getAttackConfig(attack)
					if config:
						attackconfigs.append(config)
				var boxSize = Vector2(70.5,70.5)
				if attackconfigs.size() != 0:
					boxSize = attackconfigs[0].boxSize
				for i in attackconfigs:
					if boxSize.x < i.boxSize.x or boxSize.y < i.boxSize.y:
						boxSize = i.boxSize
				if attack_exists:
					$AttackBox.rect.size = boxSize
					$BattleHeart.visible = true
				return
			for i in buttons:
				i.selected = false
			$ChoiceBox.visible = false
			$FlavorBox.visible = false
			$FightBox.visible = false
			$AttackBox.visible = true
			var can_start = true
			for i in enemies:
				if i.ready_for_next_turn == false:
					can_start = false
			if EnemyDialogStarted == false and can_start:
				EnemyDialogStarted = true
				for i in enemies:
					if i.state == 1:
						i.dialogue()
			var donetalking = true
			for i in enemies:
				if i.talking == true:
					donetalking = false
			if donetalking:
				print("done talking")
				state = ENEMY_ATTACK
		ENEMY_ATTACK:
			if !attackStarted:
				dialoguejustStarted = false
				attackStarted = true
				EnemyDialogStarted = false
				var attacksLeft := 0
				for i in enemies:
					var attack = i.getAttack()
					var attack_config : AttackData = i.getAttackConfig(attack)
					if i.state == 1 and attack != "":
						attacksLeft += 1
						if attack_config:
							if attack_config.mode == 1:
								$AttackBox.runAttack(attack_config,i.enemy_data)
							else:
								$AttackBox.runScript(attack,i.enemy_data)
						else:
							$AttackBox.runScript(attack,i.enemy_data)
						i.nextattack = ""
				while attacksLeft != 0:
					await $AttackBox.attack_over
					attacksLeft -= 1
				for i in $AttackBox/attacks.get_children():
					if i.name != "bounding":
						i.queue_free()
				for i in $AttackBox/attacks/bounding.get_children():
					i.queue_free()
				if state == ENEMY_ATTACK:
					print(state)
					print("attack ending")
					state = ENEMY_ATTACK_END
				else:
					print("fuck")
					return
				$AttackBox.rect = Rect2(Vector2.ZERO,Vector2(288,70.5))
				if $AttackBox/Node2D/AttackRect.size != Vector2(288,70.5):
					if !get_tree():
						return
					await get_tree().create_timer(0.25).timeout
				var can_playerturn = false
				for i in enemies:
					if i.state == 1:
						can_playerturn = true
				if can_playerturn and state == ENEMY_ATTACK_END:
					print("player turn")
					_PlayerTurn()
		BATTLE_END:
			if !battleOver:
				battleOver = true
				$BGM.stop()
				$FightBox.visible = false
				$ChoiceBox.visible = false  
				if $AttackBox.visible:
					$AttackBox.rect = Rect2(Vector2.ZERO,Vector2(288,70.5))
					await get_tree().create_timer(0.25).timeout
				$AttackBox.visible = false
				$FlavorBox.visible = true
				var Exp = 0
				var gold = 0
				for i in enemies:
					if i.state == 0:
						Exp += i.enemy_data.EXP
					gold += i.enemy_data.GOLD
				PlayerData.EXP += Exp
				PlayerData.GOLD += gold
				await $FlavorBox.StartBattleDialogue(["* YOU WON![wait 2][newline]* You got "+str(Exp)+" EXP and "+str(gold)+" GOLD."])
				await fader.fadeOut()
				Undermaker.load_scene(PlayerData.room)
		PLAYER_ITEM_CHOICE:
			$HeartButtonChoice.visible = false
			$ChoiceBox.visible = true
			$ChoiceBox/Choice0.visible = false
			$ChoiceBox/Choice1.visible = false
			$ChoiceBox/Choice2.visible = false
			$ChoiceBox/Choice3.visible = false
			$ChoiceBox/Choice4.visible = false
			$ChoiceBox/Choice5.visible = true
			$ChoiceBox/Choice5.text = "PAGE "+str(int(itemmenu+1))
			var choicei := -1
			var items = PlayerData.inventory.size()
			if itemmenu == 0:
				items = clamp(items,0,4)
			else:
				items -= 4
			for i in PlayerData.inventory:
				choicei += 1
				var itemname = i.short
				if Battle.loadedBattle["serious"]:
					itemname = i.serious
				if choicei <= 3 and itemmenu == 0:
					$ChoiceBox.get_node("Choice"+str(int(fmod(choicei,4)))).visible = true
					$ChoiceBox.get_node("Choice"+str(int(fmod(choicei,4)))).text = "* "+itemname
				elif choicei >= 4 and itemmenu == 1:
					$ChoiceBox.get_node("Choice"+str(int(fmod(choicei,4)))).visible = true
					$ChoiceBox.get_node("Choice"+str(int(fmod(choicei,4)))).text = "* "+itemname
				
			playeritemchoice = clamp(playeritemchoice,0,items-1)
			$ChoiceBox/HeartChoice.position = $ChoiceBox.get_node("Choice"+str(playeritemchoice)).position+Vector2(-13.5,9)
			
			if Input.is_action_just_pressed("Move Up") and (playeritemchoice != 0 and playeritemchoice != 1):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playeritemchoice -= 2
			if Input.is_action_just_pressed("Move Down") and (playeritemchoice == 0 or playeritemchoice == 1) and items >= 3:
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				playeritemchoice += 2
			if Input.is_action_just_pressed("Move Left"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				if playeritemchoice == 0:
					if PlayerData.inventory.size() >= 5:
						itemmenu = fmod(itemmenu+1,2)
					playeritemchoice = 1
				elif playeritemchoice == 2:
					if PlayerData.inventory.size() >= 5:
						itemmenu = fmod(itemmenu+1,2)
					playeritemchoice = 3
				elif playeritemchoice == 4:
					if PlayerData.inventory.size() >= 5:
						itemmenu = fmod(itemmenu+1,2)
					playeritemchoice = 5
				else:
					playeritemchoice -= 1
			if Input.is_action_just_pressed("Move Right"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_squeak.wav")
				MenuSound.play()
				if playeritemchoice == 1 or (playeritemchoice == 0 and items == 1):
					if PlayerData.inventory.size() >= 5:
						itemmenu = fmod(itemmenu+1,2)
					playeritemchoice = 0
				elif playeritemchoice == 3:
					if PlayerData.inventory.size() >= 5:
						itemmenu = fmod(itemmenu+1,2)
					playeritemchoice = 2
				else:
					playeritemchoice += 1
			if Input.is_action_just_pressed("Back"):
				state = PLAYER_BUTTON_CHOICE
			if Input.is_action_just_pressed("Select"):
				MenuSound.stream = preload("res://Audio/Sounds/snd_select.wav")
				MenuSound.play()
				state = PLAYER_ITEM_USE
				match PlayerData.inventory[playeritemchoice+(4*itemmenu)].type:
					Item.HEALING:
						PlayerData.HP += PlayerData.inventory[playeritemchoice+(4*itemmenu)].value
						PlayerData.HP = clamp(PlayerData.HP,0,PlayerData.MaxHP)
						$Sounds.stream = preload("res://Audio/Sounds/snd_heal_c.wav")
						$Sounds.play()
						if PlayerData.HP == PlayerData.MaxHP:
							await FlavorBox.StartBattleDialogue([PlayerData.inventory[playeritemchoice+(4*itemmenu)].use.pick_random()+"[wait 2][newline]* Your HP was maxed out."])
						else:
							await FlavorBox.StartBattleDialogue([PlayerData.inventory[playeritemchoice+(4*itemmenu)].use.pick_random()+"[wait 2][newline]* You recovered "+str(PlayerData.inventory[playeritemchoice+(4*itemmenu)].value)+" HP!"])
						PlayerData.inventory.remove_at(playeritemchoice+(4*itemmenu))
					Item.WEAPON:
						PlayerData.HP += PlayerData.inventory[playeritemchoice+(4*itemmenu)].value
						PlayerData.HP = clamp(PlayerData.HP,0,PlayerData.MaxHP)
						$Sounds.stream = preload("res://Audio/Sounds/snd_item.wav")
						$Sounds.play()
						await FlavorBox.StartBattleDialogue([PlayerData.inventory[playeritemchoice+(4*itemmenu)].use.pick_random()])
						PlayerData.inventory.append(PlayerData.weapon)
						PlayerData.weapon = PlayerData.inventory[playeritemchoice+(4*itemmenu)]
						PlayerData.inventory.remove_at(playeritemchoice+(4*itemmenu))
					Item.ARMOR:
						PlayerData.HP += PlayerData.inventory[playeritemchoice+(4*itemmenu)].value
						PlayerData.HP = clamp(PlayerData.HP,0,PlayerData.MaxHP)
						$Sounds.stream = preload("res://Audio/Sounds/snd_item.wav")
						$Sounds.play()
						await FlavorBox.StartBattleDialogue([PlayerData.inventory[playeritemchoice+(4*itemmenu)].use.pick_random()])
						PlayerData.inventory.append(PlayerData.armor)
						PlayerData.armor = PlayerData.inventory[playeritemchoice+(4*itemmenu)]
						PlayerData.inventory.remove_at(playeritemchoice+(4*itemmenu))
				state = ENEMY_DIALOGUE
		_:
			pass
	$HeartButtonChoice.position.x = buttons[playerbuttonchoice].position.x-19.5
	var enemiesgone = true
	for i in enemies:
		if i.state == 1:
			enemiesgone = false
	if enemiesgone:
		state = BATTLE_END

func _PlayerTurn():
	attackStarted = false
	dialoguejustStarted = false
	state = PLAYER_BUTTON_CHOICE
	playerbuttonchoice = 0
	match enemies.size():
		1:
			if enemies[0].state == 1:
				playerenemychoice = 0
		2:
			if enemies[0].state == 1:
				playerenemychoice = 0
			elif enemies[1].state == 1:
					playerenemychoice = 1
		3:
			if enemies[0].state == 1:
				playerenemychoice = 0
			elif enemies[1].state == 1:
					playerenemychoice = 1
			elif enemies[2].state == 1:
				playerenemychoice = 2
	playeractchoice = 0
	playeritemchoice = 0
	itemmenu = 0
	EnemyDialogStarted = false
	if firstTurn:
		FlavorBox.StartFlavorDialogue(Battle.loadedBattle["encounterText"])
		firstTurn = false
	else:
		var enem : Node2D
		enem = enemies.pick_random()
		while enem.state != 1:
			enem = enemies.pick_random()
		FlavorBox.StartFlavorDialogue(enem.getFlavorText())
