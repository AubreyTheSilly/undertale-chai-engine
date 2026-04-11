extends Node2D

enum {START_MENU,NAMING_SCREEN,ACCEPT_NAME,TRANSITION,SETTINGS,MAIN_MENU}
var section = START_MENU
var full_menu := false

var start_choice := 0
var menuchoice := 0

@onready var settings = [$settings/exit]
var settingsData = []
var setting := 0

@onready var loadmenu_choices = [$loadmenu/continue,$loadmenu/settings,$loadmenu/reset]

var name_chars : Array[TextObject]
var char_positions : Array[Vector2]
var char_choice := 0

var confirm_choice := 0

var name_tween1 : Tween
var name_tween2 : Tween

@onready var names := Undermaker.loadJsonAsDictionary("Data/naming.json")
@onready var settingsJson := Undermaker.loadJsonAsDictionary("Data/settings.json")

func _ready():
	PlayerData.load_settings()
	
	var save_file = PlayerData.get_save_file()
	$loadmenu/name.text = save_file["name"]
	$loadmenu/lv.text = "LV "+str(int(save_file["lv"]))
	$loadmenu/place.text = save_file["save_name"]
	
	if str(int(fmod(save_file["time"],60))).length() == 1:
		$loadmenu/time.text = str(int(floor(save_file["time"]/60)))+" 0"+str(int(fmod(save_file["time"],60)))
	else:
		$loadmenu/time.text = str(int(floor(save_file["time"]/60)))+" "+str(int(fmod(save_file["time"],60)))
	
	full_menu = save_file != {"name":"EMPTY","lv":0,"time":0,"save_name":"---"}
	
	if full_menu:
		section = MAIN_MENU
	for i in PlayerData.settings:
		if not settingsJson.has(i):
			PlayerData.settings.erase(i)
	
	for i in settingsJson:
		if settingsJson[i] is not Dictionary:
			push_warning("Setting "+i+" is not a dictionary, it will be ignored")
			continue
		elif !settingsJson[i].has("type"):
			push_warning("Setting "+i+" does not have a type, it will be ignored")
			continue
		settingsData.append(settingsJson[i])
		if !PlayerData.settings.has(i):
			if settingsJson[i]["type"] == "value":
				PlayerData.settings[i] = settingsJson[i]["default"]
			else:
				PlayerData.settings[i] = settingsJson[i]["default"]
		var settingNode := $settings/TempSetting.duplicate()
		$settings.add_child(settingNode)
		settingNode.position.y = 40+((settings.size())*30)
		settingNode.name = i
		settingNode.get_node("setting").text = i.to_upper()
		settingNode.get_node("value").position.x = settingNode.get_node("setting").get_font_end_offset().x+30
		settings.append(settingNode)
	$settings/TempSetting.queue_free()
	
	for i in names:
		if names[i] is not Dictionary:
			push_warning("erased "+i+" from naming easter egg list because it is not a dictionary")
			names.erase(i)
			continue
		elif !names[i].has("text"):
			push_warning("erased "+i+" from naming easter egg list because there is no text set")
			names.erase(i)
			continue
		elif names[i]["text"] is not String:
			push_warning("erased "+i+" from naming easter egg list because text is not a string")
			names.erase(i)
			continue
		elif names[i].has("can_pick"):
			if names[i]["can_pick"] is not bool:
				push_warning("erased "+i+" from naming easter egg list because can_pick is not a bool")
				names.erase(i)
				continue
	$AudioStreamPlayer.stream = Loader.load_file("Audio/BGM/mus_menu0.ogg")
	$AudioStreamPlayer.play()
	
	for i in $name/Letters.get_children():
		name_chars.append(i)
		char_positions.append(i.position)
	name_chars.append($name/Quit)
	name_chars.append($name/Backspace)
	name_chars.append($name/Done)

