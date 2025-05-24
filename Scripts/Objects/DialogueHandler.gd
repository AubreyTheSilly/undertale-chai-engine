extends CanvasLayer

@onready var dialogbox := $Box/DialogueRect
@onready var soundplayer := $DialoguePlayer

var skiptext = false

enum {UP=0,DOWN=1}

func StartDialogue(dialogue : Array[String],position : int = DOWN) -> void:
	visible = true
	var sound = "SND_TXT1"
	var face = "none"
	if position == 0:
		$Box.position.y = 5
	else:
		$Box.position.y = 160
	for i in dialogue:
		var textpos := Vector2(0,0)
		var index := 0
		var cmd = false
		var command = ""
		var textcolor := Color(1,1,1)
		var mode = "normal"
		var speed = 1
		skiptext = false
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
				_:
					if cmd == true:
						command += j
					else:
						var chara = preload("res://Scenes/Objects/TextCharacter.tscn").instantiate()
						chara.name = "character"+str(index)
						chara.position = Vector2(14,10)
						chara.position.x += textpos.x*8
						chara.position.y += textpos.y*18
						chara.chara = j
						chara.color = textcolor
						chara.mode = mode
						textpos.x += 1
						dialogbox.add_child(chara)
						soundplayer.stream = load("res://Audio/Sounds/"+sound+".wav")
						if j != " " and !skiptext:
							soundplayer.play()
						if !skiptext:
							for k in range(speed):
								await get_tree().process_frame
								await get_tree().process_frame
		while !Input.is_action_just_pressed("Select"):
			await get_tree().process_frame
	visible = false

func _process(_delta) -> void:
	if visible and Input.is_action_just_pressed("Back"):
		skiptext = true
