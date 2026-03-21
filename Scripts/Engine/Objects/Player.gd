class_name Player
extends Character

enum MENU_STATE {
	CHOICE,
	STATS,
	ITEM,
	ITEM_CHOICE,
	CALL
}

var menu_state : MENU_STATE = MENU_STATE.CHOICE
var menu_choice1 : int = 0
var menu_choice2 : int = 0
var menu_choice3 : int = 0

@onready var menumove : AudioStreamPlayer = $Menu/Move
@onready var menuselect : AudioStreamPlayer = $Menu/Select

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
	var can_move = !DialogueHandler.visible and PlayerData.player_can_move and !PlayerData.player_teleporting and !$Menu.visible
	if can_move:
		velocity = Vector2(Input.get_axis("Move Left","Move Right"),Input.get_axis("Move Up","Move Down"))*(30*Speed)
		PlayerData.player_dir = Vector2(Input.get_axis("Move Left","Move Right"),Input.get_axis("Move Up","Move Down"))
	else:
		velocity = Vector2.ZERO
	_handleAnimation(velocity/(30*Speed))
	move_and_slide()
	
	PlayerData.player_position = position
	
	# menu handling
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
	
	var can_open_menu = !DialogueHandler.visible and PlayerData.player_can_move and !PlayerData.player_teleporting and !$Menu/Stats.visible
	if can_open_menu and Input.is_action_just_pressed("Menu"):
		$Menu.visible = !$Menu.visible
		menumove.play()
	
	$Menu/Stats.visible = false
	$Menu/Items.visible = false
	$Menu/Call.visible = false
	$Menu/MenuChoices/Cell.visible = PlayerData.has_cell_phone
	
	if $Menu.visible:
		match menu_state:
			MENU_STATE.CHOICE:
				if PlayerData.inventory.size() != 0:
					$Menu/MenuChoices/Item.text = "ITEM"
				else:
					$Menu/MenuChoices/Item.text = "[color:128:128:128]ITEM"
				
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
							menuselect.play()
							menu_state = MENU_STATE.CALL
			MENU_STATE.STATS:
				$Menu/Stats.visible = true
				$Menu/heart.visible = false
				if Input.is_action_just_pressed("Back"):
					menu_state = MENU_STATE.CHOICE
	else:
		menu_state = MENU_STATE.CHOICE
