extends Node

var Project : Dictionary = {
	"projectName":"New Project",
	"gameName":"UNDERTALE"
}
var Path : String = "res://"

var timer : float = 0

@onready var editor_fun := randi_range(1,100)

var discord_working := false

func get_mods_list(directory : String) -> Array[Dictionary]:
	var mods : Array[Dictionary] = []
	
	if DirAccess.dir_exists_absolute(directory+"/mods"):
		var mods_folder := DirAccess.open(directory+"/mods")
		
		mods_folder.list_dir_begin()
		
		var filename := mods_folder.get_next()
		while filename != "":
			if mods_folder.current_is_dir():
				if FileAccess.file_exists(directory+"/mods/"+filename+"/project.json") and filename != "Default Assets Folder":
					var modDict = loadJsonAsDictionary_absolute(directory+"/mods/"+filename+"/project.json")
					modDict["filename"] = filename
					mods.append(modDict)
				else:
					push_warning(filename+" does not have a valid project.json")
			filename = mods_folder.get_next()
		
		mods_folder.list_dir_end()
	else:
		push_warning("Mods folder does not exist!")
	
	return mods

func get_encounter_list() -> Array[String]:
	var encounters : Array[String] = []
	
	if DirAccess.dir_exists_absolute(Path+"Data/Encounters"):
		var mods_folder := DirAccess.open(Path+"Data/Encounters")
		
		mods_folder.list_dir_begin()
		
		var filename := mods_folder.get_next()
		while filename != "":
			if filename.ends_with(".txt"):
				encounters.append(filename.trim_suffix(".txt"))
			filename = mods_folder.get_next()
		
		mods_folder.list_dir_end()
	else:
		push_warning("Encounter folder does not exist!")
	
	return encounters

func get_object_image(objtype : String):
	if objtype == "Character" or objtype == "NPC":
		return preload("res://Sprites/npc1.png")
	elif objtype == "Player":
		return preload("res://Sprites/player.png")
	elif objtype == "Portal":
		return preload("res://Sprites/portal.png")
	elif objtype == "Trigger":
		return preload("res://Sprites/trigger.png")
	elif objtype == "DiagonalWall":
		if editor_fun >= 40 and editor_fun <= 45:
			return preload("res://Sprites/wall-diagonal2.png")
		else:
			return preload("res://Sprites/wall-diagonal1.png")
	elif objtype == "Wall":
		if editor_fun >= 40 and editor_fun <= 45:
			return preload("res://Sprites/wall2.png")
		else:
			return preload("res://Sprites/wall1.png")
	elif objtype == "SavePoint":
		return preload("res://Sprites/spr_savepoint_0.png")
	elif objtype != "" and FileAccess.file_exists(Path+"Data/Objects/"+objtype+".txt"):
		if Undermaker.loadTextAsObjectData(objtype):
			return Undermaker.loadTextAsObjectData(objtype)["editor_image"]
		else:
			return null
	else:
		return null

func getObjectByClassName(className : String,instantiate : bool = true) -> Object:
	var object : Object
	if ClassDB.class_exists(className):
		object = ClassDB.instantiate(className)
	else:
		var class_tscn : PackedScene = load("res://Scenes/Objects/"+className+".tscn")
		if class_tscn:
			if instantiate:
				object = class_tscn.instantiate()
			else:
				object = class_tscn
	return object

func loadCustomObject(objname : String):
	var objectdata = Undermaker.loadTextAsObjectData(objname)
	if objectdata == {}:
		return null
	var object = Undermaker.getObjectByClassName(objectdata["extends"])
	if object:
		for j in objectdata:
			if j != "extends" and j != "editor_image":
				object.set(j,objectdata[j])
	var script = UTScript.loadScriptFromFile("Objects/"+objname+".utscript")
	if script:
		var runner = preload("res://Scenes/Objects/object_script_runner.tscn").instantiate()
		runner.script_to_run = "Objects/"+objname+".utscript"
		runner.node = object
		object.add_child(runner)
	return object

func loadTextAsObjectData(dir : String) -> Dictionary:
	if !FileAccess.file_exists(Path+"Data/Objects/"+dir+".txt"):
		print("Object to load does not exist. Returning null.")
		return {}
	var file = FileAccess.open(Path+"Data/Objects/"+dir+".txt",FileAccess.READ)
	var string = ""
	while !file.eof_reached():
		string += file.get_line()+"\n"
	var dict : Dictionary = {}
	for i in string.split("\n"):
		var key : String = ""
		var value = ""
		var keying = true
		
		for j in i:
			if j == "=" and keying:
				keying = false
			elif keying:
				key += j
			else:
				value += j
		
		if key == "":
			continue
		if key == "extends":
			pass
		elif key == "editor_image":
			value = Loader.load_file("Sprites/"+value+".png")
		elif value.ends_with(".png") or value.ends_with(".wav") or value.ends_with(".ogg"):
			value = Loader.load_file(value)
		elif value.is_valid_int():
			value = int(value)
		elif value.is_valid_float():
			value = float(value)
		elif value == "true":
			value = true
		elif value == "false":
			value = false
		else:
			value = str_to_var(value)
		
		dict[key] = value
	# THIS PRINTED SO MUCH SHIT BUT ITS GONE NOW
	# print(dict)
	if not dict.has("extends") or not dict.has("editor_image"):
		push_error("Missing required values from "+dir+".txt. Make sure you have extended and editor_image values defined!")
		return {}
	return dict

