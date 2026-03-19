extends Node2D

enum {START_MENU,NAMING_SCREEN,ACCEPT_NAME,TRANSITION,SETTINGS}
var section = START_MENU

var start_choice := 0

var settings : Array[Setting] = [Setting.new("TestOption",Setting.TYPE.BOOL_ONOFF)]
var setting := 0

var name_chars : Array[TextObject]
var char_positions : Array[Vector2]
var char_choice := 0

var confirm_choice := 0

var name_tween1 : Tween
var name_tween2 : Tween

@onready var names := Undermaker.loadJsonAsDictionary("Data/naming.json")

func _ready():
	for i in names:
		if names[i] is not Dictionary:
			print("erased "+i+" from naming easter egg list because it is not a dictionary")
			names.erase(i)
			continue
		elif !names[i].has("text"):
			print("erased "+i+" from naming easter egg list because there is no text set")
			names.erase(i)
			continue
		elif names[i]["text"] is not String:
			print("erased "+i+" from naming easter egg list because text is not a string")
			names.erase(i)
			continue
		elif names[i].has("can_pick"):
			if names[i]["can_pick"] is not bool:
				print("erased "+i+" from naming easter egg list because can_pick is not a bool")
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
	if $name/Name.text.to_lower() == "gaster":
		get_tree().change_scene_to_file("res://Scenes/launch.tscn")
	
	if section != TRANSITION:
		$controls.visible = false
		$settings.visible = false
		$name.visible = false
		$confirm.visible = false
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
					#start_game()
				else:
					print("settings dont work yet")
					#section = SETTINGS
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
					0:
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
							section = NAMING_SCREEN
						1:
							start_game()
			else:
				$confirm/Yes.visible = false
				$confirm/No.text = "[color:255:255:0]Go back"
				if Input.is_action_just_pressed("Select"):
					section = NAMING_SCREEN
		TRANSITION:
			$confirm/Name.rotation_degrees = randi_range(0,1)

func start_game() -> void:
	PlayerData.name = $confirm/Name.text
	section = TRANSITION
	$confirm/Quote.visible = false
	$confirm/No.visible = false
	$confirm/Yes.visible = false
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer2.play()
	await create_tween().tween_property($ColorRect,"color:a",1,6).finished
	get_tree().change_scene_to_packed(preload("res://Scenes/RoomLoader.tscn"))
