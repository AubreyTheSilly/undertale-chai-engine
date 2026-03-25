extends Node

var Name = "Chara"
var HP : int = 20
var MaxHP : int = 20
var LV : int = 1
var EXP = 0
var GOLD = 0
var ATK : int = 0
var DEF : int = 0
var INV : int = 30
var weapon : Item = Items.STICK
var armor : Item = Items.BANDAGE
var inventory : Array[Item] = []
var flags : Dictionary[String,bool]
var fun : int = randi_range(0,100)
var room := "room_start"
var has_cell_phone : bool = false
var callers : Array[String] = []
var time : int = 0
var timecounter : float = 0
var count_time : bool = false
var save_name := ""

var obj : Player
var player_can_move = true
var player_teleporting = false
var player_teleport_position = null
var player_position : Vector2
var player_dir : Vector2 = Vector2.DOWN
var can_move_internal := false

func loadFile(newgame : bool = false):
	if newgame:
		HP = 20
		MaxHP = 20
		LV = 1
		EXP = 0
		GOLD = 0
		ATK = 0
		DEF = 0
		var items := Item.GetItemList()
		weapon = Items.STICK
		for i in items:
			if items[i].type == Item.WEAPON and weapon == Items.STICK:
				weapon = items[i]
		armor = Items.BANDAGE
		for i in items:
			if items[i].type == Item.ARMOR and weapon == Items.BANDAGE:
				armor = items[i]
		fun = randi_range(0,100)
		flags = {}
		room = "room_start"
		inventory = []
		has_cell_phone = false
		callers = []
		time = 0
		save_name = ""
	else:
		# TODO
		pass
	count_time = true
	get_tree().change_scene_to_file("res://Scenes/RoomLoader.tscn")

func _process(_delta):
	if count_time:
		timecounter += _delta
		if timecounter >= 1:
			timecounter -= 1
			time += 1
	else:
		timecounter = 0
	HP = clampi(HP,0,MaxHP)