func loadJsonAsDictionary(dir : String) -> Dictionary:
	if !FileAccess.file_exists(Path+dir):
		push_warning("JSON to load ("+Path+dir+") does not exist. Returning null.")
		return {}
	var file = FileAccess.open(Path+dir,FileAccess.READ)
	var json_string = ""
	while !file.eof_reached():
		json_string += file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		push_warning("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}
	file.close()
	return json.data

func loadJsonAsDictionary_absolute(dir : String) -> Dictionary:
	if !FileAccess.file_exists(dir):
		print("JSON to load does not exist. Returning null.")
		return {}
	var file = FileAccess.open(dir,FileAccess.READ)
	var json_string = ""
	while !file.eof_reached():
		json_string += file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}
	file.close()
	return json.data

func createJsonFromDictionary(dir : String,dict : Dictionary = {}) -> Error:
	var file = FileAccess.open(Path+dir,FileAccess.WRITE)
	print(FileAccess.get_open_error())
	if !file:
		return FAILED
	var string = JSON.stringify(dict)
	file.store_line(string)
	return OK

func createJsonFromDictionary_absolute(dir : String,dict : Dictionary = {}) -> Error:
	var file = FileAccess.open(dir,FileAccess.WRITE)
	print(FileAccess.get_open_error())
	if !file:
		return FAILED
	var string = JSON.stringify(dict)
	file.store_line(string)
	return OK

func createDirectory(dir : String) -> void:
	DirAccess.make_dir_absolute(Path+dir)

func createDirectory_absolute(dir : String) -> void:
	DirAccess.make_dir_absolute(dir)

func loadProject() -> Error:
	Project = loadJsonAsDictionary("project.json")
	if !Project:
		return FAILED
	get_window().title = Project["projectName"]
	return OK

func newProject(newpath : String) -> Error:
	Path = "res://"
	var baseJson = loadJsonAsDictionary("project.json")
	print("Using res://project.json as base:")
	print(baseJson)
	Path = newpath
	if Path[-1] != "\\":
		Path += "\\"
	if loadJsonAsDictionary("project.json") != {}:
		print("Project file already exists there.")
		return ERR_ALREADY_EXISTS
	if createJsonFromDictionary("project.json",baseJson) == FAILED:
		print("Project file could not be created due to malformed path!")
		return FAILED
	Project = loadJsonAsDictionary("project.umproject")
	get_window().title = Project["projectName"]
	createDirectory("Audio")
	createDirectory("Audio\\BGM")
	createDirectory("Audio\\Sounds")
	createDirectory("Data")
	createDirectory("Data\\Enemies")
	createDirectory("Scripts")
	createDirectory("Sprites")
	createDirectory("Sprites\\Character")
	createDirectory("Sprites\\Character\\Player")
	print("New project successfully created at "+Path+"!")
	return OK

func _process(_delta) -> void:
	if Undermaker.Project.has("gameName"):
		if get_tree():
			if get_tree().current_scene:
				if get_tree().current_scene.name != "ModLoader":
					get_window().title = Project["gameName"]
	if Input.is_action_just_pressed("Fullscreen"):
		if get_window().mode == get_window().MODE_FULLSCREEN:
			get_window().mode = get_window().MODE_WINDOWED
		else:
			get_window().mode = get_window().MODE_FULLSCREEN
	timer += 1

func load_scene(sceneName : String):
	PlayerData.room = sceneName
	if get_tree().current_scene.name == "Room":
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_packed(preload("res://Scenes/RoomLoader.tscn"))

func _ready():
	if OS.is_debug_build():
		Path="res://"
	else:
		Path=OS.get_executable_path().get_base_dir()+"/asset/"
	loadProject()
	
	# discord rpc
	
	# Application ID
	DiscordRPC.app_id = 1496670605519487027
	# this is boolean if everything worked
	discord_working = DiscordRPC.get_is_discord_working()
	if discord_working:
		print("Discord RPC is working! Yaaayyy :3")
		# Set the first custom text row of the activity here
		DiscordRPC.details = "An UNDERTALE fangame engine."
		# Set the second custom text row of the activity here
		#DiscordRPC.state = "Loading..."
		# Image key for small image from "Art Assets" from the Discord Developer website
		#DiscordRPC.large_image = "game"
		# Tooltip text for the large image
		#DiscordRPC.large_image_text = "Try it now!"
		# Image key for large image from "Art Assets" from the Discord Developer website
		#DiscordRPC.small_image = "boss"
		# Tooltip text for the small image
		#DiscordRPC.small_image_text = "Fighting the end boss! D:"
		# "02:41 elapsed" timestamp for the activity
		DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
		# "59:59 remaining" timestamp for the activity
		#DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600
		# Always refresh after changing the values!
		DiscordRPC.refresh()
	else:
		push_error("Discord RPC failed.")

func set_rpc_state(status : String) -> void:
	if discord_working:
		DiscordRPC.state = status
		DiscordRPC.refresh()
