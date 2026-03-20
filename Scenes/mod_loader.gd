extends Node2D

@onready var mods = Undermaker.get_mods_list(OS.get_executable_path().get_base_dir())

@onready var modTemplate = $modTemplate

var modNodes : Array[Node2D] = []
var modChoice := 0

var can_select = true

func _ready() -> void:
	get_window().title = "UNDERTALE Chai Engine Mod Loader"
	fader.fadeIn()
	var pos := 0.0
	var Project = Undermaker.Project
	Project["filename"] = "Default Assets Folder"
	mods.append(Project)
	for i in mods:
		var mod = modTemplate.duplicate()
		mod.name = i["filename"]
		mod.get_node("TextObject").text = i["filename"]
		mod.position.y = pos
		add_child(mod)
		modNodes.append(mod)
		pos += 24
	modTemplate.queue_free()

func _process(_delta) -> void:
	for i in modNodes:
		i.get_node("TextObject").text = i.name
	modNodes[modChoice].get_node("TextObject").text = "[color:255:255:0]"+modNodes[modChoice].name
	$Camera2D.position.y = lerpf($Camera2D.position.y,modNodes[modChoice].position.y,0.3)
	$CanvasLayer/Box/TextObject.text = mods[modChoice]["gameName"]
	$CanvasLayer/Box/TextObject2.text = mods[modChoice]["creator"]
	
	if !can_select:
		return
	
	if Input.is_action_just_pressed("Move Up"):
		$AudioStreamPlayer2.play()
		if modChoice == 0:
			modChoice = modNodes.size()-1
		else:
			modChoice -= 1
	if Input.is_action_just_pressed("Move Down"):
		$AudioStreamPlayer2.play()
		if modChoice == modNodes.size()-1:
			modChoice = 0
		else:
			modChoice += 1
	if Input.is_action_just_pressed("Select"):
		$AudioStreamPlayer.play()
		can_select = false
		await get_tree().create_timer(1).timeout
		await fader.fadeOut()
		if mods[modChoice]["filename"] != "Default Assets Folder":
			Undermaker.Project = mods[modChoice]
			Undermaker.Path = Undermaker.Path.left(Undermaker.Path.length()-6)+"mods/"+Undermaker.Project["filename"]+"/"
			print(Undermaker.Path)
		var flags = OS.get_cmdline_args()
		await get_tree().process_frame
		fader.fadeIn()
		if flags.has("--creator"):
			get_tree().change_scene_to_packed(preload("res://Scenes/editor.tscn"))
		elif flags.has("--battle"):
			get_tree().change_scene_to_packed(preload("res://Scenes/BattleLoader.tscn"))
		else:
			get_tree().change_scene_to_packed(preload("res://Scenes/intro.tscn"))
