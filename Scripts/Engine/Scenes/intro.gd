extends Node2D

@onready var image = $Sprite2D
var imageindex = 0

@onready var dialogbox = $Node2D
@onready var soundplayer = $AudioStreamPlayer

func _ready():
	image.texture = load(Undermaker.Path+"Sprites/Intro/spr_introimage_"+str(imageindex)+".png")
	await StartDialogue(["Long ago,[wait 30][next]","Test 2[wait 30]"])

func nextimg():
	for i in range(15):
		image.modulate.a -= 1.0/15
		await get_tree().process_frame
	imageindex+=1
	image.texture = load(Undermaker.Path+"Sprites/Intro/spr_introimage_"+str(imageindex)+".png")
	for i in range(15):
		image.modulate.a += 1.0/15
		await get_tree().process_frame

func StartDialogue(dialogue : Array[String]) -> void:
	visible = true
	var sound = "SND_TXT2"
	var face = "none"
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
							for k in range(int(cmand[1])):
								await get_tree().process_frame
						"face":
							face = cmand[1]
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
						soundplayer.play()
						for k in range(speed):
							await get_tree().process_frame
							await get_tree().process_frame
	visible = false
