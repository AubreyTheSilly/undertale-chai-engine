extends Node2D

@onready var image = $Sprite2D
var imageindex = 0

@onready var dialogbox = $Node2D
@onready var soundplayer = $AudioStreamPlayer

var skip = false

signal finisheddialogue

func _ready():
	$AudioStreamPlayer2.stream = Loader.load_file("Audio/BGM/mus_story.ogg")
	var globalscript := AdvancedScriptRunner.loadScriptFromFile("global")
	if globalscript:
		GlobalScriptRunner.runScript(globalscript,get_tree().get_root())
	else:
		print("No global script detected")
	if FileAccess.file_exists(Undermaker.Path+"Data/intro.txt"):
		image.texture = Loader.load_file("Sprites/Intro/spr_introimage_"+str(imageindex)+".png")
		var introtext = FileAccess.open(Undermaker.Path+"Data/intro.txt",FileAccess.READ)
		var introdialog : Array[String] = []
		while !introtext.eof_reached():
			introdialog.append(introtext.get_line())
		visible = true
		$AudioStreamPlayer2.play()
		StartDialogue(introdialog)
		await finisheddialogue
		skip = true
	else:
		$ColorRect.modulate.a = 1

func _process(_delta):
	if Input.is_action_just_pressed("Select"):
		$AudioStreamPlayer.volume_db = -80
		$Node2D.visible = false
		skip = true
	if skip:
		$AudioStreamPlayer2.volume_db += -60*0.05
		$ColorRect.modulate.a += 0.05
	if $ColorRect.modulate.a >= 1:
		get_tree().change_scene_to_packed(preload("res://Scenes/TitleMenu.tscn"))

func nextimg():
	for i in range(15):
		image.modulate.a -= 1.0/15
		await get_tree().process_frame
	imageindex+=1
	image.texture = Loader.load_file("Sprites/Intro/spr_introimage_"+str(imageindex)+".png")
	for i in range(15):
		image.modulate.a += 1.0/15
		await get_tree().process_frame

func StartDialogue(dialogue : Array[String]) -> void:
	var sound = "SND_TXT2"
	for i in dialogue:
		var cmd = false
		var command = ""
		var speed = 1
		dialogbox.text = ""
		for j in i:
			match j:
				"[":
					cmd = true
					dialogbox.text += "["
					command = ""
				"]":
					dialogbox.text += "]"
					cmd = false
					var cmand = command.split(" ",false)
					match cmand[0]:
						"wait":
							for k in range(int(cmand[1])*7.5):
								await get_tree().process_frame
						"speed":
							speed = int(cmand[1])
						"next":
							await nextimg()
				_:
					if cmd == true:
						command += j
						dialogbox.text += j
					else:
						dialogbox.text += j
						soundplayer.stream = load("res://Audio/Sounds/"+sound+".wav")
						if j != " ":
							soundplayer.play()
						for k in range(speed):
							await get_tree().process_frame
							await get_tree().process_frame
	finisheddialogue.emit()
