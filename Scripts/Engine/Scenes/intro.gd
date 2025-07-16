extends Node2D

@onready var image = $Sprite2D
var imageindex = 0

@onready var dialogbox = $Node2D
@onready var soundplayer = $AudioStreamPlayer

var skip = false

signal finisheddialogue

func _ready():
	$AudioStreamPlayer2.stream = Loader.load_file("Audio/BGM/mus_story.ogg")
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
		var textpos := Vector2(0,0)
		var index := 0
		var cmd = false
		var command = ""
		var textcolor := Color(1,1,1)
		var mode = "normal"
		var speed = 1
		for j in dialogbox.get_children():
			j.queue_free()
		for j in i:
			index += 1
			match j:
				"[":
					cmd = true
					command = ""
				"]":
					cmd = false
					var cmand = command.split(" ",false)
					match cmand[0]:
						"newline":
							textpos.x = 0
							textpos.y += 1
						"wait":
							for k in range(int(cmand[1])*7.5):
								await get_tree().process_frame
						"color":
							textcolor.r = float(cmand[1])/255.0
							textcolor.g = float(cmand[2])/255.0
							textcolor.b = float(cmand[3])/255.0
						"mode":
							mode = cmand[1]
						"speed":
							speed = int(cmand[1])
						"next":
							await nextimg()
				_:
					if cmd == true:
						command += j
					else:
						var chara = preload("res://Scenes/Objects/TextCharacter.tscn").instantiate()
						chara.name = "character"+str(index)
						chara.position = Vector2.ZERO
						chara.position.x += textpos.x*9
						chara.position.y += textpos.y*18
						chara.chara = j
						chara.color = textcolor
						chara.mode = mode
						textpos.x += 1
						dialogbox.add_child(chara)
						soundplayer.stream = load("res://Audio/Sounds/"+sound+".wav")
						if j != " ":
							soundplayer.play()
						for k in range(speed):
							await get_tree().process_frame
							await get_tree().process_frame
	finisheddialogue.emit()
