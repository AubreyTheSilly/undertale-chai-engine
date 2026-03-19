extends Node

var Project : Dictionary = {
	"projectName":"New Project",
	"gameName":"UNDERTALE"
}
var Path : String = "res://"

var timer : float = 0

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
	print(dict)
	if not dict.has("extends") or not dict.has("editor_image"):
		push_error("Missing object data. Make sure you have extended and editor_image values defined!")
		return {}
	return dict

func loadJsonAsDictionary(dir : String) -> Dictionary:
	if !FileAccess.file_exists(Path+dir):
		print("JSON to load does not exist. Returning null.")
		return {}
	var file = FileAccess.open(Path+dir,FileAccess.READ)
	var json_string = file.get_line()
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

func createDirectory(dir : String) -> void:
	DirAccess.make_dir_absolute(Path+dir)

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
		get_window().title = Project["gameName"]
	if Input.is_action_just_pressed("Fullscreen"):
		if get_window().mode == get_window().MODE_FULLSCREEN:
			get_window().mode = get_window().MODE_WINDOWED
		else:
			get_window().mode = get_window().MODE_FULLSCREEN
	timer += 1

func load_scene(sceneName : String):
	get_tree().change_scene_to_packed(preload("res://Scenes/RoomLoader.tscn"))

func _ready():
	if OS.is_debug_build():
		Path="res://"
	else:
		Path=OS.get_executable_path().get_base_dir()+"/asset/"
	loadProject()