func _process(_delta):
	for i in settings:
		if i.name == "exit":
			continue
		if settingsJson[i.name]["type"] == "slider":
			i.get_node("value").text = str(int(PlayerData.settings[i.name]))
		elif settingsJson[i.name]["type"] == "value":
			var val = settingsJson[i.name]["values"][PlayerData.settings[i.name]]
			if val is float:
				i.get_node("value").text = str(int(val))
			else:
				i.get_node("value").text = str(val)
		elif settingsJson[i.name]["type"] == "bool":
			var val = PlayerData.settings[i.name]
			if val == true:
				if settingsJson[i.name].has("true-text"):
					i.get_node("value").text = settingsJson[i.name]["true-text"]
				else:
					i.get_node("value").text = "TRUE"
			if val == false:
				if settingsJson[i.name].has("false-text"):
					i.get_node("value").text = settingsJson[i.name]["false-text"]
				else:
					i.get_node("value").text = "FALSE"
	
	if $name/Name.text.to_lower() == "gaster":
		get_tree().change_scene_to_file("res://Scenes/launch.tscn")
	
	if section != TRANSITION:
		$controls.visible = false
		$settings.visible = false
		$name.visible = false
		$confirm.visible = false
		$loadmenu.visible = false
	$controls/start.label_settings.font_color = Color.WHITE
	$controls/settings.label_settings.font_color = Color.WHITE
	$controls/Label3.text = Undermaker.Project["gameName"]+" BY "+Undermaker.Project["creator"]+"\nUSING UNDERTALE CHAI ENGINE (ALPHA)"
	match section:
		START_MENU:
			char_choice = 0
			$controls.visible = true
			match start_choice:
				0:
					$controls/start.label_settings.font_color = Color.YELLOW
				1:
					$controls/settings.label_settings.font_color = Color.YELLOW
			if Input.is_action_just_pressed("Move Up"):
				start_choice = 0
			if Input.is_action_just_pressed("Move Down"):
				start_choice = 1
			if Input.is_action_just_pressed("Select"):
				if start_choice == 0:
					section = NAMING_SCREEN
					#new_game()
				else:
					section = SETTINGS
		NAMING_SCREEN:
			confirm_choice = 0
			if name_tween1 or name_tween2:
				name_tween1.kill()
				name_tween2.kill()
			
			$name.visible = true
			var index = -1
			for i in name_chars:
				index += 1
				i.text = i.name
				if i.name.length() != 1:
					continue
				#i.rotation_degrees = randi_range(-1,1)
				var pos = char_positions[index]
				pos.x += randf_range(-1,1)/1.9
				pos.y += randf_range(-1,1)/1.9
				i.position = pos
			
			name_chars[char_choice].text = "[color:255:255:0]"+name_chars[char_choice].text
			if Input.is_action_just_pressed("Move Left"):
				match char_choice:
					0,52:
						pass
					_:
						char_choice -= 1
			if Input.is_action_just_pressed("Move Right"):
				match char_choice:
					54:
						pass
					_:
						char_choice += 1
			if Input.is_action_just_pressed("Move Up"):
				match char_choice:
					0,1,2:
						char_choice = 52
					3,4:
						char_choice = 53
					5,6:
						char_choice = 54
					26:
						char_choice = 21
					27:
						char_choice = 22
					28:
						char_choice = 23
					29:
						char_choice = 24
					30:
						char_choice = 25
					31:
						char_choice = 19
					32:
						char_choice = 20
					53:
						char_choice = 51
					_:
						char_choice -= 7
			if Input.is_action_just_pressed("Move Down"):
				match char_choice:
					19:
						char_choice = 31
					20:
						char_choice = 32
					21:
						char_choice = 26
					22:
						char_choice = 27
					23:
						char_choice = 28
					24:
						char_choice = 29
					25:
						char_choice = 30
					45,46,47,48,49,50,51:
						char_choice = 53
					52:
						char_choice = 0
					53:
						char_choice = 3
					54:
						char_choice = 5
					_:
						char_choice += 7
			if Input.is_action_just_pressed("Select"):
				match char_choice:
					52:
						section = START_MENU
					53:
						if $name/Name.text.length() != 0:
							$name/Name.text[-1] = ""
					54:
						#if $name/Name.text.length() != 0:
							$confirm/Name.position = Vector2(138.5,55.0)
							$confirm/Name.scale = Vector2(1.0,1.0)
							name_tween1 = create_tween()
							name_tween1.tween_property($confirm/Name,"position",Vector2(96.0,115.0),4)
							name_tween2 = create_tween()
							name_tween2.tween_property($confirm/Name,"scale",Vector2(3.5,3.5),4)
							section = ACCEPT_NAME
					_:
						if $name/Name.text.length() != 6:
							$name/Name.text += name_chars[char_choice].name
		ACCEPT_NAME:
			var can_pick := true
			$confirm.visible = true
			
			$confirm/Name.rotation_degrees = randi_range(0,1)
			$confirm/Name.text = $name/Name.text
			$confirm/Quote.text = "Is this name correct?"
			
			for i in names:
				if $confirm/Name.text.to_lower() == i:
					$confirm/Quote.text = names[i]["text"]
					if names[i].has("can_pick"):
						can_pick = names[i]["can_pick"]
			if full_menu:
				$confirm/Quote.text = "A name has already[newline]been chosen."
			
			if can_pick:
				$confirm/Yes.visible = true
				if confirm_choice == 0:
					$confirm/No.text = "[color:255:255:0]No"
					$confirm/Yes.text = "Yes"
				else:
					$confirm/No.text = "No"
					$confirm/Yes.text = "[color:255:255:0]Yes"
				if Input.is_action_just_pressed("Move Right"):
					confirm_choice = 1
				if Input.is_action_just_pressed("Move Left"):
					confirm_choice = 0
				if Input.is_action_just_pressed("Select"):
					match confirm_choice:
						0:
							if full_menu:
								section = MAIN_MENU
							else:
								section = NAMING_SCREEN
						1:
							new_game()
			else:
				$confirm/Yes.visible = false
				$confirm/No.text = "[color:255:255:0]Go back"
				if Input.is_action_just_pressed("Select"):
					section = NAMING_SCREEN
		MAIN_MENU:
			if name_tween1 or name_tween2:
				name_tween1.kill()
				name_tween2.kill()
			$loadmenu.visible = true
			
			if Input.is_action_just_pressed("Move Left"):
				menuchoice = 0
			if Input.is_action_just_pressed("Move Down"):
				menuchoice = 1
			if Input.is_action_just_pressed("Move Right"):
				menuchoice = 2
			if Input.is_action_just_pressed("Move Up") and menuchoice == 1:
				menuchoice = 0
			
			for i in loadmenu_choices:
				i.modulate = Color.WHITE
			loadmenu_choices[menuchoice].modulate = Color.YELLOW
			
			if Input.is_action_just_pressed("Select"):
				match menuchoice:
					0:
						PlayerData.loadFile(false)
					1:
						section = SETTINGS
					2:
						$name/Name.text = PlayerData.get_save_file()["name"]
						$confirm/Name.position = Vector2(138.5,55.0)
						$confirm/Name.scale = Vector2(1.0,1.0)
						name_tween1 = create_tween()
						name_tween1.tween_property($confirm/Name,"position",Vector2(96.0,115.0),4)
						name_tween2 = create_tween()
						name_tween2.tween_property($confirm/Name,"scale",Vector2(3.5,3.5),4)
						section = ACCEPT_NAME
		TRANSITION:
			$confirm/Name.rotation_degrees = randi_range(0,1)
		SETTINGS:
			$settings.visible = true
			for i in settings:
				i.modulate = Color.WHITE
			settings[setting].modulate = Color.YELLOW
			if Input.is_action_just_pressed("Move Down"):
				if setting == settings.size()-1:
					setting = 0
				else:
					setting += 1
			if Input.is_action_just_pressed("Move Up"):
				if setting == 0:
					setting = settings.size()-1
				else:
					setting -= 1
			
			if Input.is_action_just_pressed("Move Left"):
				if settings[setting].name == "exit":
					return
				var type = settingsData[setting-1]["type"]
				if type == "value":
					if PlayerData.settings[settings[setting].name] == 0:
						PlayerData.settings[settings[setting].name] = settingsData[setting-1]["values"].size()-1
					else:
						PlayerData.settings[settings[setting].name] -= 1
				if type == "slider":
					if PlayerData.settings[settings[setting].name] > settingsData[setting-1]["min"]:
						PlayerData.settings[settings[setting].name] -= settingsData[setting-1]["increment"]
			
			if Input.is_action_just_pressed("Move Right"):
				if settings[setting].name == "exit":
					return
				var type = settingsData[setting-1]["type"]
				if type == "value":
					if PlayerData.settings[settings[setting].name] == settingsData[setting-1]["values"].size()-1:
						PlayerData.settings[settings[setting].name] = 0
					else:
						PlayerData.settings[settings[setting].name] += 1
				if type == "slider":
					if PlayerData.settings[settings[setting].name] < settingsData[setting-1]["max"]:
						PlayerData.settings[settings[setting].name] += settingsData[setting-1]["increment"]
			
			if Input.is_action_just_pressed("Select"):
				if settings[setting].name == "exit":
					PlayerData.save_settings()
					if full_menu:
						section = MAIN_MENU
					else:
						section = START_MENU
					return
				var type = settingsData[setting-1]["type"]
				if type == "bool":
					PlayerData.settings[settings[setting].name] = !PlayerData.settings[settings[setting].name]

func new_game() -> void:
	PlayerData.Name = $confirm/Name.text
	section = TRANSITION
	$confirm/Quote.visible = false
	$confirm/No.visible = false
	$confirm/Yes.visible = false
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer2.play()
	await create_tween().tween_property($ColorRect,"color:a",1,6).finished
	PlayerData.loadFile(true)
