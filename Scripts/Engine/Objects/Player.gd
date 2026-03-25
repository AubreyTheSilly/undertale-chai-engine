class_name Player
extends Character

enum MENU_STATE {
	CHOICE,
	STATS,
	ITEM,
	ITEM_CHOICE,
	CALL,
	DIALOGUE
}

var menu_state : MENU_STATE = MENU_STATE.CHOICE
var menu_choice1 : int = 0
var menu_choice2 : int = 0
var menu_choice3 : int = 0

@onready var menumove : AudioStreamPlayer = $Menu/Move
@onready var menuselect : AudioStreamPlayer = $Menu/Select

var phonenumbers = []
var phonecalls = {}

func get_phone_dialogue(caller : String) -> Array:
	var dialogue = ["* Ring.."]
	
	if phonecalls.has(caller.to_lower()):
		if phonecalls[caller.to_lower()].has(PlayerData.room):
			dialogue.append_array(phonecalls[caller.to_lower()][PlayerData.room])
			dialogue.append("[sound:SND_TXT1][face:empty][font:DTM-Mono.otf][font-size:13:8:18]* Click...")
		elif phonecalls[caller.to_lower()].has("all"):
			dialogue.append_array(phonecalls[caller.to_lower()]["all"])
			dialogue.append("[sound:SND_TXT1][face:empty][font:DTM-Mono.otf][font-size:13:8:18]* Click...")
		else:
			dialogue.append("* ...")
			dialogue.append("* Nobody picked up.")
	else:
		dialogue.append("* ...")
		dialogue.append("* Nobody picked up.")
	
	return dialogue

func _ready() -> void:
	$Menu.visible = false
	PlayerData.obj = self
	reload_sprite()
	if Character_Sprite.IdleDown:
		_sprite.sprite_frames.add_frame("idle_down",Character_Sprite.IdleDown,1,-1)
	if Character_Sprite.IdleLeft:
		_sprite.sprite_frames.add_frame("idle_left",Character_Sprite.IdleLeft,1,-1)
	if Character_Sprite.IdleUp:
		_sprite.sprite_frames.add_frame("idle_up",Character_Sprite.IdleUp,1,-1)
	if Character_Sprite.IdleRight:
		_sprite.sprite_frames.add_frame("idle_right",Character_Sprite.IdleRight,1,-1)
	
	if Character_Sprite.WalkDown:
		for i in Character_Sprite.WalkDown:
			_sprite.sprite_frames.add_frame("move_down",i,1,-1)
	if Character_Sprite.WalkLeft:
		for i in Character_Sprite.WalkLeft:
			_sprite.sprite_frames.add_frame("move_left",i,1,-1)
	if Character_Sprite.WalkUp:
		for i in Character_Sprite.WalkUp:
			_sprite.sprite_frames.add_frame("move_up",i,1,-1)
	if Character_Sprite.WalkRight:
		for i in Character_Sprite.WalkRight:
			_sprite.sprite_frames.add_frame("move_right",i,1,-1)
	
	PlayerData.player_teleporting = false
	PlayerData.player_can_move = true
	if PlayerData.player_teleport_position != null:
		position = PlayerData.player_teleport_position
		PlayerData.player_teleport_position = null
	elif PlayerData.player_position:
		position = PlayerData.player_position
	if PlayerData.player_dir:
		match PlayerData.player_dir:
			Vector2(-1,0):
				direction = "left"
			Vector2(0,1):
				direction = "down"
			Vector2(0,-1):
				direction = "up"
			Vector2(1,0):
				direction = "right"
		_handleAnimation(Vector2.ZERO)
	fader.fadeIn()

