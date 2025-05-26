extends Node

var Project : Dictionary = {}
var Path : String = "res://"

var player_can_move = true

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
	return json.data

func createJsonFromDictionary(dir : String,dict : Dictionary = {}) -> Error:
	var file = FileAccess.open(Path+dir,FileAccess.WRITE)
	if !file:
		return FAILED
	var string = JSON.stringify(dict)
	file.store_line(string)
	return OK

func createDirectory(dir : String) -> void:
	DirAccess.make_dir_absolute(Path+dir)

func loadProject(openpath : String) -> Error:
	Path = openpath
	if Path[-1] != "\\":
		Path += "\\"
	Project = loadJsonAsDictionary(Path+"project.umproject")
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
	if Input.is_action_just_pressed("Fullscreen"):
		if get_window().mode == get_window().MODE_FULLSCREEN:
			get_window().mode = get_window().MODE_WINDOWED
		else:
			get_window().mode = get_window().MODE_FULLSCREEN
