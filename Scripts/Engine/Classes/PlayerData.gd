extends Node

var Name = "Chara"
var HP : int = 20
var KR : int = 0
var MaxHP : int = 20
var LV : int = 1
var EXP := 0
var GOLD := 0
var ATK : int = 0
var DEF : int = 0
var INV : int = 30
var weapon : Item = Items.STICK
var armor : Item = Items.BANDAGE
var inventory : Array[Item] = []
var flags : Dictionary
var fun : int = randi_range(0,100)
var room := "room_start"
var has_cell_phone : bool = false
var callers : Array = []
var time : int = 0
var timecounter : float = 0
var count_time : bool = false
var save_name := ""

var obj : Player
var player_can_move := true
var player_teleporting := false
var player_teleport_position = null
var player_position : Vector2
var player_dir : Vector2 = Vector2.DOWN
var battle_soul_pos : Vector2 = Vector2(160,120)
var can_move_internal := false

var settings := {}

func get_save_file() -> Dictionary:
	var save := {"name":"EMPTY","lv":0,"time":0,"save_name":"---"}
	var saveFile = Undermaker.loadJsonAsDictionary_absolute("user://save_"+Undermaker.Project["projectName"]+".json")
	if saveFile != {}:
		save = saveFile
	# why the fuck is this here. i genuinely don't remember. in the event that it turns out this was meant for something i've commented it out instead of deleting it
	# var color : Color
	return save

func save_settings() -> void:
	Undermaker.createJsonFromDictionary_absolute("user://settings_"+Undermaker.Project["projectName"]+".json",settings)

func load_settings() -> void:
	var settingsJson = Undermaker.loadJsonAsDictionary_absolute("user://settings_"+Undermaker.Project["projectName"]+".json")
	
	if settingsJson != {}:
		settings = settingsJson

func savefile_to_dictionary() -> Dictionary:
	var save := {}
	
	save["name"] = Name
	save["HP"] = MaxHP
	save["MaxHP"] = MaxHP
	save["lv"] = LV
	save["atk"] = ATK
	save["def"] = DEF
	save["inventory"] = var_to_str(inventory)
	save["weapon"] = var_to_str(weapon)
	save["armor"] = var_to_str(armor)
	save["callers"] = callers
	save["has_cell_phone"] = has_cell_phone
	save["exp"] = EXP
	save["gold"] = GOLD
	save["save_name"] = save_name
	save["time"] = time
	save["room"] = room
	save["flags"] = flags
	save["fun"] = fun
	
	return save

func save_game() -> void:
	Undermaker.createJsonFromDictionary_absolute("user://save_"+Undermaker.Project["projectName"]+".json",savefile_to_dictionary())

func load_custom_stats() -> void:
	var prestats := Undermaker.loadJsonAsDictionary("Data/stats.json")
	if prestats:
		for i in prestats:
			if get_indexed(i):
				set_indexed(i,prestats[i])

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
		load_custom_stats()
	else:
		var save = get_save_file()
		Name = save["name"]
		MaxHP = save["HP"]
		MaxHP = save["MaxHP"]
		LV = save["lv"]
		ATK = save["atk"]
		DEF = save["def"]
		inventory = str_to_var(save["inventory"])
		weapon = str_to_var(save["weapon"])
		armor = str_to_var(save["armor"])
		callers = save["callers"]
		has_cell_phone = save["has_cell_phone"]
		EXP = save["exp"]
		GOLD = save["gold"]
		save_name = save["save_name"]
		time = save["time"]
		room = save["room"]
		flags = save["flags"]
		fun = save["fun"]
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