func _process(_delta) -> void:
	var can_move = !DialogueHandler.visible and PlayerData.player_can_move and !PlayerData.player_teleporting and !$Menu.visible and SaveMenu.visible
	if can_move:
		velocity = Vector2(Input.get_axis("Move Left","Move Right"),Input.get_axis("Move Up","Move Down"))*(30*Speed)
		PlayerData.player_dir = Vector2(Input.get_axis("Move Left","Move Right"),Input.get_axis("Move Up","Move Down"))
	else:
		velocity = Vector2.ZERO
	_handleAnimation(velocity/(30*Speed))
	move_and_slide()
	
	PlayerData.player_position = position
	
	# handle phone call loading
	if phonenumbers != PlayerData.callers and PlayerData.has_cell_phone:
		phonenumbers = PlayerData.callers
		phonecalls = Undermaker.loadJsonAsDictionary("Data/calls.json")
	
	# menu handling
	var menu_bottom = false
	var playerpos = position
	if get_viewport().get_camera_2d():
		playerpos = (position-get_viewport().get_camera_2d().position)
	if playerpos.y > 120:
		menu_bottom = true
	$Menu/NameHealthGold.position.y = 26+(135*int(menu_bottom))
	
	$Menu/NameHealthGold/Name.text = PlayerData.Name
	$Menu/NameHealthGold/LVValue.text = str(PlayerData.LV)
	$Menu/NameHealthGold/HPValue.text = str(PlayerData.HP)+"/"+str(PlayerData.MaxHP)
	$Menu/NameHealthGold/GValue.text = str(PlayerData.GOLD)
	
	$Menu/Stats/Name.text = "\""+PlayerData.Name+"\""
	$Menu/Stats/LV.text = "LV "+str(PlayerData.LV)
	$Menu/Stats/HP.text = "HP "+str(PlayerData.HP)+"/ "+str(PlayerData.MaxHP)
	$Menu/Stats/AT.text = "AT "+str(PlayerData.ATK)
	$Menu/Stats/DF.text = "DF "+str(PlayerData.DEF)
	$Menu/Stats/WeaponAT.text = "("+str(PlayerData.weapon.value)+")"
	$Menu/Stats/ArmorDF.text = "("+str(PlayerData.armor.value)+")"
	$Menu/Stats/EXP.text = "EXP: "+str(PlayerData.EXP)
	var exp_to_next = [0,10,30,70,120,200,300,500,800,1200,1700,2500,3500,5000,7000,10000,15000,25000,50000,99999]
	$Menu/Stats/NEXT.text = "NEXT:"+str(exp_to_next[PlayerData.LV]-PlayerData.EXP)
	$Menu/Stats/WEAPON.text = "WEAPON: "+PlayerData.weapon.itemName
	$Menu/Stats/ARMOR2.text = ": "+PlayerData.armor.itemName
	$Menu/Stats/GOLD.text = "GOLD: "+str(PlayerData.GOLD)
	
	var can_open_menu = !DialogueHandler.visible and PlayerData.player_can_move and !PlayerData.player_teleporting and menu_state == MENU_STATE.CHOICE and SaveMenu.visible
	if can_open_menu and Input.is_action_just_pressed("Menu"):
		if !$Menu.visible:
			menumove.play()
		$Menu.visible = !$Menu.visible
	$Menu/Items/Items.text = ""
	for i in PlayerData.inventory:
		$Menu/Items/Items.text += i.itemName+"[newline]"
	$Menu/Call/Items.text = ""
	for i in PlayerData.callers:
		$Menu/Call/Items.text += i+"[newline]"
	
	$Menu/Stats.visible = false
	$Menu/Items.visible = false
	$Menu/Call.visible = false
	$Menu/MenuChoices/Cell.visible = PlayerData.has_cell_phone
	
	if $Menu.visible:
		match menu_state:
			MENU_STATE.CHOICE:
				menu_choice2 = 0
				
				if PlayerData.inventory.size() != 0:
					$Menu/MenuChoices/Item.text = "ITEM"
				else:
					$Menu/MenuChoices/Item.text = "[color:128:128:128]ITEM"
				
				if PlayerData.callers.size() != 0:
					$Menu/MenuChoices/Cell.text = "CELL"
				else:
					$Menu/MenuChoices/Cell.text = "[color:128:128:128]CELL"
				
				$Menu/heart.position = Vector2(32.5,$Menu/MenuChoices.get_children()[menu_choice1].global_position.y+8.5)
				$Menu/heart.visible = true
				if Input.is_action_just_pressed("Move Down"):
					if PlayerData.has_cell_phone:
						if menu_choice1 != 2:
							menu_choice1 += 1
							menumove.play()
					else:
						if menu_choice1 != 1:
							menu_choice1 += 1
							menumove.play()
				if Input.is_action_just_pressed("Move Up"):
					if menu_choice1 != 0:
						menu_choice1 -= 1
						menumove.play()
				if Input.is_action_just_pressed("Back"):
					$Menu.visible = false
				if Input.is_action_just_pressed("Select"):
					match menu_choice1:
						0:
							if PlayerData.inventory.size() != 0:
								menuselect.play()
								menu_state = MENU_STATE.ITEM
						1:
							menuselect.play()
							menu_state = MENU_STATE.STATS
						2:
							if PlayerData.callers.size() != 0:
								menuselect.play()
								menu_state = MENU_STATE.CALL
			MENU_STATE.STATS:
				$Menu/Stats.visible = true
				$Menu/heart.visible = false
				if Input.is_action_just_pressed("Back"):
					menu_state = MENU_STATE.CHOICE
			MENU_STATE.ITEM:
				menu_choice3 = 0
				$Menu/Items.visible = true
				$Menu/heart.position = Vector2(108.5,48.5+(16*menu_choice2))
				
				if Input.is_action_just_pressed("Move Up"):
					if menu_choice2 != 0:
						menumove.play()
						menu_choice2 -= 1
				if Input.is_action_just_pressed("Move Down"):
					if menu_choice2 != PlayerData.inventory.size()-1:
						menumove.play()
						menu_choice2 += 1
				if Input.is_action_just_pressed("Select"):
					menuselect.play()
					menu_state = MENU_STATE.ITEM_CHOICE
				if Input.is_action_just_pressed("Back"):
					menu_state = MENU_STATE.CHOICE
			MENU_STATE.ITEM_CHOICE:
				$Menu/Items.visible = true
				# 6.5 pixel difference between the text
				match menu_choice3:
					0:
						$Menu/heart.position = Vector2(108.5,188.5)
					1:
						$Menu/heart.position = Vector2(156.5,188.5)
					2:
						$Menu/heart.position = Vector2(213.5,188.5)
				if Input.is_action_just_pressed("Move Left"):
					if menu_choice3 != 0:
						menumove.play()
						menu_choice3 -= 1
				if Input.is_action_just_pressed("Move Right"):
					if menu_choice3 != 2:
						menumove.play()
						menu_choice3 += 1
				if Input.is_action_just_pressed("Select"):
					menu_state = MENU_STATE.DIALOGUE
					# using these from the battle script as reference...
					#if PlayerData.HP == PlayerData.MaxHP:
						#await FlavorBox.StartBattleDialogue([PlayerData.inventory[playeritemchoice+(4*itemmenu)].use.pick_random()+"[wait 2][newline]* Your HP was maxed out."])
					#else:
						#await FlavorBox.StartBattleDialogue([PlayerData.inventory[playeritemchoice+(4*itemmenu)].use.pick_random()+"[wait 2][newline]* You recovered "+str(PlayerData.inventory[playeritemchoice+(4*itemmenu)].value)+" HP!"])
					match menu_choice3:
						0:
							match PlayerData.inventory[menu_choice2].type:
								0:
									$Menu/Heal.play()
									PlayerData.HP += PlayerData.inventory[menu_choice2].value
									if PlayerData.HP >= PlayerData.MaxHP:
										DialogueHandler.StartDialogue([PlayerData.inventory[menu_choice2].use.pick_random()+"[wait 2][newline]* Your HP was maxed out."],int(!menu_bottom))
										PlayerData.HP = PlayerData.MaxHP
									else:
										DialogueHandler.StartDialogue([PlayerData.inventory[menu_choice2].use.pick_random()+"[wait 2][newline]* You recovered "+str(PlayerData.inventory[menu_choice2].value)+" HP!"],int(!menu_bottom))
										PlayerData.HP += PlayerData.inventory[menu_choice2].value
									PlayerData.inventory.remove_at(menu_choice2)
								1:
									$Menu/Equip.play()
									PlayerData.inventory.append(PlayerData.weapon)
									PlayerData.weapon = PlayerData.inventory[menu_choice2]
									DialogueHandler.StartDialogue([PlayerData.inventory[menu_choice2].use.pick_random()],int(!menu_bottom))
									PlayerData.inventory.remove_at(menu_choice2)
								2:
									$Menu/Equip.play()
									PlayerData.inventory.append(PlayerData.armor)
									PlayerData.armor = PlayerData.inventory[menu_choice2]
									DialogueHandler.StartDialogue([PlayerData.inventory[menu_choice2].use.pick_random()],int(!menu_bottom))
									PlayerData.inventory.remove_at(menu_choice2)
								3:
									DialogueHandler.StartDialogue([PlayerData.inventory[menu_choice2].use.pick_random()],int(!menu_bottom))
									PlayerData.inventory.remove_at(menu_choice2)
						1:
							DialogueHandler.StartDialogue(PlayerData.inventory[menu_choice2].check,int(!menu_bottom))
						2:
							var throwaway = randi_range(0,17)
							match throwaway:
								0:
									DialogueHandler.StartDialogue(["* You bid a quiet farewell[newline] to the"+PlayerData.inventory[menu_choice2].itemName+""],int(!menu_bottom))
								1:
									DialogueHandler.StartDialogue(["* You put the "+PlayerData.inventory[menu_choice2].itemName+"[newline]  on the ground and gave it a[newline]  little pat."],int(!menu_bottom))
								2:
									DialogueHandler.StartDialogue(["* You abandoned the "+PlayerData.inventory[menu_choice2].itemName+"."],int(!menu_bottom))
								3:
									DialogueHandler.StartDialogue(["* You threw the "+PlayerData.inventory[menu_choice2].itemName+" on the ground like the piece[newline]  of trash it is."],int(!menu_bottom))
								_:
									DialogueHandler.StartDialogue(["* The "+PlayerData.inventory[menu_choice2].itemName+" was[newline]  thrown away."],int(!menu_bottom))
							PlayerData.inventory.remove_at(menu_choice2)
					await DialogueHandler.dialogue_finished
					$Menu.visible = false
				if Input.is_action_just_pressed("Back"):
					menu_state = MENU_STATE.ITEM
			MENU_STATE.CALL:
				menu_choice3 = 0
				$Menu/Call.visible = true
				$Menu/heart.position = Vector2(108.5,48.5+(16*menu_choice2))
				
				if Input.is_action_just_pressed("Move Up"):
					if menu_choice2 != 0:
						menumove.play()
						menu_choice2 -= 1
				if Input.is_action_just_pressed("Move Down"):
					if menu_choice2 != PlayerData.callers.size()-1:
						menumove.play()
						menu_choice2 += 1
				if Input.is_action_just_pressed("Select"):
					menuselect.play()
					$Menu/Call2.play()
					menu_state = MENU_STATE.DIALOGUE
					DialogueHandler.StartDialogue(get_phone_dialogue(PlayerData.callers[menu_choice2]),int(!menu_bottom))
					await DialogueHandler.dialogue_finished
					$Menu.visible = false
				if Input.is_action_just_pressed("Back"):
					menu_state = MENU_STATE.CHOICE
			MENU_STATE.DIALOGUE:
				$Menu/heart.visible = false
	else:
		menu_state = MENU_STATE.CHOICE
	
	PlayerData.can_move_internal = can_move
