extends Node2D

enum {START_MENU,NAMING_SCREEN,ACCEPT_NAME,TRANSITION,SETTINGS}
var section = START_MENU

var start_choice := 0

var settings : Array[Setting] = [Setting.new("TestOption",Setting.TYPE.BOOL_ONOFF)]
var setting := 0

func _ready():
	$AudioStreamPlayer.stream = Loader.load_file("Audio/BGM/mus_menu0.ogg")
	$AudioStreamPlayer.play()

func _process(_delta):
	$controls.visible = false
	$settings.visible = false
	$name.visible = false
	$confirm.visible = false
	$controls/start.label_settings.font_color = Color.WHITE
	$controls/settings.label_settings.font_color = Color.WHITE
	$controls/Label3.text = Undermaker.Project["gameName"]+"\nUSING UNDERTALE CHAI ENGINE (ALPHA)"
	match section:
		START_MENU:
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
					#section = NAMING_SCREEN
					start_game()
				else:
					print("settings dont work yet")
					#section = SETTINGS

func start_game():
	section = TRANSITION
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer2.play()
	await create_tween().tween_property($ColorRect,"color:a",1,6).finished
	get_tree().change_scene_to_packed(preload("res://Scenes/RoomLoader.tscn"))
